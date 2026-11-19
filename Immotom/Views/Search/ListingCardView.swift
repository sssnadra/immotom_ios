import SwiftUI
import CoreLocation

/// Card-UI für ein Inserat in der Ergebnisliste.
///
/// - Zeigt Bild (Asset oder Remote URL)
/// - Zeigt Titel, Adresse, Preis
/// - Stern-Button als Favoriten-UI (Logik aktuell noch leer)
struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Bildbereich + Favoritenbutton
            ZStack(alignment: .topTrailing) {

                // Bild: Asset -> Remote -> Placeholder
                Group {
                    if let imageName = listing.imageName {
                        Image(imageName)
                            .resizable()
                    } else if let url = listing.imageURL {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                    } else {
                        Rectangle().fill(Color.gray.opacity(0.2))
                    }
                }
                .aspectRatio(1.5, contentMode: .fill)
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipped()

                // Favoritenbutton
                Button(action: {
                    // TODO: Favoritenlogik
                }) {
                    Image(systemName: "star")
                        .padding(8)
                        .background(.white.opacity(0.8))
                        .clipShape(Circle())
                        .padding(12)
                }
            }

            // MARK: - Textbereich
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(listing.address ?? "Keine Adresse verfügbar")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Text("Details folgen")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(listing.price)€")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.7, green: 0.85, blue: 0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color.white)
        }
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

#Preview {
    ListingCardView(listing: Listing(
        id: "preview_house",
        title: "Moderne Villa mit Pool",
        price: "850.000",
        address: "Musterstraße 1, 12345 Musterstadt",
        imageName: "house3",
        coordinate: CLLocationCoordinate2D(latitude: 48.21, longitude: 16.37)
    ))
}

