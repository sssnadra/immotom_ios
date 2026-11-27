import SwiftUI

/// Root-Layout der App (Header + Content + SideMenu).
///
/// - Hält den globalen "Tab" / Screen-State (`selectedTab`)
/// - Hält den globalen Filterzustand (`filters`), sodass Start/Suche
///   konsistent denselben Filterzustand verwenden können
/// - Zeigt das Slide-In Menü (Overlay) über `isMenuShowing`
struct AppScaffoldView: View {

    /// Welcher Screen ist gerade aktiv.
    @State private var selectedTab: String = "Start"

    /// Öffnet/schließt das Side-Menü.
    @State private var isMenuShowing: Bool = false

    /// Zentraler Filterzustand.
    @State private var filters: SearchFilters = .default

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                // Fixer App-Header
                AppHeader(showMenuButton: true, onMenuTap: {
                    isMenuShowing.toggle()
                })
                .background(
                    // Header-Farbe + SafeArea Top ignorieren, um Designprobleme zu beheben
                    Color(red: 0.7, green: 0.85, blue: 0.3)
                        .ignoresSafeArea(edges: .top)
                )

                // Aktueller Screen
                Group {
                    switch selectedTab {
                    case "Start":
                        StartView(filters: $filters, selectedTab: $selectedTab)
                    case "Suche":
                        SearchView(filters: $filters, selectedTab: $selectedTab)
                    case "Favoriten":
                        FavoritesView(selectedTab: $selectedTab)
                    case "Login":
                        LoginView()
                    default:
                        // Fallback: Start
                        StartView(filters: $filters, selectedTab: $selectedTab)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Wenn Menü offen ist, werden Interaktionen im Hintergrund deaktiviert.
            .disabled(isMenuShowing)
            .accessibilityHidden(isMenuShowing)

            // Menü + dunkles Overlay
            if isMenuShowing {
                // Overlay: Klick schließt Menü
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { isMenuShowing = false }
                    .accessibilityHidden(true)
                    .zIndex(9)

                // Menü selbst
                SideMenuView(isShowing: $isMenuShowing, selectedTab: $selectedTab)
                    .transition(.move(edge: .trailing))
                    .zIndex(10)
            }
        }

        // Animation für Menü ein/aus
        .animation(.easeInOut, value: isMenuShowing)
    }
}
