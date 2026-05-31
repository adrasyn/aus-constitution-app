import SwiftUI
import ConstitutionKit

struct ChapterListView: View {
    let store: ContentStore

    var body: some View {
        NavigationStack {
            List(store.chapters) { chapter in
                let count = store.sections(for: chapter).count
                NavigationLink(value: chapter) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(chapter.title)
                            .font(.headline)
                        Text(count == 1 ? "1 section" : "\(count) sections")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Constitution")
            .contentDestinations(store: store)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
        }
    }
}
