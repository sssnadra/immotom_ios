import Foundation
import CoreLocation

enum BackendError: LocalizedError {
    case missingBaseURL
    case invalidURL
    case invalidResponse
    case http(Int)
    case invalidID
    case unsupportedCategory
    case invalidPagination

    var errorDescription: String? {
        switch self {
        case .missingBaseURL: return "Die Backend-Adresse wurde noch nicht konfiguriert."
        case .invalidURL: return "Die Backend-Adresse ist ungültig."
        case .invalidResponse: return "Die Serverantwort konnte nicht verarbeitet werden."
        case .http(404): return "Dieses Inserat ist nicht mehr verfügbar."
        case .http(let status): return "Der Server meldet einen Fehler (HTTP \(status))."
        case .invalidID: return "Die Inserat-ID ist ungültig."
        case .unsupportedCategory: return "Die Kategorie Gewerbe wird vom Backend derzeit nicht unterstützt."
        case .invalidPagination: return "Die Suchergebnisse konnten nicht vollständig geladen werden."
        }
    }
}

/// Set this to the public API root once available, or use the scheme environment
/// variable IMMOTOM_API_BASE_URL. Include any reverse-proxy prefix, but not /it/inserate.
enum BackendConfiguration {
    static let baseURLString = "http://localhost:8082"


    static var baseURL: URL? {
        let value = ProcessInfo.processInfo.environment["IMMOTOM_API_BASE_URL"] ?? baseURLString
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return URL(string: trimmed)
    }
}

struct BackendClient {
    let baseURL: URL?
    let session: URLSession

    init(baseURL: URL? = BackendConfiguration.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        guard let baseURL else { throw BackendError.missingBaseURL }
        guard ["https", "http"].contains(baseURL.scheme?.lowercased() ?? ""),
              baseURL.host != nil,
              baseURL.user == nil, baseURL.password == nil,
              baseURL.query == nil, baseURL.fragment == nil,
              var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        else { throw BackendError.invalidURL }
        components.queryItems = query.isEmpty ? nil : query
        guard let url = components.url else { throw BackendError.invalidURL }
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse else { throw BackendError.invalidResponse }
        guard (200..<300).contains(response.statusCode) else { throw BackendError.http(response.statusCode) }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw BackendError.invalidResponse
        }
    }

    func imageURL(_ path: String) -> URL? {
        guard !path.isEmpty, let baseURL,
              let url = URL(string: path, relativeTo: baseURL.appendingPathComponent("/"))?.absoluteURL,
              ["https", "http"].contains(url.scheme?.lowercased() ?? "") else { return nil }
        return url
    }
}

struct BackendPage: Decodable {
    let content: [BackendListing]
    let totalPages: Int
}

/// Field names intentionally match ListingSmallDTO / ListingBigDTO in the backend.
struct BackendListing: Decodable {
    let id: Int
    let title: String
    let price: Int
    let street: String
    let city: String
    let zip: Int
    let lat: Double
    let long: Double
    let area: Int
    let rooms: Int
    let image: String
    let description: String?
    let availability: String?
    let contact_company: String?
    let contact_name: String?
    let contact_street: String?
    let contact_city: String?
    let contact_phone: String?
    let contact_email: String?

    private var priceText: String {
        price.formatted(.number.locale(Locale(identifier: "de_AT")))
    }

    private var zipCity: String {
        [zip > 0 ? String(zip) : "", city].filter { !$0.isEmpty }.joined(separator: " ")
    }

    func listing(client: BackendClient) -> Listing {
        Listing(
            id: String(id), title: title, price: priceText,
            address: [street, zipCity].filter { !$0.isEmpty }.joined(separator: ", "),
            imageURL: client.imageURL(image),
            coordinate: .init(latitude: lat, longitude: long)
        )
    }

