import Foundation
import Combine

/// ViewModel für die Ergebnisliste (Search Screen).
///
/// - `filters`: UI bindet hier dran
/// - `state`: UI rendert anhand von Loading/Loaded/Failed
@MainActor
final class SearchViewModel: ObservableObject {

    /// Aktuelle Filter (z.B. Radius, Kategorie, Preis etc.)
    @Published var filters: SearchFilters = .default

    /// Ladezustand der Suche.
    @Published private(set) var state: Loadable<[Listing]> = .idle

    private var repo: ListingsRepository

    init(repo: ListingsRepository) {
        self.repo = repo
    }

    /// Erlaubt Dependency-Austausch (z.B. von Demo → real), ohne dass das ViewModel neu erstellt werden muss.
    func update(repo: ListingsRepository) {
        self.repo = repo
    }

    /// Führt die Suche aus und aktualisiert den UI-State.
    func search() async {
        state = .loading
        do {
            let results = try await repo.search(filters: filters)
            state = .loaded(results)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

