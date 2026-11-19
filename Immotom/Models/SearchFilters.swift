import Foundation
import CoreLocation

/// Bündelt alle Filterparameter für Suche & Umkreissuche.
struct SearchFilters: Hashable {

    // MARK: - Ort / Radius

    /// Text-Eingabe für den Ort (z.B. "Linz", "1010 Wien").
    var locationText: String

    /// Mittelpunkt der Umkreissuche.
    var centerLatitude: Double
    var centerLongitude: Double

    /// Convenience-Coordinate für Maps/Location APIs.
    var center: CLLocationCoordinate2D {
        get { .init(latitude: centerLatitude, longitude: centerLongitude) }
        set {
            centerLatitude = newValue.latitude
            centerLongitude = newValue.longitude
        }
    }

    /// Umkreis-Radius in Kilometern.
    var radiusKm: Double

    // MARK: - Preis / Kategorie

    /// Preisfilter
    var minPrice: Int?
    var maxPrice: Int?

    /// Kategorie
    var category: String

    /// Mieten oder Kaufen.
    var rentBuy: String

    // MARK: - Detailfilter

    var minArea: Int?
    var maxArea: Int?
    var rooms: String
    var floor: String

    var hasBalkony: String
    var hasElevator: String
    var hasCellar: String

    var heatingType: String
    var buildingType: String

    var isFurnished: String
    var energyClass: String
    var petsAllowed: String
    var isAccessible: String

    // MARK: - Default

    /// Default-Filterzustand beim App-Start.
    /// Zentrum ist Linz (Koordinaten fix vorbelegt).
    static let `default` = SearchFilters(
        locationText: "Linz",
        centerLatitude: 48.3069,
        centerLongitude: 14.2858,
        radiusKm: 5,

        minPrice: nil,
        maxPrice: nil,
        category: "Alle",
        rentBuy: "Mieten",

        minArea: nil,
        maxArea: nil,
        rooms: "Zimmer",
        floor: "Stockwerk",
        hasBalkony: "Egal",
        hasElevator: "Egal",
        hasCellar: "Egal",
        heatingType: "Heizungsart",
        buildingType: "Bauform",
        isFurnished: "Egal",
        energyClass: "Energieklasse",
        petsAllowed: "Egal",
        isAccessible: "Egal"
    )
}

