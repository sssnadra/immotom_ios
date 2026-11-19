import SwiftUI

/// Favoriten-Screen.
///
/// Aktueller Stand:
/// - Favoriten sind nur als `[String]` modelliert (z.B. Titel/IDs).
/// - Es gibt noch keine Persistenz und keine Verbindung zu `Listing`.
struct FavoritesView: View {

    /// Demo-Favoritenliste.
    @State private var favorites: [String] = []

    /// Menü-State.
    @State private var showMenu = false

    /// Tab-Steuerung in der App-Shell
    @Binding var selectedTab: String

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {

                // Titelzeile
                Text("Favoriten")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.7, green: 0.85, blue: 0.3))

                if favorites.isEmpty {
                    // Empty State
                    VStack {
                        Spacer()

                        Image(systemName: "star.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.bottom, 10)

                        Text("Keine Favoriten gespeichert")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("Speichere interessante Inserate, um sie hier später schnell wiederzufinden.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                } else {
                    // Favoritenliste
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(favorites, id: \.self) { item in
                                favoriteRow(title: item)
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

            // SideMenu (nur sichtbar, wenn showMenu true ist)
            if showMenu {
                SideMenuView(isShowing: $showMenu, selectedTab: $selectedTab)
                    .transition(.move(edge: .trailing))
                    .zIndex(10)
            }
        }
    }

    /// Eine Zeile in der Favoritenliste.
    func favoriteRow(title: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.black)
                Text(title)
                Spacer()
            }
            .padding()
            .background(Color.white)
            Divider()
        }
    }
}

#Preview {
    FavoritesView(selectedTab: .constant("Favoriten"))
}
