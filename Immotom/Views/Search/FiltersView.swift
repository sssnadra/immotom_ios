import SwiftUI

/// Detail-Filter
struct FiltersView: View {
    @Binding var filters: SearchFilters
    var onApply: () -> Void

    // MARK: - Local UI State (für TextFields)

    /// Fläche wird als String eingegeben und intern in `Int?` gemappt.
    @State private var minAreaText: String = ""
    @State private var maxAreaText: String = ""

    // Dropdown-Optionen
    private let bauformOptionen = ["Bauform", "Altbau", "Neubau", "Einfamilienhaus"]
    private let energieOptionen = ["Energieklasse", "A++", "A", "B", "C", "D", "E"]
    private let jaNeinOptionen = ["Egal", "Ja", "Nein"]
    private let zimmerOptionen = ["Zimmer", "1", "2", "3", "4", "5", "6+"]
    private let stockwerkOptionen = ["Stockwerk", "EG", "1", "2", "3", "4+"]
    private let heizungOptionen = ["Heizungsart", "Gas", "Fernwärme", "Strom", "Öl", "Wärmepumpe"]
    private let haustierOptionen = ["Egal", "Erlaubt", "Nicht erlaubt", "Nach Absprache"]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Detail Filter")
                            .font(.title).bold()
                            .padding(.top, 10)

                        Group {
                            filterLabel(text: "Fläche (m²)")
                            HStack(spacing: 12) {
                                customTextField(placeholder: "Min. Fläche", text: $minAreaText)
                                customTextField(placeholder: "Max. Fläche", text: $maxAreaText)
                            }

                            filterLabel(text: "Zimmeranzahl")
                            customDropdown(selection: $filters.rooms, options: zimmerOptionen)

                            filterLabel(text: "Stockwerk")
                            customDropdown(selection: $filters.floor, options: stockwerkOptionen)
                        }

                        Group {
                            filterLabel(text: "Balkon / Terrasse")
                            customDropdown(selection: $filters.hasBalkony, options: jaNeinOptionen)

                            filterLabel(text: "Aufzug")
                            customDropdown(selection: $filters.hasElevator, options: jaNeinOptionen)

                            filterLabel(text: "Kellerabteil")
                            customDropdown(selection: $filters.hasCellar, options: jaNeinOptionen)

                            filterLabel(text: "Heizungsart")
                            customDropdown(selection: $filters.heatingType, options: heizungOptionen)

                            filterLabel(text: "Bauform")
                            customDropdown(selection: $filters.buildingType, options: bauformOptionen)

                            filterLabel(text: "Möbliert")
                            customDropdown(selection: $filters.isFurnished, options: jaNeinOptionen)

                            filterLabel(text: "Energieklasse")
                            customDropdown(selection: $filters.energyClass, options: energieOptionen)

                            filterLabel(text: "Haustiere")
                            customDropdown(selection: $filters.petsAllowed, options: haustierOptionen)

                            filterLabel(text: "Barrierefreiheit")
                            customDropdown(selection: $filters.isAccessible, options: jaNeinOptionen)
                        }

                        // Platz, damit der Bottom-Button nichts überdeckt
                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 25)
                }
            }

            // Fixer Bottom-Button
            filterBottomButton
        }
        .ignoresSafeArea(edges: .top)

        // MARK: - Initial Sync
        .onAppear {
            minAreaText = filters.minArea.map(String.init) ?? ""
            maxAreaText = filters.maxArea.map(String.init) ?? ""
        }

        // MARK: - Live Sync
        .onChange(of: minAreaText) { _, newValue in
            filters.minArea = Self.toOptionalInt(newValue)
        }
        .onChange(of: maxAreaText) { _, newValue in
            filters.maxArea = Self.toOptionalInt(newValue)
        }
    }

    // MARK: - Bottom Button

    private var filterBottomButton: some View {
        VStack {
            Button(action: {
                filters.minArea = Self.toOptionalInt(minAreaText)
                filters.maxArea = Self.toOptionalInt(maxAreaText)

                onApply()
            }) {
                Text("Filter")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color(red: 0.7, green: 0.85, blue: 0.3))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.white.opacity(0), .white]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Small UI Helpers

    private func filterLabel(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .bold()
            .padding(.bottom, -10)
    }

    private func customTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding(12)
            .background(Color(white: 0.9))
            .cornerRadius(8)
            .keyboardType(.numberPad)
    }

    private func customDropdown(selection: Binding<String>, options: [String]) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection.wrappedValue = option }
            }
        } label: {
            HStack {
                Text(selection.wrappedValue.isEmpty ? options.first ?? "" : selection.wrappedValue)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color(white: 0.9))
            .cornerRadius(8)
        }
    }

    // MARK: - Parsing Helper

    /// Wandelt einen String in `Int?` um:
    /// - ""  -> nil
    /// - "12" -> 12
    /// - "12a" -> 12
    private static func toOptionalInt(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Nur Ziffern behalten
        let digitsOnly = trimmed.filter { $0.isNumber }
        return Int(digitsOnly)
    }
}

#Preview {
    struct PreviewWrap: View {
        @State var f: SearchFilters = .default
        var body: some View {
            FiltersView(filters: $f) {}
        }
    }
    return PreviewWrap()
}

