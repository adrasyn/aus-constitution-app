import SwiftUI
import ConstitutionKit

struct ReferendumDetailView: View {
    let store: ContentStore
    let referendum: Referendum

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(referendum.title)
                        .font(.system(.title, design: .serif))
                    Text(referendum.date ?? String(referendum.year))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                labelled("Question", referendum.question)
                labelled("Outcome", referendum.outcome.capitalized)
                labelled("Yes vote", String(format: "%.2f%%", referendum.yesPercentage))
                if let f = referendum.statesFor, let a = referendum.statesAgainst {
                    labelled("States", "\(f) for · \(a) against")
                }

                Text(referendum.content)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                RelatedSection(title: "Related Sections",
                               items: store.sections(forReferences: referendum.relatedSections)) {
                    $0.number == "0" ? "Preamble" : "Section \($0.number)"
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .navigationTitle(String(referendum.year))
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
