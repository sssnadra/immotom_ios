import Foundation

/// Abstraktion zum Laden von Detaildaten eines Inserats.
protocol ListingsDetailRepository {

    /// Lädt Detailinformationen zu einem Inserat.
    ///
    /// - Parameter id: eindeutige Inserat-ID
    /// - Returns: `ListingDetail` für die Detailseite
    func fetchDetail(id: String) async throws -> ListingDetail
}
