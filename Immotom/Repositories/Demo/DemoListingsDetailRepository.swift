import Foundation
import CoreLocation

/// Demo-Repository für Detaildaten.
///
/// - Ermöglicht eine funktionierende Detailansicht ohne Backend
/// - Liefert für bestimmte IDs fix definierte Detaildaten
/// - Für alle anderen IDs werden Platzhalterdaten gebaut
final class DemoListingsDetailRepository: ListingsDetailRepository {

    /// Liefert Detailinformationen zu einem Inserat (Demo).
    ///
    /// - Parameter id: Inserat-ID
    /// - Returns: `ListingDetail` für die Detailansicht
    func fetchDetail(id: String) async throws -> ListingDetail {
        switch id {
        case "1":
            // Für ID "1" wird eine besonders ausführliche Demo-Detailseite geliefert.
            return ListingDetail(
                id: "1",
                title: "Moderne Wohnung mit Garten",
                price: "€ 125.000",
                street: "Am Sonnenhang 12",
                zipCity: "4040 Linz",
                metaLeft: "5 Zimmer",
                metaMid: "98 m²",
                metaRight: "Wohnfläche",
                imageURL: nil,
                imageName: "house1",
                infoTitle: "Objektinformation",

                // Key-Value-Paare, die in der UI in einer Tabelle/Spalte angezeigt werden.
                infoPairs: [
                    ("Objekttyp", "Wohnung"),
                    ("Stockwerk(e)", "1"),
                    ("Zimmer", "5"),
                    ("Wohnfläche", "98 m²"),
                    ("Verfügbarkeit", "ab sofort"),
                    ("Heizung", "Bodenheizung"),
                    ("Heizungstyp", "Wärmepumpe"),
                    ("Böden", "Parkett & Fliesen"),
                    ("Freiflächen", "Garten"),
                    ("Ausstattung", "Einbauküche, Teilmöbliert / Möbliert")
                ],
                descriptionTitle: "Beschreibung",
                description: "Diese moderne und lichtdurchflutete Wohnung verbindet zeitgemäßes Wohnen mit einem hohen Maß an Komfort und Privatsphäre...",
                contactTitle: "Kontaktdaten",
                contactCompany: "Immotom Immobilien GmbH",
                contactPerson: "Max Mustermann",
                contactStreet: "Luftschloss 41",
                contactCity: "1234 Lufthausen",
                contactEmail: "office@immotom.at",
                contactPhone: "+43 664 133 13 13",
                latitude: 48.3069,
                longitude: 14.2858
            )

        default:
            // Für andere IDs wird versucht, ein Listing aus den Demo-Listen zu finden.
            let listing = try await DemoListingsRepository()
                .search(filters: .default)
                .first { $0.id == id }

            // Adresse splitten, damit UI Straße + Ort getrennt anzeigen kann.
            let address = listing?.address ?? "-"
            let (street, zipCity) = Self.splitAddress(address)

            // Detaildaten
            return ListingDetail(
                id: id,
                title: listing?.title ?? "Objekt",
                price: listing?.price ?? "-",
                street: street,
                zipCity: zipCity,
                metaLeft: "-",
                metaMid: "-",
                metaRight: "-",
                imageURL: listing?.imageURL,
                imageName: "house2",
                infoTitle: "Objektinformation",

                infoPairs: [
                    ("Objekttyp", "Immobilie"),
                    ("Stockwerk(e)", "1"),
                    ("Zimmer", "5"),
                    ("Wohnfläche", "100 m²"),
                    ("Verfügbarkeit", "ab sofort"),
                    ("Heizung", "Heizung"),
                    ("Heizungstyp", "Wärmepumpe"),
                    ("Böden", "Parkett & Fliesen"),
                    ("Freiflächen", "Garten"),
                    ("Ausstattung", "Möbliert")
                ],
                descriptionTitle: "Beschreibung",
                description: "Keine Detaildaten vorhanden.",
                contactTitle: "Kontaktdaten",
                contactCompany: "Immotom GmbH",
                contactPerson: "Team",
                contactStreet: "-",
                contactCity: "-",
                contactEmail: "-",
                contactPhone: "-",
                latitude: listing?.latitude ?? 48.3069,
                longitude: listing?.longitude ?? 14.2858
            )
        }
    }

    // MARK: - Helpers

    /// Splittet eine Adresse der Form "Straße..., PLZ Ort" in zwei Teile.
    private static func splitAddress(_ address: String) -> (street: String, zipCity: String) {
        let parts = address
            .split(separator: ",", maxSplits: 1)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if parts.count == 2 {
            return (parts[0], parts[1])
        } else {
            return (address.isEmpty ? "-" : address, "-")
        }
    }
}

