import SwiftUI
import ConstitutionKit

/// A monospace section-reference chip (e.g. "s 51", "s 51(ii)"). If the
/// reference resolves to a section, it becomes a navigation link to it.
struct SectionRefPill: View {
    let reference: String
    let store: ContentStore

    var body: some View {
        if let section = store.section(reference: reference) {
            NavigationLink(value: section) { pill }
                .buttonStyle(.plain)
        } else {
            pill
        }
    }

    private var pill: some View {
        Text(formatted)
            .font(AppFont.monoSmall)
            .foregroundStyle(Color.accentGreen)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(Color.appSurface, in: Capsule())
    }

    private var formatted: String {
        let bare = reference.hasPrefix("s") ? String(reference.dropFirst()) : reference
        return "s \(bare)"
    }
}
