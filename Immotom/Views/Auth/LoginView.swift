import SwiftUI
import AuthenticationServices

/// Login / Registrierung Screen.
///
/// - E-Mail Eingabe
/// - "Fortfahren mit E-Mail" Button (ToDo)
/// - "Mit Google fortfahren" Button (ToDo)
/// - Info-Liste, wofür ein Konto gut ist
struct LoginView: View {

    @State private var showMenu = false
    @State private var email: String = ""
    @State private var showsAppleSignInMessage = false
    @State private var appleSignInMessage = ""
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text("Registrieren oder Anmelden")
                        .font(.title3).bold()
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, 30)

                    // E-Mail Eingabe
                    VStack(alignment: .leading, spacing: 8) {
                        Text("E-Mail-Adresse").font(.subheadline)
                            .accessibilityHidden(true)

                        TextField("beispiel@email.com", text: $email)
                            .padding()
                            .background(Color(white: 0.9))
                            .cornerRadius(8)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .accessibilityLabel(VoiceOverLabels.email)
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
                    .accessibilityHint(VoiceOverLabels.unavailable)

                    Text("oder")
                        .accessibilityHidden(true)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)

                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        switch result {
                        case .success:
                            // Die Konto-Anbindung folgt zusammen mit den übrigen Login-Flows.
                            appleSignInMessage = "Die Anmeldung bei Immotom ist noch nicht verfügbar."
                        case .failure(let error):
                            if let authorizationError = error as? ASAuthorizationError,
                               authorizationError.code == .canceled {
                                return
                            }
                            appleSignInMessage = "Die Anmeldung mit Apple konnte nicht abgeschlossen werden."
                        }
                        showsAppleSignInMessage = true
                    }
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    // Google Continue
                    Button(action: {
                        // TODO: Google Sign-In
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .accessibilityHidden(true)
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
                    .accessibilityHint(VoiceOverLabels.unavailable)

                    // Info-Liste
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mit einem Konto kannst du").bold()
                            .accessibilityAddTraits(.isHeader)
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
        .alert("Apple-Anmeldung", isPresented: $showsAppleSignInMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(appleSignInMessage)
        }
    }
}

/// Kleine Bullet-Row für den Info-Block.
struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top) {
            Text("•").accessibilityHidden(true)
            Text(text).font(.footnote)
        }
    }
}

#Preview {
    LoginView()
}
