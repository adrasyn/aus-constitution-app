import SwiftUI
import ConstitutionKit

struct CaseListView: View {
    let store: ContentStore

    enum Sort: Hashable { case year, name }
    @State private var sort: Sort = .year

    private var cases: [Case] {
        switch sort {
        case .year: return store.cases.sorted { $0.year < $1.year }
        case .name: return store.cases.sorted { ($0.shortName ?? $0.name) < ($1.shortName ?? $1.name) }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Cases", subtitle: "\(store.cases.count) landmark cases")
                    FilterPills(options: [
                        .init(title: "By year", value: .year, activeColor: .accentGreen),
                        .init(title: "By name", value: .name, activeColor: .accentGreen),
                    ], selection: $sort)
                    LazyVStack(spacing: 10) {
                        ForEach(cases) { item in
                            NavigationLink(value: item) {
                                CaseCard(legalCase: item, store: store)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
            .revealingNavigationTitle("Cases")
            .contentDestinations(store: store)
        }
    }
}

private struct CaseCard: View {
    let legalCase: Case
    let store: ContentStore
    private var dissent: Bool { legalCase.outcome.lowercased() == "dissent" }

    var body: some View {
        ContentCard(accent: dissent ? .accentBurgundy : .accentGreen) {
            HStack(alignment: .top) {
                YearBadge(text: String(legalCase.year))
                Spacer()
                if !legalCase.relatedSections.isEmpty {
                    FlowLayout(spacing: 4) {
                        ForEach(legalCase.relatedSections.prefix(4), id: \.self) { ref in
                            SectionRefPill(reference: ref, store: store)
                        }
                    }
                    .frame(maxWidth: 160, alignment: .trailing)
                }
            }
            Text(legalCase.name)
                .font(AppFont.cardTitle)
                .foregroundStyle(Color.textPrimary)
            Text(legalCase.principle)
                .font(AppFont.body)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(3)
            Text(legalCase.court)
                .font(AppFont.monoSmall)
                .foregroundStyle(Color.textSecondary)
        }
    }
}
