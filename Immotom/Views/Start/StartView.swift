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

                // Filterbereich
                VStack(spacing: 15) {
                    Spacer().frame(height: 20)

                    Group {
                        filterSection(title: "Kaufen oder Mieten", width: geometry.size.width * 0.85) {
                            customMenuPicker(selection: $filters.rentBuy, options: rentBuyOptions)
                        }

                        filterSection(title: "Kategorie", width: geometry.size.width * 0.85) {
                            customMenuPicker(selection: $filters.category, options: categoryOptions)
                        }

                        filterSection(title: "Preis", width: geometry.size.width * 0.85) {
                            HStack(spacing: 12) {
                                priceField(placeholder: "Min.", text: $minPriceStr)
                                Text("–").foregroundColor(.white).bold()
                                priceField(placeholder: "Max.", text: $maxPriceStr)
                            }
                        }

                        filterSection(title: "Umkreis", width: geometry.size.width * 0.85) {
                            VStack(spacing: 5) {
                                Slider(value: $filters.radiusKm, in: 0...50)
                                    .tint(brandColor)
                                Text("\(Int(filters.radiusKm)) km")
                                    .foregroundColor(.white)
                                    .bold()
                            }
                        }

                        filterSection(title: "Standort", width: geometry.size.width * 0.85) {
                            HStack {
                                TextField("Ort, PLZ...", text: $filters.locationText)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(.black)

                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)

                // Footer-Buttons (unten fixiert)
                VStack {
                    Spacer()
                    footerButtons
                        .frame(height: 100)
                }
            }
        }
    }

    // MARK: - Footer Buttons

    /// Zwei Hauptaktionen: Suche + Karte
    var footerButtons: some View {
        HStack(spacing: 20) {

            // Suche: schreibt Preisstrings in Int-Filter & wechselt Tab
            Button(action: {
                filters.minPrice = Int(minPriceStr)
                filters.maxPrice = Int(maxPriceStr)
                selectedTab = "Suche"
            }) {
                Label("Suche", systemImage: "magnifyingglass")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(brandColor, in: Capsule())
            }

            // Karte: Tab wechseln
            Button(action: {
                selectedTab = "Karte"
            }) {
                Label("Karte", systemImage: "map")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(brandColor, in: Capsule())
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 40)
    }

    // MARK: - UI Helper

    /// Custom `Menu`-Picker, damit er wie ein eigenes Feld aussieht.
    func customMenuPicker(selection: Binding<String>, options: [String]) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection.wrappedValue = option }
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

            content()
        }
        .frame(width: width)
    }

    /// Preis-Feld mit NumberPad.
    func priceField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding(12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
            .keyboardType(.numberPad)
    }
}

#Preview {
    StartView(
        filters: .constant(SearchFilters.default),
        selectedTab: .constant("Start")
    )
}
