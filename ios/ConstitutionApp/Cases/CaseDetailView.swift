import SwiftUI
import ConstitutionKit

struct CaseDetailView: View {
    let store: ContentStore
    let legalCase: Case

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(legalCase.name)
                        .font(.system(.title, design: .serif))
                    Text("\(legalCase.court) · \(String(legalCase.year))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(legalCase.citation)
                        .font(.subheadline.monospaced())
                        .foregroundStyle(.secondary)
                }

                labelled("Principle", legalCase.principle)
                labelled("Outcome", legalCase.outcome.capitalized)

                Text(legalCase.content)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                RelatedSection(title: "Related Sections",
                               items: store.sections(forReferences: legalCase.relatedSections)) {
                    $0.number == "0" ? "Preamble" : "Section \($0.number)"
                }
                RelatedSection(title: "Related Cases",
                               items: legalCase.relatedCases.compactMap { store.case(id: $0) }) {
                    $0.shortName ?? $0.name
                }

                if let urlString = legalCase.sourceUrl, let url = URL(string: urlString) {
                    Link("View on AustLII", destination: url)
                        .font(.callout)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .navigationTitle(legalCase.shortName ?? legalCase.name)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }

    @ViewBuilder
    private func labelled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
