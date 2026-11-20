import Foundation
import Testing
@testable import Immotom

/// Synthetic fixtures based on the current Kotlin DTOs, not captured server responses.
@Suite(.serialized)
@MainActor
struct BackendTests {
    private func session(handler: @escaping @Sendable (URLRequest) throws -> (Int, Data)) -> URLSession {
        BackendURLProtocol.handler = handler
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [BackendURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    private static func fixture(id: Int) -> String {
        """
        {"id":\(id),"title":"Wohnung","price":125000,"street":"Teststraße 1",
        "city":"Linz","zip":4020,"lat":48.3,"long":14.2,"area":75,"rooms":3,
        "image":"/uploads/house.jpg","description":"Helle Wohnung",
        "contact_company":"Testfirma","contact_name":"Testkontakt",
        "contact_phone":"+431234","contact_email":"test@example.invalid"}
        """
    }

    @Test func searchLoadsEveryPageAndEncodesFilters() async throws {
        let first = Self.fixture(id: 1)
        let second = Self.fixture(id: 2)
        let session = session { request in
            let url = try #require(request.url)
            #expect(url.path == "/api/it/inserate/search")
            #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
            let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
            let items = components.queryItems ?? []
            let query = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
            #expect(query["query"] == "Linz & Umgebung")
            #expect(query["price_max"] == "300000")
            #expect(query["rooms_min"] == "6")
            #expect(query["rooms_max"] == nil)
            #expect(query["pay_type"] == "0")
            #expect(query["type_id"] == "3")
            let item = query["page"] == "0" ? first : second
            return (200, Data("{\"content\":[\(item)],\"totalPages\":2}".utf8))
        }
        defer { session.invalidateAndCancel() }
        let url = try #require(URL(string: "https://example.invalid/api"))
        let client = BackendClient(baseURL: url, session: session)
        var filters = SearchFilters.default
        filters.locationText = "Linz & Umgebung"
        filters.maxPrice = 300000
        filters.rooms = "6+"
        filters.category = "Wohnung"
        let results = try await BackendListingsRepository(client: client).search(filters: filters)
        #expect(results.map(\.id) == ["1", "2"])
        #expect(results.first?.address == "Teststraße 1, 4020 Linz")
        #expect(results.first?.imageURL?.absoluteString == "https://example.invalid/uploads/house.jpg")
        #expect(results.first?.imageName == nil)
    }

    @Test func postcodeAndExactRooms() throws {
        var filters = SearchFilters.default
        filters.locationText = "4020"
        filters.rooms = "3"
        let items = try BackendListingsRepository.queryItems(filters: filters)
        let values = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
        #expect(values["zip"] == "4020")
        #expect(values["query"] == nil)
        #expect(values["rooms_min"] == "3")
        #expect(values["rooms_max"] == "3")
    }

    @Test func detailsUseIndexEndpointAndServerData() async throws {
        let fixture = Self.fixture(id: 7)
        let session = session { request in
            #expect(request.url?.path == "/it/inserate/index/7")
            return (200, Data(fixture.utf8))
        }
        defer { session.invalidateAndCancel() }
        let url = try #require(URL(string: "https://example.invalid"))
        let detail = try await BackendListingsDetailRepository(
            client: BackendClient(baseURL: url, session: session)
        ).fetchDetail(id: "7")
        #expect(detail.id == "7")
        #expect(detail.description == "Helle Wohnung")
        #expect(detail.contactCompany == "Testfirma")
        #expect(detail.contactStreet.isEmpty)
        #expect(detail.imageName == nil)
        #expect(detail.metaMid == "75 m²")
    }

    @Test(arguments: [404, 500])
    func httpErrors(status: Int) async throws {
        let session = session { _ in (status, Data()) }
        defer { session.invalidateAndCancel() }
        let url = try #require(URL(string: "https://example.invalid"))
        do {
            let _: BackendPage = try await BackendClient(baseURL: url, session: session).get("it/inserate/search")
            Issue.record("Expected an HTTP error")
        } catch BackendError.http(let received) {
            #expect(received == status)
        }
    }

    @Test func malformedResponse() async throws {
        let session = session { _ in (200, Data("not JSON".utf8)) }
        defer { session.invalidateAndCancel() }
        let url = try #require(URL(string: "https://example.invalid"))
        await #expect(throws: BackendError.self) {
            let _: BackendPage = try await BackendClient(baseURL: url, session: session).get("it/inserate/search")
        }
    }

    @Test func emptySearch() async throws {
        let session = session { _ in (200, Data("{\"content\":[],\"totalPages\":0}".utf8)) }
        defer { session.invalidateAndCancel() }
        let url = try #require(URL(string: "https://example.invalid"))
        let results = try await BackendListingsRepository(
            client: BackendClient(baseURL: url, session: session)
        ).search(filters: .default)
        #expect(results.isEmpty)
    }

    @Test func missingConfigurationAndInvalidID() async {
        await #expect(throws: BackendError.self) {
            let _: BackendPage = try await BackendClient(baseURL: nil).get("it/inserate/search")
        }
        await #expect(throws: BackendError.self) {
            _ = try await BackendListingsDetailRepository().fetchDetail(id: "../invalid")
        }
    }
}

private final class BackendURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (Int, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        do {
            guard let handler = Self.handler,
                  let url = request.url else { throw URLError(.badURL) }
            let (status, data) = try handler(request)
            guard let response = HTTPURLResponse(
                url: url, statusCode: status, httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            ) else { throw URLError(.badServerResponse) }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
