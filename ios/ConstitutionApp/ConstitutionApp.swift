import SwiftUI
import SwiftData
import ConstitutionKit
import UIKit

@main
struct ConstitutionApp: App {
    let store: ContentStore
    let searchIndex: SearchIndex

    init() {
        let store = ContentStore.bundled()
        self.store = store
        self.searchIndex = SearchIndex(store: store)

        // Shrink only the tab-bar label font; do NOT reconfigure the background,
        // so the iOS 26 Liquid Glass material is preserved.
        let smaller = UIFont.systemFont(ofSize: 9, weight: .medium)
        let attrs: [NSAttributedString.Key: Any] = [.font: smaller]
        let appearance = UITabBar.appearance().standardAppearance
        for layout in [appearance.stackedLayoutAppearance,
                       appearance.inlineLayoutAppearance,
                       appearance.compactInlineLayoutAppearance] {
            layout.normal.titleTextAttributes = attrs
            layout.selected.titleTextAttributes = attrs
        }
        UITabBar.appearance().standardAppearance = appearance
        if let scrollEdge = UITabBar.appearance().scrollEdgeAppearance {
            for layout in [scrollEdge.stackedLayoutAppearance,
                           scrollEdge.inlineLayoutAppearance,
                           scrollEdge.compactInlineLayoutAppearance] {
                layout.normal.titleTextAttributes = attrs
                layout.selected.titleTextAttributes = attrs
            }
            UITabBar.appearance().scrollEdgeAppearance = scrollEdge
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(store: store, index: searchIndex)
                .tint(.accentGreen)
                .modelContainer(for: SavedItem.self)
        }
    }
}
