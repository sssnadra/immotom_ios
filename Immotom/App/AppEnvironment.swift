import Foundation
import Combine

/// Shared repositories. Demo data must be selected explicitly, never as an error fallback.
final class AppEnvironment: ObservableObject {
    let listingsRepository: any ListingsRepository
    let listingsDetailRepository: any ListingsDetailRepository
    let usesDemoData: Bool

    init(
        useDemoData: Bool = ProcessInfo.processInfo.arguments.contains("-immotom-demo")
            || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
        client: BackendClient = BackendClient()
    ) {
        usesDemoData = useDemoData
        if useDemoData {
            listingsRepository = DemoListingsRepository()
            listingsDetailRepository = DemoListingsDetailRepository()
        } else {
            listingsRepository = BackendListingsRepository(client: client)
            listingsDetailRepository = BackendListingsDetailRepository(client: client)
        }
    }
}
