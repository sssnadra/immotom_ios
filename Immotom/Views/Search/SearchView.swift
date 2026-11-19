import SwiftUI

/// Screen: Suchergebnisse als Liste.
///
/// - `filters` kommen von AppScaffold
/// - ViewModel wird als `@StateObject` gehalten
/// - In `.task` werden Dependencies aus `AppEnvironment` injected und initial gesucht
struct SearchView: View {
    @EnvironmentObject private var env: AppEnvironment

    @Binding var filters: SearchFilters
    @Binding var selectedTab: String

    @State private var showMenu = false
    @State private var isShowingFilters = false

    /// Default-Repo ist Demo, wird aber in `.task` durch `env.listingsRepository` ersetzt.
    @StateObject private var vm = SearchViewModel(repo: DemoListingsRepository())

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Searchbar (aktuell nur TextField)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Suche nach Stadt, PLZ oder Adresse", text: $filters.locationText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(25)
                .padding(.horizontal)
                .padding(.bottom, 10)

                // Content abhängig vom Ladezustand
                content
            }
        }
        .navigationBarHidden(true)

        // Initiales Laden
        .task {
            // VM übernimmt die aktuellen Filter von außen
            vm.filters = filters

            // Repo kommt zentral aus dem Environment
            vm.update(repo: env.listingsRepository)

            // Suche starten
            await vm.search()
        }

        // Filter-Sheet
        .sheet(isPresented: $isShowingFilters) {
            FiltersView(filters: $filters, onApply: {
                isShowingFilters = false

                // Nach Apply erneut suchen
                Task { await vm.search() }
            })
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let listings):
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("\(listings.count) von \(listings.count) Immobilien")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(listings) { listing in
                            NavigationLink {
                                ObjectDetailView(listingID: listing.id)
                            } label: {
                                ListingCardView(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer().frame(height: 90) // Platz für Floating Buttons
                    }
                    .padding(.top, 8)
                }
            }

        case .failed(let msg):
            VStack(spacing: 12) {
                Text("Fehler beim Laden")
                    .font(.headline)
                Text(msg)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .idle:
            EmptyView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
