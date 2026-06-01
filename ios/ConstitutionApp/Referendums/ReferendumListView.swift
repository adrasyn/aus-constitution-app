import SwiftUI
import ConstitutionKit

struct ReferendumListView: View {
    let store: ContentStore

    enum Filter: Hashable { case all, carried, defeated }
    @State private var filter: Filter = .all

    private var sorted: [Referendum] { store.referendums.sorted { $0.year < $1.year } }
    private var carriedCount: Int { store.referendums.filter { $0.outcome == "carried" }.count }
    private var defeatedCount: Int { store.referendums.filter { $0.outcome == "defeated" }.count }

    private var filtered: [Referendum] {
        switch filter {
        case .all: return sorted
        case .carried: return sorted.filter { $0.outcome == "carried" }
        case .defeated: return sorted.filter { $0.outcome == "defeated" }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(
                        title: "Referendums",
                        subtitle: "\(store.referendums.count) proposals — \(carriedCount) carried, \(defeatedCount) defeated"
                    )

                    FilterPills(options: [
                        .init(title: "All (\(store.referendums.count))", value: .all),
                        .init(title: "Carried (\(carriedCount))", value: .carried, activeColor: .accentGreen),
                        .init(title: "Defeated (\(defeatedCount))", value: .defeated, activeColor: .accentBurgundy),
                    ], selection: $filter)

                    LazyVStack(spacing: 10) {
                        ForEach(filtered) { referendum in
                            NavigationLink(value: referendum) {
                                ReferendumCard(referendum: referendum, store: store)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
            .revealingNavigationTitle("Referendums")
            .contentDestinations(store: store)
        }
    }
}

private struct ReferendumCard: View {
    let referendum: Referendum
    let store: ContentStore

    private var carried: Bool { referendum.outcome == "carried" }

    var body: some View {
        ContentCard(accent: carried ? .accentGreen : .accentBurgundy) {
            HStack {
                YearBadge(text: String(referendum.year))
                Spacer()
                OutcomeBadge(
                    text: referendum.outcome,
                    foreground: carried ? .accentGreen : .accentBurgundy,
                    background: carried ? .tintGreen : .tintBurgundy
                )
            }
            Text(referendum.title)
                .font(AppFont.cardTitle)
                .foregroundStyle(Color.textPrimary)
            Text(referendum.question)
                .font(AppFont.body)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(3)
            HStack(spacing: 12) {
                Text("\(referendum.yesPercentage, specifier: "%.2f")% yes")
                if let f = referendum.statesFor, let a = referendum.statesAgainst {
                    Text("\(f)/\(f + a) states")
                }
            }
            .font(AppFont.mono)
            .foregroundStyle(Color.textSecondary)
            if !referendum.relatedSections.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(referendum.relatedSections, id: \.self) { ref in
                        SectionRefPill(reference: ref, store: store)
                    }
                }
            }
        }
    }
}
