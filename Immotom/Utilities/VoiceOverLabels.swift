import SwiftUI

/// Zentrale, lokalisierbare VoiceOver-Texte. Keine eigene Sprachausgabe:
/// VoiceOver übernimmt Sprache, Bedienhinweise und die Rollen der Systemcontrols.
@MainActor
final class VoiceOverLabels {
    private init() {}

    static let openMenu: LocalizedStringKey = "Menü öffnen"
    static let closeMenu: LocalizedStringKey = "Menü schließen"
    static let back: LocalizedStringKey = "Zurück"
    static let closeFilters: LocalizedStringKey = "Detailfilter schließen"
    static let applyFilters: LocalizedStringKey = "Filter anwenden"
    static let location: LocalizedStringKey = "Ort oder Postleitzahl"
    static let searchLocation: LocalizedStringKey = "Stadt, Postleitzahl oder Adresse"
    static let minimumPrice: LocalizedStringKey = "Mindestpreis in Euro"
    static let maximumPrice: LocalizedStringKey = "Höchstpreis in Euro"
    static let minimumArea: LocalizedStringKey = "Mindestfläche in Quadratmetern"
    static let maximumArea: LocalizedStringKey = "Höchstfläche in Quadratmetern"
    static let radius: LocalizedStringKey = "Suchradius"
    static let email: LocalizedStringKey = "E-Mail-Adresse"
    static let openDetails: LocalizedStringKey = "Öffnet die Details dieser Immobilie"
    static let search: LocalizedStringKey = "Immobilien suchen"
    static let unavailable: LocalizedStringKey = "Diese Funktion ist noch nicht verfügbar."
    static let loadingListings: LocalizedStringKey = "Immobilien werden geladen"
    static let loadingDetails: LocalizedStringKey = "Immobiliendetails werden geladen"

    static func resultCount(_ count: Int) -> LocalizedStringKey {
        switch count {
        case 0: return "Keine Immobilien gefunden"
        case 1: return "1 Immobilie"
        default: return "\(count) Immobilien"
        }
    }

    /// Leere Platzhalter sind keine Objektinformationen und sollen nicht vorgelesen werden.
    static func metadata(_ values: [String]) -> String {
        values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !["-", "–", "—"].contains($0) }
            .map { $0.replacingOccurrences(of: "m²", with: "Quadratmeter") }
            .joined(separator: ", ")
    }

    static func radiusValue(_ kilometers: Double) -> LocalizedStringKey {
        "\(Int(kilometers)) Kilometer"
    }

    static func favoriteAction(title: String, isFavorite: Bool) -> LocalizedStringKey {
        isFavorite ? "\(title) aus Favoriten entfernen" : "\(title) zu Favoriten hinzufügen"
    }

    static func favoriteState(_ isFavorite: Bool) -> LocalizedStringKey {
        isFavorite ? "Gespeichert" : "Nicht gespeichert"
    }

    /// Preise kommen als bereits formatierter Euro-Text aus den Repositories.
    /// Keine Interpretation von Kaufpreis, Monatsmiete oder Bildinhalten.
    static func price(_ raw: String) -> LocalizedStringKey {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return "Preis nicht angegeben" }
        if value.contains("€") {
            return "Preis: \(value.replacingOccurrences(of: "€", with: "Euro"))"
        }
        if value.contains(where: \.isNumber), !value.localizedCaseInsensitiveContains("EUR") {
            return "Preis: \(value) Euro"
        }
        return "Preis: \(value)"
    }

    static func propertyImage(title: String, hasImage: Bool) -> LocalizedStringKey {
        hasImage ? "Immobilienfoto zu: \(title)" : "Kein Immobilienfoto verfügbar"
    }

    static func detail(label: String, value: String) -> LocalizedStringKey {
        let spokenValue = value.replacingOccurrences(of: "m²", with: "Quadratmeter")
        return "\(label): \(spokenValue)"
    }

    static func selectionValue(_ value: String) -> LocalizedStringKey {
        switch value {
        case "", "Zimmer", "Stockwerk", "Bauform", "Energieklasse", "Heizungsart", "Egal", "Alle":
            return "Keine Einschränkung"
        case "EG":
            return "Erdgeschoss"
        case "6+":
            return "6 oder mehr"
        case "4+":
            return "4 oder höher"
        default:
            return "\(value)"
        }
    }
}
