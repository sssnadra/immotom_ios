import SwiftUI

/// Startscreen der App.
///
/// Zeigt eine Filterübersicht direkt auf der Startseite.
struct StartView: View {

    // MARK: - Bindings (kommen aus AppScaffoldView)

    /// Global geteilter Filterzustand.
    @Binding var filters: SearchFilters

    /// Tab/Screen-Auswahl in der AppShell.
    @Binding var selectedTab: String

    // MARK: - Local UI State

    /// Preise werden in der UI als String eingegeben und erst beim "Suche"-Klick zu Int konvertiert.
    @State private var minPriceStr = ""
    @State private var maxPriceStr = ""

    // MARK: - Options

    let rentBuyOptions = ["Mieten", "Kaufen"]
    let categoryOptions = ["Wohnung", "Haus", "Grundstück", "Gewerbe"]

    /// Brand-Farbe
    let brandColor = Color(red: 0.7, green: 0.85, blue: 0.3)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {

                // Hintergrundbild
                Image("start_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.3))
                    .accessibilityHidden(true)

                // Filterbereich
                VStack(spacing: 15) {
                    Spacer().frame(height: 20)

                    Group {
                        filterSection(title: "Kaufen oder Mieten", width: geometry.size.width * 0.85) {
                            customMenuPicker(selection: $filters.rentBuy, options: rentBuyOptions, label: "Kaufen oder Mieten")
                        }

                        filterSection(title: "Kategorie", width: geometry.size.width * 0.85) {
                            customMenuPicker(selection: $filters.category, options: categoryOptions, label: "Immobilienkategorie")
                        }

                        filterSection(title: "Preis", width: geometry.size.width * 0.85) {
                            HStack(spacing: 12) {
                                priceField(placeholder: "Min.", text: $minPriceStr, label: VoiceOverLabels.minimumPrice)
                                Text("–").foregroundColor(.white).bold().accessibilityHidden(true)
                                priceField(placeholder: "Max.", text: $maxPriceStr, label: VoiceOverLabels.maximumPrice)
                            }
                        }

                        filterSection(title: "Umkreis", width: geometry.size.width * 0.85) {
                            VStack(spacing: 5) {
                                Slider(value: $filters.radiusKm, in: 0...50, step: 1)
                                    .accessibilityLabel(VoiceOverLabels.radius)
                                    .accessibilityValue(VoiceOverLabels.radiusValue(filters.radiusKm))
                                    .tint(brandColor)
                                Text("\(Int(filters.radiusKm)) km")
                                    .foregroundColor(.white)
                                    .bold()
                                    .accessibilityHidden(true)
                            }
                        }

                        filterSection(title: "Standort", width: geometry.size.width * 0.85) {
                            HStack {
                                TextField("Ort, PLZ...", text: $filters.locationText)
                                    .textFieldStyle(.plain)
                                    .accessibilityLabel(VoiceOverLabels.location)
                                    .foregroundColor(.black)

                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .accessibilityHidden(true)
                            }
                            .padding(12)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)

                // Suchaktion unten, bündig mit den Filterfeldern.
                VStack {
                    Spacer()
                    searchButton
                        .frame(width: geometry.size.width * 0.85)
                }
            }
        }
    }

    // MARK: - Suche

    /// Hauptaktion über die gesamte Breite des Filterbereichs.
    private var searchButton: some View {
        Button {
            filters.minPrice = Int(minPriceStr)
            filters.maxPrice = Int(maxPriceStr)
            selectedTab = "Suche"
        } label: {
            Label("Suche", systemImage: "magnifyingglass")
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .background(brandColor, in: Capsule())
        }
        .accessibilityLabel(VoiceOverLabels.search)
        .padding(.bottom, 40)
    }

    // MARK: - UI Helper

    /// Custom `Menu`-Picker, damit er wie ein eigenes Feld aussieht.
    func customMenuPicker(selection: Binding<String>, options: [String], label: LocalizedStringKey) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection.wrappedValue = option }
                    .accessibilityAddTraits(selection.wrappedValue == option ? .isSelected : [])
            }
        } label: {
            HStack {
                Text(selection.wrappedValue).foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
        }
        .accessibilityLabel(label)
        .accessibilityValue(VoiceOverLabels.selectionValue(selection.wrappedValue))
    }

    /// Wrapper für ein "Filter-Block" Label + Content.
    func filterSection<Content: View>(
        title: String,
        width: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            content()
        }
        .frame(width: width)
    }

    /// Preis-Feld mit NumberPad.
    func priceField(placeholder: String, text: Binding<String>, label: LocalizedStringKey) -> some View {
        TextField(placeholder, text: text)
            .padding(12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
            .keyboardType(.numberPad)
            .accessibilityLabel(label)
    }
}

#Preview {
    StartView(
        filters: .constant(SearchFilters.default),
        selectedTab: .constant("Start")
    )
}
