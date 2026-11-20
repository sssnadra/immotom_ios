import Foundation
import Observation

/// Gemeinsamer Favoritenstatus und einmaliger Hinweis, vollständig lokal gespeichert.
@MainActor
@Observable
final class FavoritesStore {
    private(set) var favoriteIDs: Set<String>
    private(set) var launchCount: Int
    private(set) var shouldShowHint = false

    private let defaults: UserDefaults
    private var didRegisterLaunch = false

    private enum Keys {
        static let favorites = "favorites.listingIDs"
        static let launches = "favorites.launchCount"
        static let hintShown = "favorites.hintShown"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        favoriteIDs = Set(defaults.stringArray(forKey: Keys.favorites) ?? [])
        launchCount = defaults.integer(forKey: Keys.launches)
    }

    func contains(_ listingID: String) -> Bool {
        favoriteIDs.contains(listingID)
    }

    func toggle(_ listingID: String) {
        if !favoriteIDs.insert(listingID).inserted {
            favoriteIDs.remove(listingID)
        }
        defaults.set(favoriteIDs.sorted(), forKey: Keys.favorites)
    }

    /// Der Store lebt für den gesamten Prozess. View-Wechsel und Vordergrundwechsel
    /// dürfen keinen weiteren App-Start zählen.
    func registerLaunch() {
        guard !didRegisterLaunch else { return }
        didRegisterLaunch = true
        launchCount = min(max(launchCount, 0), 4) + 1
        defaults.set(launchCount, forKey: Keys.launches)
        shouldShowHint = launchCount >= 5 && !defaults.bool(forKey: Keys.hintShown)
    }

    /// Erst die tatsächliche Anzeige verbraucht den Hinweis, nicht das Starten der App.
    func markHintPresented() {
        guard shouldShowHint else { return }
        defaults.set(true, forKey: Keys.hintShown)
    }

    func dismissHint() {
        defaults.set(true, forKey: Keys.hintShown)
        shouldShowHint = false
    }
}
