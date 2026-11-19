import Foundation

/// Generischer Ladezustand für asynchrone Operationen.
///
/// - UI kann sauber nach Zuständen rendern (Progress / Content / Error)
/// - funktioniert für jeden Datentyp (`Loadable<T>`)
enum Loadable<T> {
    /// Noch nichts gestartet.
    case idle

    /// Request läuft.
    case loading

    /// Erfolgreich geladen.
    case loaded(T)

    /// Fehlgeschlagen, mit UI-tauglicher Fehlermeldung.
    case failed(String)

    /// Convenience: liefert den geladenen Wert, falls vorhanden.
    var value: T? {
        if case .loaded(let v) = self { return v }
        return nil
    }

    /// Convenience: `true`, wenn gerade geladen wird.
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

