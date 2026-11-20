import Foundation
import CoreLocation

/// Demo-Repository für Inserate.
///
/// Diese Version unterstützt neben der Umkreissuche zusätzlich:
/// - Kategorie (filters.category)   [wenn != "Alle"]
/// - Mieten/Kaufen (filters.rentBuy)
/// - Preis min/max (filters.minPrice / maxPrice)
/// - Fläche min/max (filters.minArea / maxArea)
/// - Zimmer (filters.rooms)
final class DemoListingsRepository: ListingsRepository {

    // MARK: - Demo Daten (Listings)

    private let demo: [Listing] = [
        Listing(
            id: "1",
            title: "Moderne Wohnung mit Garten",
            price: "125.000",
            address: "Landstraße 12, 4020 Linz",
            imageName: "house1",
            coordinate: .init(latitude: 48.3069, longitude: 14.2858)
        ),
        Listing(
            id: "2",
            title: "Charmantes Haus am Stadtrand",
            price: "395.000",
            address: "Siedlungsweg 4, 4040 Linz",
            imageName: "house2",
            coordinate: .init(latitude: 48.3330, longitude: 14.3000)
        ),
        Listing(
            id: "3",
            title: "Zentrale Mietwohnung mit Balkon",
            price: "950",
            address: "Hauptstraße 1, 4020 Linz",
            imageName: "house3",
            coordinate: .init(latitude: 48.3050, longitude: 14.2905)
        )
    ]

    // MARK: - Meta Daten (für Filter)

    /// Zusätzliche Filterdaten je Listing-ID.
    /// Dadurch müssen wir `Listing` nicht aufblasen.
    private struct ListingMeta {
        let category: String
        let rentBuy: String
        let priceValue: Int
        let areaSqm: Int?
        let rooms: Int?
        let floor: String?
    }

    private let metaById: [String: ListingMeta] = [
        "1": .init(category: "Wohnung", rentBuy: "Kaufen", priceValue: 125000, areaSqm: 98, rooms: 5, floor: "1"),
        "2": .init(category: "Haus",    rentBuy: "Kaufen", priceValue: 395000, areaSqm: 160, rooms: 6, floor: nil),
        "3": .init(category: "Wohnung", rentBuy: "Mieten", priceValue: 950,    areaSqm: 55, rooms: 2, floor: "2"),
    ]

    func listings(ids: Set<String>) async throws -> [Listing] {
        demo.filter { ids.contains($0.id) }
    }

    // MARK: - Search

    /// Demo-Suche: Radius + zusätzliche Filter.
    func search(filters: SearchFilters) async throws -> [Listing] {
        let center = filters.center
        let maxKm = filters.radiusKm

        // Radiusfilter
        let radiusFiltered = demo.filter { listing in
            Geo.distanceKm(
                fromLat: center.latitude,
                fromLon: center.longitude,
                toLat: listing.latitude,
                toLon: listing.longitude
            ) <= maxKm
        }

        // Detailfilter
        return radiusFiltered.filter { listing in
            guard let meta = metaById[listing.id] else {
                // Wenn keine Metadaten existieren, wird es durchgelassen
                return true
            }

            // Kategorie
            if filters.category != "Alle", meta.category != filters.category {
                return false
            }

            // Mieten/Kaufen
            if meta.rentBuy != filters.rentBuy {
                return false
            }

            // Preis
            if let minP = filters.minPrice, meta.priceValue < minP { return false }
            if let maxP = filters.maxPrice, meta.priceValue > maxP { return false }

            // Fläche
            if let minA = filters.minArea {
                // Wenn Fläche fehlt, wird es als "nicht passend" behandelt.
                guard let area = meta.areaSqm, area >= minA else { return false }
            }
            if let maxA = filters.maxArea {
                guard let area = meta.areaSqm, area <= maxA else { return false }
            }

            // Zimmer
            if filters.rooms != "Zimmer" {
                guard let required = Self.parseRoomsRequirement(filters.rooms) else { return true }
                guard let rooms = meta.rooms else { return false }

                switch required {
                case .atLeast(let n):
                    if rooms < n { return false }
                case .exact(let n):
                    if rooms != n { return false }
                }
            }

            // Stockwerk
            if filters.floor != "Stockwerk" {
                // Wenn floor im Meta nicht existiert -> nicht passend
                guard let floor = meta.floor else { return false }
                if floor != filters.floor { return false }
            }

            return true
        }
    }

    // MARK: - Helpers

    private enum RoomsRequirement {
        case exact(Int)
        case atLeast(Int)
    }

    /// Parst z.B.:
    /// - "2"  -> exact(2)
    /// - "6+" -> atLeast(6)
    private static func parseRoomsRequirement(_ text: String) -> RoomsRequirement? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if t.hasSuffix("+") {
            let digits = t.dropLast().filter { $0.isNumber }
            if let n = Int(digits) { return .atLeast(n) }
            return nil
        } else {
            let digits = t.filter { $0.isNumber }
            if let n = Int(digits) { return .exact(n) }
            return nil
        }
    }
}

