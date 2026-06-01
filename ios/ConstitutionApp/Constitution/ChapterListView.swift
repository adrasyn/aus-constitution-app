import SwiftUI
import ConstitutionKit

struct ChapterListView: View {
    let store: ContentStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 10) {
                        Image("CoatOfArms")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140)
                            .accessibilityLabel("Commonwealth Coat of Arms")
                        Text("The Constitution")
                            .font(AppFont.screenTitle)
                            .foregroundStyle(Color.textPrimary)
                        Text("Commonwealth of Australia Constitution Act 1900")
                            .font(AppFont.subtitle)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    LazyVStack(spacing: 10) {
                        ForEach(store.chapters) { chapter in
                            let count = store.sections(for: chapter).count
                            NavigationLink(value: chapter) {
                                ContentCard(accent: .accentGreen) {
                                    Text(chapter.title)
                                        .font(AppFont.cardTitle)
                                        .foregroundStyle(Color.textPrimary)
                                    Text(count == 1 ? "1 section" : "\(count) sections")
                                        .font(AppFont.monoSmall)
                                        .foregroundStyle(Color.textSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
            .revealingNavigationTitle("Constitution")
            .contentDestinations(store: store)
        }
    }
}
