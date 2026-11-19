import Foundation
import CoreLocation
import Combine

/// ViewModel für die Kartenansicht.
///
/// - Verwaltet Filterzustand (`SearchFilters`)
/// - Lädt Inserate über `ListingsRepository` (Demo/Real)
/// - Hält einen Ladezustand (`Loadable<[Listing]>`) für die UI
/// - Erzeugt Demo-POIs rund um das aktuelle Zentrum
///
/// POI funktionieren nicht so, wie ich das möchte
/// ToDo
@MainActor
final class MapViewModel: ObservableObject {

    // MARK: - Published State

    /// Filter (Zentrum, Radius, Text etc.) – gebunden an UI (Slider, TextField …)
    @Published var filters: SearchFilters = .default

    /// Ladezustand für die Ergebnisliste (Pins) auf der Karte.
    @Published private(set) var state: Loadable<[Listing]> = .idle

    /// Demo-POIs (Supermarkt, Schule, …) rund um das Zentrum.
    @Published private(set) var pois: [POI] = []

    // MARK: - Dependencies

    private var repo: ListingsRepository

    // MARK: - Init

    init(repo: ListingsRepository) {
        self.repo = repo

        // initial POIs anhand Default-Zentrum
        self.pois = Self.demoPOIs(near: filters.center)
    }

    /// Austausch von Abhängigkeiten, z.B. wenn `AppEnvironment` ein anderes Repo liefert.
    func updateDeps(repo: ListingsRepository) {
        self.repo = repo
    }

    // MARK: - Demo-Zentrum

    /// Demo-Version: Keine Permissions und keine Geräte-Location.
    ///
    /// Setzt das Zentrum auf den Default und regeneriert POIs.
    func useDefaultCenter() {
        filters.center = SearchFilters.default.center
        pois = Self.demoPOIs(near: filters.center)
    }

    // MARK: - Loading

    /// Lädt Inserate anhand der aktuellen Filter und aktualisiert den UI-State.
    func refresh() async {
        state = .loading
        do {
            let results = try await repo.search(filters: filters)
            state = .loaded(results)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    // MARK: - Demo POIs

    /// Erstellt fix definierte POIs rund um den Mittelpunkt.
    private static func demoPOIs(near center: CLLocationCoordinate2D) -> [POI] {
        [
            POI(
                title: "Supermarkt",
                subtitle: "5 min",
                category: "shopping",
                coordinate: .init(
                    latitude: center.latitude + 0.006,
                    longitude: center.longitude + 0.004
                )
            ),
            POI(
                title: "Schule",
                subtitle: "10 min",
                category: "education",
                coordinate: .init(
                    latitude: center.latitude - 0.004,
                    longitude: center.longitude + 0.007
                )
            ),
            POI(
                title: "Restaurant",
                subtitle: "7 min",
                category: "food",
                coordinate: .init(
                    latitude: center.latitude + 0.003,
                    longitude: center.longitude - 0.006
                )
            ),
            POI(
                title: "ÖPNV Haltestelle",
                subtitle: "2 min",
                category: "transport",
                coordinate: .init(
                    latitude: center.latitude - 0.002,
                    longitude: center.longitude - 0.003
                )
            )
        ]
    }
}
