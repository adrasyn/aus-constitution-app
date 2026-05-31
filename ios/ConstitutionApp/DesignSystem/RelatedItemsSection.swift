import SwiftUI

/// A titled section of related-content cards. Each card navigates to its item
/// (a destination must be registered via `.contentDestinations(store:)`).
/// Renders nothing when `items` is empty.
struct RelatedItemsSection<Item: Identifiable & Hashable>: View {
    let title: String
    let items: [Item]
    var accent: Color = .accentGreen
    let primary: (Item) -> String
    var secondary: (Item) -> String? = { _ in nil }

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title.uppercased())
                    .font(AppFont.badge)
                    .tracking(0.5)
                    .foregroundStyle(Color.textSecondary)
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        ContentCard(accent: accent) {
                            Text(primary(item))
                                .font(AppFont.cardTitle)
                                .foregroundStyle(Color.textPrimary)
                            if let sub = secondary(item) {
                                Text(sub)
                                    .font(AppFont.body)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
