import Foundation

/// Geografische Hilfsfunktionen.
enum Geo {

    /// Berechnet die Distanz zwischen zwei Koordinaten.
    ///
    /// - Parameters:
    ///   - fromLat/fromLon: Startpunkt (Breite/Länge)
    ///   - toLat/toLon: Zielpunkt (Breite/Länge)
    /// - Returns: Distanz in Kilometern
    static func distanceKm(fromLat: Double, fromLon: Double, toLat: Double, toLon: Double) -> Double {
        let earthRadiusKm = 6371.0

        // Grad → Radiant
        let dLat = (toLat - fromLat) * .pi / 180
        let dLon = (toLon - fromLon) * .pi / 180

        let fromLatRad = fromLat * .pi / 180
        let toLatRad = toLat * .pi / 180

        // Haversine-Formel
        let a = sin(dLat / 2) * sin(dLat / 2)
              + cos(fromLatRad) * cos(toLatRad)
              * sin(dLon / 2) * sin(dLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusKm * c
    }
}
