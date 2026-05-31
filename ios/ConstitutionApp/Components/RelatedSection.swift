import SwiftUI

/// A titled block of navigation links to related content. Renders nothing when
/// `items` is empty. `Item` must be Hashable (for the link value) and
/// Identifiable (for ForEach); a destination must be registered via
/// `.contentDestinations(store:)` on the enclosing stack.
struct RelatedSection<Item: Identifiable & Hashable>: View {
    let title: String
    let items: [Item]
    let label: (Item) -> String

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        HStack {
                            Text(label(item))
                                .font(.callout)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
        }
    }
}
