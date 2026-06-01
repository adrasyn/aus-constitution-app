import SwiftUI
import ConstitutionKit

struct CaseDetailView: View {
    let store: ContentStore
    let legalCase: Case

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    YearBadge(text: String(legalCase.year))
                    Text(legalCase.name)
                        .font(AppFont.readingTitle)
                        .foregroundStyle(Color.textPrimary)
                    Text("\(legalCase.court) · \(legalCase.citation)")
                        .font(AppFont.monoSmall)
                        .foregroundStyle(Color.textSecondary)
                }

                labelled("Principle", legalCase.principle)
                labelled("Outcome", legalCase.outcome.capitalized)

                Text(legalCase.content)
                    .font(AppFont.readingBody)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                let sections = store.sections(forReferences: legalCase.relatedSections)
                if !sections.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RELATED SECTIONS").font(AppFont.badge).tracking(0.5)
                            .foregroundStyle(Color.textSecondary)
                        FlowLayout(spacing: 4) {
                            ForEach(legalCase.relatedSections, id: \.self) { ref in
                                SectionRefPill(reference: ref, store: store)
                            }
                        }
                    }
                }

                RelatedItemsSection(
                    title: "Related Cases",
                    items: legalCase.relatedCases.compactMap { store.case(id: $0) },
                    accent: .accentGreen,
                    primary: { $0.shortName ?? $0.name },
                    secondary: { String($0.year) }
                )

                if let urlString = legalCase.sourceUrl, let url = URL(string: urlString) {
                    Link("View on AustLII", destination: url).font(AppFont.body)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .revealingNavigationTitle(legalCase.shortName ?? legalCase.name)
        .tabBarMinimizeBehavior(.onScrollDown)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: ShareText.legalCase(legalCase)) {
                    Image(systemName: "square.and.arrow.up")
                }
                BookmarkButton(kind: .legalCase, contentID: legalCase.id)
            }
        }
    }

    @ViewBuilder
    private func labelled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline).foregroundStyle(Color.textPrimary)
            Text(value).font(AppFont.body).foregroundStyle(Color.textSecondary)
        }
    }
}
