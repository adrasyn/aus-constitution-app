import SwiftUI
import ConstitutionKit

struct SectionDetailView: View {
    let store: ContentStore
    let section: ConstitutionKit.Section

    private var label: String { section.number == "0" ? "Preamble" : "Section \(section.number)" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(label.uppercased())
                        .font(AppFont.monoSmall)
                        .foregroundStyle(Color.textSecondary)
                    Text(section.title)
                        .font(AppFont.readingTitle)
                        .foregroundStyle(Color.textPrimary)
                }

                Text(section.content)
                    .font(AppFont.readingBody)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                if let notes = section.notes, !notes.isEmpty {
                    AmendmentNote(text: notes)
                }

                RelatedItemsSection(
                    title: "Related Cases",
                    items: store.cases(for: section),
                    accent: .accentGreen,
                    primary: { $0.shortName ?? $0.name },
                    secondary: { "\($0.court) · \(String($0.year))" }
                )
                RelatedItemsSection(
                    title: "Related Referendums",
                    items: store.referendums(for: section),
                    accent: .accentGold,
                    primary: { $0.title },
                    secondary: { "\(String($0.year)) · \($0.outcome.capitalized)" }
                )
                RelatedItemsSection(
                    title: "Related Documents",
                    items: store.documents(for: section),
                    accent: .accentGold,
                    primary: { $0.title },
                    secondary: { String($0.year) }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .revealingNavigationTitle(label)
        .tabBarMinimizeBehavior(.onScrollDown)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: ShareText.section(section)) {
                    Image(systemName: "square.and.arrow.up")
                }
                BookmarkButton(kind: .section, contentID: section.id)
            }
        }
    }
}
