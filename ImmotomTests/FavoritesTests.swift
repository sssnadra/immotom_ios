import Foundation
import Testing
@testable import Immotom

@MainActor
struct FavoritesTests {
    private func withDefaults(_ test: (UserDefaults) throws -> Void) throws {
        let suiteName = "FavoritesTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try test(defaults)
    }

    @Test func favoritesSurviveRestartAndRemoval() throws {
        try withDefaults { defaults in
            let store = FavoritesStore(defaults: defaults)
            store.toggle("1")
            store.toggle("2")

            let restarted = FavoritesStore(defaults: defaults)
            #expect(restarted.favoriteIDs == ["1", "2"])
            restarted.toggle("1")

            let restartedAgain = FavoritesStore(defaults: defaults)
            #expect(restartedAgain.favoriteIDs == ["2"])
        }
    }

    @Test func hintAppearsOnFifthLaunchAndOnlyOnce() throws {
        try withDefaults { defaults in
            for expectedCount in 1...4 {
                let store = FavoritesStore(defaults: defaults)
                store.registerLaunch()
                #expect(store.launchCount == expectedCount)
                #expect(!store.shouldShowHint)
            }

            let fifthLaunch = FavoritesStore(defaults: defaults)
            fifthLaunch.registerLaunch()
            #expect(fifthLaunch.shouldShowHint)
            fifthLaunch.markHintPresented()
            #expect(fifthLaunch.shouldShowHint)
            fifthLaunch.dismissHint()
            #expect(!fifthLaunch.shouldShowHint)

            let sixthLaunch = FavoritesStore(defaults: defaults)
            sixthLaunch.registerLaunch()
            #expect(!sixthLaunch.shouldShowHint)
        }
    }

    @Test func repeatedViewTasksDoNotCountAsLaunches() throws {
        try withDefaults { defaults in
            let store = FavoritesStore(defaults: defaults)
            for _ in 1...10 {
                store.registerLaunch()
            }
            #expect(store.launchCount == 1)
            #expect(!store.shouldShowHint)
        }
    }

    @Test func unseenHintRemainsAvailableAfterFifthLaunch() throws {
        try withDefaults { defaults in
            for _ in 1...5 {
                FavoritesStore(defaults: defaults).registerLaunch()
            }
            let nextLaunch = FavoritesStore(defaults: defaults)
            nextLaunch.registerLaunch()
            #expect(nextLaunch.shouldShowHint)
            nextLaunch.markHintPresented()

            // Auch ohne X darf eine bereits angezeigte Karte nach Neustart nicht wiederkommen.
            let afterPresentation = FavoritesStore(defaults: defaults)
            afterPresentation.registerLaunch()
            #expect(!afterPresentation.shouldShowHint)
        }
    }

    @Test func favoriteLookupIsIndependentOfSearchFilters() async throws {
        let repository = DemoListingsRepository()
        let listings = try await repository.listings(ids: ["1", "3", "missing"])
        #expect(Set(listings.map(\.id)) == ["1", "3"])
        let empty = try await repository.listings(ids: [])
        #expect(empty.isEmpty)
    }
}
