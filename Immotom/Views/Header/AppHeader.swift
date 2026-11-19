import SwiftUI

/// App-Header (Logo + Claim + optionaler Menü-Button).
///
/// Wird im `AppScaffoldView` oben fix angezeigt.
/// Der Menübutton ruft `onMenuTap()` auf, damit die Shell das SideMenu toggeln kann.
struct AppHeader: View {

    /// Ob rechts ein Menü-Button angezeigt werden soll.
    var showMenuButton: Bool = true

    /// Callback für Menu-Button.
    var onMenuTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {

                // App Logo
                Image("ic_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                // Titel + Untertitel
                VStack(alignment: .leading, spacing: 0) {
                    Text("Immotom").font(.headline).bold()
                    Text("Find Your Home").font(.caption)
                }
                .foregroundColor(.black)

                Spacer()

                // Optional: Menübutton
                if showMenuButton {
                    Button(action: {
                        onMenuTap()
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white.opacity(0.5), in: Circle())
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(Color(red: 0.7, green: 0.85, blue: 0.3))
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.1).ignoresSafeArea()

        VStack(spacing: 30) {
            AppHeader(showMenuButton: true, onMenuTap: {
                print("Menü wurde in der Vorschau getippt")
            })
            Spacer()
        }
    }
    .ignoresSafeArea(edges: .top)
}
