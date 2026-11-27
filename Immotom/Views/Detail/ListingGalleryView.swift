import SwiftUI

/// Shared image rendering with explicit loading, missing-image and error states.
struct ListingPhotoView: View {
    let url: URL?
    var imageName: String? = nil
    var contentMode: ContentMode = .fill

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                } else if let url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: contentMode)
                        case .failure:
                            photoPlaceholder("Bild konnte nicht geladen werden")
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        @unknown default:
                            photoPlaceholder("Bild nicht verfügbar")
                        }
                    }
                } else {
                    photoPlaceholder("Kein Bild vorhanden")
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .background(Color.secondary.opacity(0.15))
    }

    private func photoPlaceholder(_ title: LocalizedStringKey) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "photo").font(.largeTitle)
            Text(title).font(.caption).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ListingGalleryView: View {
    let urls: [URL]
    let imageName: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if urls.isEmpty {
                    ListingPhotoView(url: nil, imageName: imageName, contentMode: .fit)
                } else {
                    TabView {
                        ForEach(urls.enumerated(), id: \.element) { index, url in
                            ListingPhotoView(url: url, contentMode: .fit)
                                .accessibilityLabel("Bild \(index + 1) von \(urls.count)")
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
            }
            .navigationTitle("Bildergalerie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
        }
    }
}
