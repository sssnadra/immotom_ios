import SwiftUI

/// Detailansicht eines Inserats.
///
/// Datenfluss:
/// - `init(listingID:)` erzeugt `DetailViewModel` mit Demo-Repo
/// - In `.task` wird auf das Repo aus `AppEnvironment` umgestellt und geladen
///
/// Layout:
/// - Header-Bild mit Back-Button + Favorite-Button
/// - Kartenartige Sektionen (Hauptinfo, Objektinfo, Beschreibung, Kontakt)
/// - Bottom-Bar mit Aktionen (Anrufen / E-Mail) – derzeit ohne Logik
struct ObjectDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var env: AppEnvironment

    @StateObject private var vm: DetailViewModel


    init(listingID: String) {
        // ViewModel startet mit Demo-Repo – wird später via env ersetzt
        _vm = StateObject(wrappedValue: DetailViewModel(id: listingID, repo: DemoListingsDetailRepository()))
    }

    var body: some View {
        content
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .top)
            .task {
                vm.update(repo: env.listingsDetailRepository)
                await vm.load()
            }
    }

    // MARK: - Content Switch (Loadable)

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView()
                .accessibilityLabel(VoiceOverLabels.loadingDetails)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let d):
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        imageHeader(d)

                        VStack(spacing: 20) {
                            mainInfoCard(d)

                            if !d.infoPairs.isEmpty {
                                sectionContainer(title: d.infoTitle) {
                                    detailedInfoGrid(d)
                                }
                            }

                            if !d.description.isEmpty {
                                sectionContainer(title: d.descriptionTitle) {
                                    Text(d.description)
                                        .font(.subheadline)
                                        .foregroundColor(.primary.opacity(0.8))
                                        .lineSpacing(4)
                                }
                            }

                            if !d.contactCompany.isEmpty || !d.contactPerson.isEmpty || !d.contactPhone.isEmpty || !d.contactEmail.isEmpty {
                                sectionContainer(title: d.contactTitle) {
                                    contactInfo(d)
                                }
                            }
                        }
                        // Platz für Bottom-Bar
                        .padding(.bottom, 140)
                        .offset(y: -30)
                    }
                }

                if !d.contactPhone.isEmpty || !d.contactEmail.isEmpty {
                    actionButtons(d)
                }
            }
            .background(Color(.systemGroupedBackground).opacity(0.5))

        case .failed(let msg):
            VStack {
                ContentUnavailableView(
                    "Fehler",
                    systemImage: "exclamationmark.triangle",
                    description: Text(msg)
                )
                HStack {
                    Button("Zurück") { dismiss() }
                    Button("Erneut versuchen") { Task { await vm.load() } }
                }
                .padding()
            }
        }
    }

    // MARK: - Header (Bild + Back + Favorite)

    private func imageHeader(_ d: ListingDetail) -> some View {
        ZStack(alignment: .top) {

            Group {
                if let imageName = d.imageName {
                    Image(imageName).resizable().scaledToFill()
                } else if let url = d.imageURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                } else {
                    Color.gray.opacity(0.2)
                        .overlay { Image(systemName: "photo").font(.largeTitle) }
                }
            }
            .frame(height: 250)
            .clipped()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(VoiceOverLabels.propertyImage(title: d.title, hasImage: d.imageName != nil || d.imageURL != nil))
            .accessibilityAddTraits(.isImage)

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .padding(10)
                        .frame(minWidth: 44, minHeight: 44)
                        .background(.white.opacity(0.9))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
                .accessibilityLabel(VoiceOverLabels.back)

                Spacer()

                FavoriteButton(listingID: d.id, listingTitle: d.title)
            }
            .padding(.horizontal)
            .padding(.top, 60)
        }
    }

    // MARK: - Main Card (Titel/Adresse/Preis + Meta)

    private func mainInfoCard(_ d: ListingDetail) -> some View {
        let spokenMetadata = VoiceOverLabels.metadata([d.metaLeft, d.metaMid, d.metaRight])
        return VStack(alignment: .leading, spacing: 10) {
            Text(d.title)
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(d.street)
                    Text(d.zipCity)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityElement(children: .combine)

                Spacer()

                Text(formatPrice(d.price))
                    .accessibilityLabel(VoiceOverLabels.price(d.price))
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.65, green: 0.82, blue: 0.25))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Divider().padding(.vertical, 5)

            Text("\(d.metaLeft)  •  \(d.metaMid)  •  \(d.metaRight)")
                .font(.caption.bold())
                .foregroundColor(.primary.opacity(0.7))
                .accessibilityLabel(Text(spokenMetadata))
                .accessibilityHidden(spokenMetadata.isEmpty)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
    }

    // MARK: - Objektinfo Grid (Key/Value)

    private func detailedInfoGrid(_ d: ListingDetail) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(d.infoPairs, id: \.0) { k, v in
                VStack(alignment: .leading, spacing: 4) {
                    Text(k)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text(v)
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(VoiceOverLabels.detail(label: k, value: v))
            }
        }
    }

    // MARK: - Section Container

    private func sectionContainer<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title).font(.headline)
                .accessibilityAddTraits(.isHeader)
            Divider()
            content()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }

    // MARK: - Kontaktblock

    private func contactInfo(_ d: ListingDetail) -> some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text(d.contactCompany).font(.subheadline.bold())
                Text(d.contactPerson).font(.caption)
                Text("\(d.contactStreet), \(d.contactCity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image("ic_logo")
                .resizable()
                .frame(width: 50, height: 50)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Bottom Actions

    private func actionButtons(_ d: ListingDetail) -> some View {
        HStack(spacing: 15) {
            Button(action: {
                // TODO: Telefon-Aktion
            }) {
                Label("Anrufen", systemImage: "phone.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.65, green: 0.82, blue: 0.25))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .accessibilityHint(VoiceOverLabels.unavailable)

            Button(action: {
                // TODO: Mail-Aktion
            }) {
                Label("E-Mail", systemImage: "envelope.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.65, green: 0.82, blue: 0.25))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .accessibilityHint(VoiceOverLabels.unavailable)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 40)
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
    }
    
    private func formatPrice(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains("€") { return trimmed }
        return "\(trimmed)€"
    }
}

#Preview {
    NavigationStack {
        ObjectDetailView(listingID: "1")
    }
    .environmentObject(AppEnvironment(useDemoData: true))
    .environment(FavoritesStore())
}
