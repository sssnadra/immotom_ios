import SwiftUI
import TipKit

struct FavoriteTip: Tip {
    var title: Text {
        Text("Als Favorit speichern")
    }

    var message: Text? {
        Text("Mit dem Stern speicherst du interessante Immobilien. Du findest sie später im Menü unter „Favoriten“ wieder.")
    }

    var image: Image? {
        Image(systemName: "star")
    }

    var options: [any TipOption] {
        MaxDisplayCount(1)
    }
}
