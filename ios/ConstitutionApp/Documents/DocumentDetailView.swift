import SwiftUI
import ConstitutionKit

struct DocumentDetailView: View {
    let store: ContentStore
    let document: HistoricalDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    YearBadge(text: String(document.year))
                    Text(document.title)
                        .font(AppFont.readingTitle)
                        .foregroundStyle(Color.textPrimary)
                }
                Text(document.description)
                    .font(AppFont.body)
                    .foregroundStyle(Color.textSecondary)

                Text(document.content)
                    .font(AppFont.readingBody)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                let sections = store.sections(forReferences: document.relatedSections)
                if !sections.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RELATED SECTIONS").font(AppFont.badge).tracking(0.5)
                            .foregroundStyle(Color.textSecondary)
                        FlowLayout(spacing: 4) {
                            ForEach(document.relatedSections, id: \.self) { ref in
                                SectionRefPill(reference: ref, store: store)
                            }
                        }
                    }
                }

                if let urlString = document.sourceUrl, let url = URL(string: urlString) {
                    Link("View source", destination: url).font(AppFont.body)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .navigationTitle(String(document.year))
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
