import SwiftUI

/// Einzelnes Menü-Element im SideMenu.
struct SideMenuOption: View {
    let title: String
    let icon: String
    let tab: String
    @Binding var selectedTab: String
    @Binding var isShowing: Bool

    var body: some View {
        Button(action: {
            selectedTab = tab
            isShowing = false
        }) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 25)
                Text(title)
                Spacer()
            }
            .padding()
            .background(Color(white: 0.9))
            .foregroundColor(.black)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
        }
    }
}

/// SideMenu (Slide-In rechts).
///
/// Parameter:
/// - `isShowing`: steuert Ein-/Ausblenden
/// - `selectedTab`: bestimmt den aktiven Screen in `AppScaffoldView`
struct SideMenuView: View {
    @Binding var isShowing: Bool
    @Binding var selectedTab: String

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {

                // MARK: - Header im Menü
                VStack {
                    HStack {
                        Image("ic_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .background(Color.white.cornerRadius(10))

                        VStack(alignment: .leading) {
                            Text("Immotom").font(.title3).bold()
                            Text("Find Your Home").font(.caption)
                        }

                        Spacer()

                        // Close Button
                        Button(action: { isShowing = false }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 60)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .background(Color(red: 0.65, green: 0.82, blue: 0.25))

                // MARK: - Menu Items
                VStack(spacing: 15) {
                    SideMenuOption(title: "Home", icon: "line.3.horizontal.decrease", tab: "Start", selectedTab: $selectedTab, isShowing: $isShowing)
                    SideMenuOption(title: "Listensuchen", icon: "magnifyingglass", tab: "Suche", selectedTab: $selectedTab, isShowing: $isShowing)
                    SideMenuOption(title: "Favoriten", icon: "star", tab: "Favoriten", selectedTab: $selectedTab, isShowing: $isShowing)
                    SideMenuOption(title: "Anmelden", icon: "person", tab: "Login", selectedTab: $selectedTab, isShowing: $isShowing)

                    Spacer()
                }
                .padding()
                .background(Color.white)
            }
            .frame(width: 300)
            .edgesIgnoringSafeArea(.all)
        }

        // Hintergrundoverlay: Tap schließt Menü
        .background(Color.black.opacity(0.3).onTapGesture { isShowing = false })
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(
            isShowing: .constant(true),
            selectedTab: .constant("Start")
        )
        .previewDevice("iPhone 17 Pro")
    }
}
