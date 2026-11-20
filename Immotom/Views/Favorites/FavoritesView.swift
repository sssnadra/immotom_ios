import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Environment(FavoritesStore.self) private var favorites
    @Binding var selectedTab: String

    @State private var listings: [Listing] = []
    @State private var isLoading = true
    @State private var didFail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Favoriten")
                        .font(.title2.bold())
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top)

                    if favorites.favoriteIDs.isEmpty {
                        ContentUnavailableView(
                            "Keine Favoriten gespeichert",
                            systemImage: "star",
                            description: Text("Tippe bei einer Immobilie auf den Stern, um sie hier wiederzufinden.")
                        )
                        Button {
                            selectedTab = "Suche"
                        } label: {
                            Text("Immobilien suchen")
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                    } else if isLoading {
                        ProgressView("Favoriten werden geladen")
                    } else if didFail {
                        ContentUnavailableView(
                            "Favoriten konnten nicht geladen werden",
                            systemImage: "exclamationmark.triangle",
                            description: Text("Deine gespeicherten Favoriten bleiben erhalten.")
                        )
                        Button {
                            Task { await loadFavorites() }
                        } label: {
                            Text("Erneut versuchen")
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                    } else if listings.isEmpty {
                        ContentUnavailableView(
                            "Inserate derzeit nicht verfügbar",
                            systemImage: "house",
                            description: Text("Deine Favoriten bleiben gespeichert.")
                        )
                    } else {
                        ForEach(listings) { listing in
                            ListingCardView(listing: listing)
                        }
                    }
                }
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
            .task(id: favorites.favoriteIDs) {
                await loadFavorites()
            }
        }
    }

    private func loadFavorites() async {
        let requestedIDs = favorites.favoriteIDs
        isLoading = true
        didFail = false
        do {
            let result = try await env.listingsRepository.listings(ids: requestedIDs)
            guard !Task.isCancelled, requestedIDs == favorites.favoriteIDs else { return }
            listings = result
            isLoading = false
        } catch {
            guard !Task.isCancelled, requestedIDs == favorites.favoriteIDs else { return }
            didFail = true
            isLoading = false
        }
    }
}

#Preview {
    FavoritesView(selectedTab: .constant("Favoriten"))
        .environmentObject(AppEnvironment())
        .environment(FavoritesStore())
}
