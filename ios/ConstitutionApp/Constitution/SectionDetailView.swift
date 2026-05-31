import SwiftUI
import ConstitutionKit

struct SectionDetailView: View {
    let store: ContentStore
    let section: ConstitutionKit.Section

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(section.title)
                    .font(.system(.title, design: .serif))

                Text(section.content)
                    .font(.system(.body, design: .serif))
                    .lineSpacing(6)
                    .textSelection(.enabled)

                RelatedSection(title: "Related Cases",
                               items: store.cases(for: section)) {
                    $0.shortName ?? $0.name
                }
                RelatedSection(title: "Related Referendums",
                               items: store.referendums(for: section)) {
                    "\($0.title) (\(String($0.year)))"
                }
                RelatedSection(title: "Related Documents",
                               items: store.documents(for: section)) {
                    $0.title
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(section.number == "0" ? "Preamble" : "Section \(section.number)")
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
