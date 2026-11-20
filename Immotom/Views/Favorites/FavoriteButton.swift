import SwiftUI
import TipKit

struct FavoriteButton: View {
    @Environment(FavoritesStore.self) private var favorites
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animationTrigger = 0

    let listingID: String
    let listingTitle: String
    var showsTip = true

    @State private var isTipPresented = false
    private let favoriteTip = FavoriteTip()

    var body: some View {
        Button {
            favorites.toggle(listingID)
            if isTipPresented {
                favoriteTip.invalidate(reason: .actionPerformed)
                favorites.dismissHint()
            }
            if !reduceMotion {
                animationTrigger += 1
            }
        } label: {
            Image(systemName: favorites.contains(listingID) ? "star.fill" : "star")
                .font(.title3.bold())
                .symbolEffect(.bounce, value: animationTrigger)
                .symbolEffectsRemoved(reduceMotion)
                .frame(minWidth: 44, minHeight: 44)
                .foregroundStyle(.primary)
                .background(Color(.systemBackground), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .popoverTip(
            showsTip && favorites.shouldShowHint ? favoriteTip : nil,
            isPresented: $isTipPresented,
            arrowEdge: .top
        )
        .onChange(of: isTipPresented) { wasPresented, isPresented in
            if isPresented {
                favorites.markHintPresented()
            } else if wasPresented {
                favorites.dismissHint()
            }
        }
        .accessibilityLabel(favorites.contains(listingID) ? "Aus Favoriten entfernen" : "Zu Favoriten hinzufügen")
        .accessibilityValue(Text("\(listingTitle), \(favorites.contains(listingID) ? "Gespeichert" : "Nicht gespeichert")"))
        .accessibilityIdentifier("favorite-\(listingID)")
    }
}
