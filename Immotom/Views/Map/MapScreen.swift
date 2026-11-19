import SwiftUI
import CoreLocation

/// Screen: Umkreissuche auf der Karte.
///
/// Aufbau:
/// - Hintergrund: MapboxMapView (zeigt Kreis + Pins)
/// - Overlay oben: Suchfeld + Radius Slider
/// - Overlay unten: Buttons (Liste / Filter)
struct MapScreen: View {
    @EnvironmentObject private var env: AppEnvironment

    /// ViewModel: wird einmal erstellt und behält seinen Zustand
    @StateObject private var vm = MapViewModel(repo: DemoListingsRepository())

    /// Filter-Sheet anzeigen
    @State private var isShowingFilters = false

    /// Tab-Steuerung in der App-Shell
    @Binding var selectedTab: String

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                // MARK: - Karte
                MapboxMapView(
                    centerCoordinate: $vm.filters.center,
                    distance: $vm.filters.radiusKm,
                    listings: vm.state.value ?? []
                )
                .ignoresSafeArea(edges: .top)

                // MARK: - Overlay
                VStack(spacing: 0) {
                    headerArea
                    Spacer()
                    floatingControls
                }
            }
            .navigationBarHidden(true)

            // MARK: - Initial Setup / Loading
            .task {
                // Default Filter setzen (Demo)
                vm.filters = .default

                // Repo aus Environment übernehmen
                vm.updateDeps(repo: env.listingsRepository)

                // Initiale Inserate laden
                await vm.refresh()
            }
        }
    }

    // MARK: - Header Overlay (Suche + Radius)

    private var headerArea: some View {
        VStack(spacing: 12) {

            VStack(spacing: 15) {

                // Suchfeld
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Stadt, PLZ oder Adresse", text: $vm.filters.locationText)
                        .submitLabel(.search)
                        .onSubmit { Task { await vm.refresh() } }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5)

                // Radius
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Suchradius:").font(.subheadline).bold()
                        Text("\(Int(vm.filters.radiusKm)) km").font(.subheadline)
                    }
                    Slider(value: $vm.filters.radiusKm, in: 1...50, step: 1)
                        .tint(Color(red: 0.6, green: 0.8, blue: 0.2))
                }
                .padding(.horizontal, 8)
            }
            .padding()
            .background(Color.white.opacity(0.95))
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }

    // MARK: - Bottom Controls

    private var floatingControls: some View {
        HStack(spacing: 15) {

            // Wechsel in die Listenansicht
            actionPill(title: "Liste", icon: "list.bullet") {
                selectedTab = "Suche"
            }

            // Filter-Sheet
            actionPill(title: "Filter", icon: "line.3.horizontal.decrease") {
                isShowingFilters = true
            }
        }
        .padding(.bottom, 30)
        .sheet(isPresented: $isShowingFilters) {
            FiltersView(filters: $vm.filters, onApply: {
                isShowingFilters = false
                Task { await vm.refresh() }
            })
        }
    }

    /// Pill-Button Styling
    private func actionPill(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.bold())
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color(red: 0.6, green: 0.8, blue: 0.2))
            .foregroundColor(.black)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    NavigationStack {
        MapScreen(selectedTab: .constant("Karte"))
    }
    .environmentObject(AppEnvironment())
}
