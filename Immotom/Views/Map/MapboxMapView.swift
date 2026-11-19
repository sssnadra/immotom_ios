import SwiftUI
import MapboxMaps
import Turf

/// SwiftUI-Wrapper um eine Mapbox `MapView`.
///
/// Bindings:
/// - `centerCoordinate`: Mittelpunkt der Karte (ändert Kamera + Kreis)
/// - `distance`: Radius in km (ändert Kreis)
/// - `listings`: Inserate, die als Marker angezeigt werden
struct MapboxMapView: UIViewControllerRepresentable {

    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var distance: Double
    var listings: [Listing]

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        let mapInitOptions = MapInitOptions()
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Initiale Kamera
        mapView.mapboxMap.setCamera(to: CameraOptions(center: centerCoordinate, zoom: 11))

        viewController.view = mapView
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let mapView = uiViewController.view as? MapView else { return }

        // Kamera nachziehen, wenn Zentrum geändert wurde
        mapView.mapboxMap.setCamera(to: CameraOptions(center: centerCoordinate))

        // Kreis + Marker aktualisieren
        updateRadiusCircle(on: mapView)
        updateAnnotationsIfNeeded(on: mapView)
    }

    // MARK: - Radius Circle

    /// Zeichnet/aktualisiert einen Kreis als Fill-Layer.
    private func updateRadiusCircle(on mapView: MapView) {
        let sourceId = "radius-source"
        let layerId = "radius-layer"

        // Polygon aus "Circle"
        let circlePolygon = Polygon.fromCircle(center: centerCoordinate, radius: distance)
        let geoJSON = Feature(geometry: circlePolygon)

        if mapView.mapboxMap.sourceExists(withId: sourceId) {
            // Quelle existiert → Daten aktualisieren
            try? mapView.mapboxMap.updateGeoJSONSource(withId: sourceId, data: .feature(geoJSON))
        } else {
            // Quelle + Layer einmalig hinzufügen
            var source = GeoJSONSource(id: sourceId)
            source.data = .feature(geoJSON)
            try? mapView.mapboxMap.addSource(source)

            var layer = FillLayer(id: layerId, source: sourceId)
            layer.fillColor = .constant(StyleColor(UIColor.systemGreen.withAlphaComponent(0.3)))
            layer.fillOutlineColor = .constant(StyleColor(UIColor.systemGreen))
            try? mapView.mapboxMap.addLayer(layer)
        }
    }

    // MARK: - Annotations (Pins)

    /// Setzt Marker für Listings.
    private func updateAnnotationsIfNeeded(on mapView: MapView) {
        let annotationManager = mapView.annotations.makePointAnnotationManager()

        if annotationManager.annotations.count != listings.count {
            annotationManager.annotations = listings.map { item in
                PointAnnotation(coordinate: item.coordinate)
            }
        }
    }
}

/// Erweiterung: Erzeugt ein Turf-Polygon, das einen Kreis approximiert.
extension Polygon {

    /// Approximiert einen Kreis um `center` mit Radius `radius` (in km) über 64 Punkte.
    static func fromCircle(center: CLLocationCoordinate2D, radius: Double) -> Polygon {
        let vertices = 64
        var coordinates = [CLLocationCoordinate2D]()

        // km → Radiant (Erd-Radius ~ 6371 km)
        let distanceRadians = radius / 6371.0

        let centerLatRad = center.latitude * .pi / 180.0
        let centerLonRad = center.longitude * .pi / 180.0

        for i in 0..<vertices {
            // Bearing rund um den Kreis
            let bearing = 2.0 * .pi * Double(i) / Double(vertices)

            // Großer Kreis
            let latRad = asin(
                sin(centerLatRad) * cos(distanceRadians) +
                cos(centerLatRad) * sin(distanceRadians) * cos(bearing)
            )

            let lonRad = centerLonRad + atan2(
                sin(bearing) * sin(distanceRadians) * cos(centerLatRad),
                cos(distanceRadians) - sin(centerLatRad) * sin(latRad)
            )

            coordinates.append(
                CLLocationCoordinate2D(
                    latitude: latRad * 180.0 / .pi,
                    longitude: lonRad * 180.0 / .pi
                )
            )
        }

        // Polygon schließen
        coordinates.append(coordinates[0])
        return Polygon([coordinates])
    }
}

