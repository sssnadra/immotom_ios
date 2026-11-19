import Foundation
import Combine

/// ViewModel für die Objekt-Detailansicht.
///
/// - Hält den UI-Ladezustand (`Loadable<ListingDetail>`)
/// - Lädt Detaildaten über ein `ListingsDetailRepository`
/// - Arbeitet anhand einer fixen Objekt-ID (`id`)
@MainActor
final class DetailViewModel: ObservableObject {

    // MARK: - Published State

    /// UI-State für die Detaildaten:
    /// - `.idle`    : noch nicht geladen
    /// - `.loading` : Request läuft
    /// - `.loaded`  : Detaildaten vorhanden
    /// - `.failed`  : Fehlertext anzeigen
    @Published private(set) var state: Loadable<ListingDetail> = .idle

    // MARK: - Dependencies / Parameters

    /// Repository, das die Detaildaten liefert (Demo oder Backend).
    private var repo: ListingsDetailRepository

    /// ID des Inserats, für das Details geladen werden.
    private let id: String

    // MARK: - Init

    init(id: String, repo: ListingsDetailRepository) {
        self.id = id
        self.repo = repo
    }

    // MARK: - DI Update

    /// Erlaubt, das Repository nachträglich auszutauschen (z.B. Demo → Real), ohne das ViewModel neu zu erstellen.
    func update(repo: ListingsDetailRepository) {
        self.repo = repo
    }

    // MARK: - Loading

    /// Lädt die Detaildaten und aktualisiert den UI-State.
    func load() async {
        state = .loading
        do {
            let detail = try await repo.fetchDetail(id: id)
            state = .loaded(detail)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
