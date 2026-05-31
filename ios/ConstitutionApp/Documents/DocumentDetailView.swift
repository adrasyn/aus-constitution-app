import SwiftUI
import ConstitutionKit

struct DocumentDetailView: View {
    let store: ContentStore
    let document: HistoricalDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(document.title)
                        .font(.system(.title, design: .serif))
                    Text(String(document.year))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(document.description)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Text(document.content)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                RelatedSection(title: "Related Sections",
                               items: store.sections(forReferences: document.relatedSections)) {
                    $0.number == "0" ? "Preamble" : "Section \($0.number)"
                }

                if let urlString = document.sourceUrl, let url = URL(string: urlString) {
                    Link("View source", destination: url)
                        .font(.callout)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
