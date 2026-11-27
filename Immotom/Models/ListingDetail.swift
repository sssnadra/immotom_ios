import Foundation
import CoreLocation

/// Domain-Model für die Detailansicht eines Inserats.
///
/// Enthält mehr Felder als `Listing` (Listenmodell),
struct ListingDetail: Identifiable {

    // MARK: - Identität / Header

    let id: String
    let title: String
    let price: String

    // MARK: - Adresse

    /// Straße/Hausnummer
    let street: String

    /// PLZ + Ort
    let zipCity: String

    // MARK: - Meta-Kacheln

    let metaLeft: String
    let metaMid: String
    let metaRight: String

    // MARK: - Bild

    /// Optional: Remote-URL (in Demo oft nil)
    let imageURL: URL?

    /// Optional: lokaler Asset-Name (z.B. "house1")
    let imageName: String?

    /// Preview first, followed by the remaining unique remote images.
    var imageURLs: [URL] = []

    // MARK: - Objektinformation

    let infoTitle: String

    /// Liste aus (Label, Wert) – z.B. ("Zimmer", "5")
    let infoPairs: [(String, String)]

    // MARK: - Beschreibung

    let descriptionTitle: String
    let description: String

    // MARK: - Kontaktblock

    let contactTitle: String
    let contactCompany: String
    let contactPerson: String
    let contactStreet: String
    let contactCity: String
    let contactEmail: String
    let contactPhone: String

    // MARK: - Location

    let latitude: Double
    let longitude: Double

    /// Convenience für Maps.
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}

