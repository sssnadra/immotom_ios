import Foundation
import CoreLocation

/// Domain-Model für ein Inserat in der Ergebnisliste / Karte.
///
/// Enthält nur die Daten, die man in Cards/Markers sofort braucht.
/// Detaildaten kommen separat über `ListingDetail`.
struct Listing: Identifiable, Hashable {

    // MARK: - Identität
    let id: String

    // MARK: - Basisinfo
    let title: String
    let price: String

    /// Optionale Adresse.
    let address: String?

    // MARK: - Bild
    /// Optional: Remote-Bild.
    let imageURL: URL?

    /// Optional: Asset-Name für lokale Bilder.
    let imageName: String?

    // MARK: - Koordinaten
    let latitude: Double
    let longitude: Double

    /// Convenience für Map APIs.
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    /// Initializer nimmt `coordinate` entgegen und speichert intern als latitude/longitude.
    init(
        id: String,
        title: String,
        price: String,
        address: String? = nil,
        imageURL: URL? = nil,
        imageName: String? = nil,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.address = address
        self.imageURL = imageURL
        self.imageName = imageName
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

