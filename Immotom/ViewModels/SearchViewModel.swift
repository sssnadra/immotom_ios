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

    private var requestID = UUID()
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
        let currentRequest = UUID()
        requestID = currentRequest
        state = .loading
        do {
            let results = try await repo.search(filters: filters)
            guard requestID == currentRequest, !Task.isCancelled else { return }
            state = .loaded(results)
        } catch {
            guard requestID == currentRequest else { return }
            if Task.isCancelled || error is CancellationError || (error as? URLError)?.code == .cancelled {
                state = .idle
                return
            }
            state = .failed(error.localizedDescription)
        }
    }
}