    func detail(client: BackendClient) -> ListingDetail {
        var pairs = [("Zimmer", String(rooms)), ("Wohnfläche", "\(area) m²")]
        if let availability, !availability.isEmpty { pairs.append(("Verfügbarkeit", availability)) }
        return ListingDetail(
            id: String(id), title: title, price: priceText,
            street: street, zipCity: zipCity,
            metaLeft: "\(rooms) Zimmer", metaMid: "\(area) m²", metaRight: "Wohnfläche",
            imageURL: client.imageURL(image), imageName: nil,
            infoTitle: "Objektinformation", infoPairs: pairs,
            descriptionTitle: "Beschreibung", description: description ?? "",
            contactTitle: "Kontaktdaten",
            contactCompany: contact_company ?? "", contactPerson: contact_name ?? "",
            contactStreet: contact_street ?? "", contactCity: contact_city ?? "",
            contactEmail: contact_email ?? "", contactPhone: contact_phone ?? "",
            latitude: lat, longitude: long
        )
    }
}

struct BackendListingsRepository: ListingsRepository {
    let client: BackendClient

    init(client: BackendClient = BackendClient()) { self.client = client }

    func listings(ids: Set<String>) async throws -> [Listing] {
        var result: [Listing] = []
        for id in ids.sorted() {
            try Task.checkCancellation()
            guard let number = Int32(id), number > 0 else { continue }
            do {
                let response: BackendListing = try await client.get("it/inserate/index/\(number)")
                guard response.id == Int(number) else { throw BackendError.invalidResponse }
                result.append(response.listing(client: client))
            } catch BackendError.http(404) {
                // Keep the favorite ID saved even when its listing is unavailable.
                continue
            }
        }
        return result
    }

    func search(filters: SearchFilters) async throws -> [Listing] {
        let query = try Self.queryItems(filters: filters)
        var page = 0
        var listings: [Listing] = []
        var seenIDs = Set<String>()
        // Preserve the existing array-based repository contract by loading every page.
        while true {
            try Task.checkCancellation()
            let response: BackendPage = try await client.get(
                "it/inserate/search",
                query: query + [
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "size", value: "100"),
                    URLQueryItem(name: "sort", value: "id,asc")
                ]
            )
            guard response.totalPages >= 0 else { throw BackendError.invalidPagination }
            let mapped = response.content.map { $0.listing(client: client) }
            let newListings = mapped.filter { seenIDs.insert($0.id).inserted }
            listings.append(contentsOf: newListings)
            if page + 1 >= response.totalPages { return listings }
            guard !newListings.isEmpty else { throw BackendError.invalidPagination }
            page += 1
        }
    }

    static func queryItems(filters: SearchFilters) throws -> [URLQueryItem] {
        var query: [URLQueryItem] = []
        func add(_ name: String, _ value: Int?) {
            if let value { query.append(URLQueryItem(name: name, value: String(value))) }
        }
        add("price_min", filters.minPrice)
        add("price_max", filters.maxPrice)
        add("area_min", filters.minArea)
        add("area_max", filters.maxArea)

        let location = filters.locationText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !location.isEmpty {
            if location.allSatisfy({ $0.isNumber }), let zip = Int(location) {
                add("zip", zip)
            } else {
                query.append(URLQueryItem(name: "query", value: location))
            }
        }
        let rooms = filters.rooms.trimmingCharacters(in: .whitespacesAndNewlines)
        if let number = Int(rooms.replacingOccurrences(of: "+", with: "")) {
            add("rooms_min", number)
            if !rooms.hasSuffix("+") { add("rooms_max", number) }
        }
        // Lookup IDs follow V3__normalize_lookup_ids.sql.
        add("pay_type", ["Mieten": 0, "Kaufen": 1][filters.rentBuy])
        if filters.category == "Gewerbe" { throw BackendError.unsupportedCategory }
        add("type_id", ["Grundstück": 0, "Haus": 1, "Reihenhaus": 2, "Wohnung": 3, "WG": 4][filters.category])
        return query
    }
}

struct BackendListingsDetailRepository: ListingsDetailRepository {
    let client: BackendClient

    init(client: BackendClient = BackendClient()) { self.client = client }

    func fetchDetail(id: String) async throws -> ListingDetail {
        guard let number = Int32(id), number > 0 else { throw BackendError.invalidID }
        let response: BackendListing = try await client.get("it/inserate/index/\(number)")
        guard response.id == Int(number) else { throw BackendError.invalidResponse }
        return response.detail(client: client)
    }
}
