import Foundation
import CoreLocation

/// Point of Interest (POI) für die Kartenansicht.
///
/// Wird z.B. verwendet um zusätzliche Marker in der Nähe anzuzeigen
/// Funktioniert noch nicht so, wie ich das möchte
struct POI: Identifiable, Hashable {

    // MARK: - Identität

    let id: UUID

    // MARK: - Inhalt

    let title: String
    let subtitle: String?
    let category: String?

    // MARK: - Koordinaten

    let latitude: Double
    let longitude: Double

    /// Convenience-Koordinate für Map APIs.
    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String? = nil,
        category: String? = nil,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

