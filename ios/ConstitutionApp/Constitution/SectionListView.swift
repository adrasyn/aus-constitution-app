import SwiftUI
import ConstitutionKit

struct SectionListView: View {
    let store: ContentStore
    let chapter: Chapter

    var body: some View {
        List(store.sections(for: chapter)) { section in
            NavigationLink(value: section) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.number == "0" ? "Preamble" : "Section \(section.number)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(section.title)
                        .font(.body)
                }
            }
        }
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
