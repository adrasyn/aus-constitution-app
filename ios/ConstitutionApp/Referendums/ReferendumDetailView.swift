import SwiftUI
import ConstitutionKit

struct ReferendumDetailView: View {
    let store: ContentStore
    let referendum: Referendum

    private var carried: Bool { referendum.outcome == "carried" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        YearBadge(text: referendum.date ?? String(referendum.year))
                        Spacer()
                        OutcomeBadge(
                            text: referendum.outcome,
                            foreground: carried ? .accentGreen : .accentBurgundy,
                            background: carried ? .tintGreen : .tintBurgundy
                        )
                    }
                    Text(referendum.title)
                        .font(AppFont.readingTitle)
                        .foregroundStyle(Color.textPrimary)
                }

                labelled("Question", referendum.question)
                HStack(spacing: 16) {
                    Text("\(referendum.yesPercentage, specifier: "%.2f")% yes")
                    if let f = referendum.statesFor, let a = referendum.statesAgainst {
                        Text("\(f)/\(f + a) states")
                    }
                }
                .font(AppFont.mono)
                .foregroundStyle(Color.textSecondary)

                Text(referendum.content)
                    .font(AppFont.readingBody)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                let sections = store.sections(forReferences: referendum.relatedSections)
                if !sections.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Related Sections")
                            .font(.headline)
                            .foregroundStyle(Color.textPrimary)
                        FlowLayout(spacing: 4) {
                            ForEach(referendum.relatedSections, id: \.self) { ref in
                                SectionRefPill(reference: ref, store: store)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
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
                .foregroundStyle(Color.textPrimary)
            Text(value)
                .font(AppFont.body)
                .foregroundStyle(Color.textSecondary)
        }
    }
}
