import Foundation

/// Abstraktion für eine Inserat-Suche.
protocol ListingsRepository {

    /// Sucht Inserate anhand der gegebenen Filter.
    ///
    /// - Parameter filters: aktueller Filterzustand (Ort, Radius, Preis, Kategorie,…)
    /// - Returns: Liste von `Listing` für Ergebnisliste und Karte
    func search(filters: SearchFilters) async throws -> [Listing]
}
