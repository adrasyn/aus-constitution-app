import SwiftUI
import ConstitutionKit

struct ChapterListView: View {
    let store: ContentStore

    var body: some View {
        NavigationStack {
            List(store.chapters) { chapter in
                NavigationLink(value: chapter) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(chapter.title)
                            .font(.headline)
                        Text("\(store.sections(for: chapter).count) sections")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Constitution")
            .navigationDestination(for: Chapter.self) { chapter in
                SectionListView(store: store, chapter: chapter)
            }
            .navigationDestination(for: ConstitutionKit.Section.self) { section in
                SectionDetailView(store: store, section: section)
            }
        }
    }
}
