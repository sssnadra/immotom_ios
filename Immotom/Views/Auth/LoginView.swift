import SwiftUI

/// Login / Registrierung Screen.
///
/// - E-Mail Eingabe
/// - "Fortfahren mit E-Mail" Button (ToDo)
/// - "Mit Google fortfahren" Button (ToDo)
/// - Info-Liste, wofür ein Konto gut ist
struct LoginView: View {

    @State private var showMenu = false
    @State private var email: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text("Registrieren oder Anmelden")
                        .font(.title3).bold()
                        .padding(.top, 30)

                    // E-Mail Eingabe
                    VStack(alignment: .leading, spacing: 8) {
                        Text("E-Mail-Adresse").font(.subheadline)

                        TextField("beispiel@email.com", text: $email)
                            .padding()
                            .background(Color(white: 0.9))
                            .cornerRadius(8)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }

                    // Email Continue
                    Button(action: {
                        // TODO: Login/Signup Flow
                    }) {
                        Text("Fortfahren mit E-Mail")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.7, green: 0.85, blue: 0.3))
                            .cornerRadius(8)
                    }

                    Text("oder")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)

                    // Google Continue
                    Button(action: {
                        // TODO: Google Sign-In
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Mit Google fortfahren")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    }

                    // Info-Liste
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mit einem Konto kannst du").bold()
                        BulletPoint(text: "Suchagenten erstellen")
                        BulletPoint(text: "Lieblingsimmobilien speichern")
                        BulletPoint(text: "Mit Anbietern ganz einfach in Kontakt treten")
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 25)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Kleine Bullet-Row für den Info-Block.
struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text).font(.footnote)
        }
    }
}

#Preview {
    LoginView()
}
