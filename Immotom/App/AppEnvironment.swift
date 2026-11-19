import Foundation
import Combine

/// Zentraler Dependency-Container für die App.
///
/// Wird in `ImmotomApp` als `@StateObject` erstellt und via `.environmentObject(env)` an die gesamte View-Hierarchie verteilt.
final class AppEnvironment: ObservableObject {

    // MARK: - Repositories (Demo)

    /// Liefert Inserate (Suche / Umkreissuche) aus lokalen Demo-Daten.
    let listingsRepository: any ListingsRepository = DemoListingsRepository()

    /// Liefert Detaildaten zu einem Inserat aus lokalen Demo-Daten.
    let listingsDetailRepository: any ListingsDetailRepository = DemoListingsDetailRepository()
}
