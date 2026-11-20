import SwiftUI
import TipKit

/// App-Entry-Point.
/// Erstellt den zentralen DI-Container (`AppEnvironment`) und macht ihn als `EnvironmentObject` überall verfügbar.
@main
struct ImmotomApp: App {
    @StateObject private var env = AppEnvironment()
    @State private var favorites = FavoritesStore()

    init() {
        do {
            try Tips.configure()
        } catch {
            // Die Favoritenfunktion bleibt auch ohne verfügbare TipKit-Datenbank nutzbar.
            print("TipKit konnte nicht initialisiert werden: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppScaffoldView()
                .environmentObject(env)
                .environment(favorites)
                .task {
                    favorites.registerLaunch()
                }
        }
    }
}
