import SwiftUI
import CoreLocation

/// Detailnavigation und Favoritenbutton sind getrennte, zugängliche Aktionen.
struct ListingCardView: View {
    let listing: Listing
    var showsFavoriteTip = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink {
                ObjectDetailView(listingID: listing.id)
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    listingImage
                        .aspectRatio(1.5, contentMode: .fill)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(listing.title)
                            .font(.headline)
                        Text(listing.address ?? "Keine Adresse verfügbar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(listing.price) €")
                            .font(.headline)
                            .accessibilityLabel(VoiceOverLabels.price(listing.price))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .foregroundStyle(.black)
                            .background(Color(red: 0.7, green: 0.85, blue: 0.3), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .foregroundStyle(.primary)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .contentShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(VoiceOverLabels.openDetails)

            FavoriteButton(
                listingID: listing.id,
                listingTitle: listing.title,
                showsTip: showsFavoriteTip
            )
                .padding(12)
        }
        .accessibilityElement(children: .contain)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var listingImage: some View {
        if let imageName = listing.imageName {
            Image(imageName).resizable()
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
}

#Preview {
    NavigationStack {
        ListingCardView(listing: Listing(
            id: "preview_house",
            title: "Moderne Villa mit Pool",
            price: "850.000",
            address: "Musterstraße 1, 12345 Musterstadt",
            imageName: "house3",
            coordinate: CLLocationCoordinate2D(latitude: 48.21, longitude: 16.37)
        ))
    }
    .environment(FavoritesStore())
}
