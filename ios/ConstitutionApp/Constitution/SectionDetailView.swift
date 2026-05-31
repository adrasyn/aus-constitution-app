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

                let cases = store.cases(for: section)
                if !cases.isEmpty {
                    relatedSection("Related Cases") {
                        ForEach(cases) { Text($0.shortName ?? $0.name) }
                    }
                }
                let referendums = store.referendums(for: section)
                if !referendums.isEmpty {
                    relatedSection("Related Referendums") {
                        ForEach(referendums) { Text("\($0.title) (\($0.year))") }
                    }
                }
                let documents = store.documents(for: section)
                if !documents.isEmpty {
                    relatedSection("Related Documents") {
                        ForEach(documents) { Text($0.title) }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(section.number == "0" ? "Preamble" : "Section \(section.number)")
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }

    @ViewBuilder
    private func relatedSection<Content: View>(_ title: String,
                                               @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}
