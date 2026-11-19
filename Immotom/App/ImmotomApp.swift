import SwiftUI

/// App-Entry-Point.
/// Erstellt den zentralen DI-Container (`AppEnvironment`) und macht ihn als `EnvironmentObject` überall verfügbar.
@main
struct ImmotomApp: App {
    @StateObject private var env = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            AppScaffoldView()
                .environmentObject(env)
        }
    }
}
