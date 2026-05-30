import Testing
import Foundation
@testable import ConstitutionKit

@Suite struct ContentStoreTests {
    private func makeStore() throws -> ContentStore {
        try ContentStore(contentDirectory: repoContentDirectory())
    }

    @Test func loadsAllCollections() throws {
        let store = try makeStore()
        #expect(store.chapters.count == 10)
        #expect(store.sections.count == 131)
        #expect(store.cases.count == 41)
        #expect(store.referendums.count == 45)
        #expect(store.documents.count == 5)
    }

    @Test func lookupsByID() throws {
        let store = try makeStore()
        #expect(store.section(id: "s51")?.number == "51")
        #expect(store.section(id: "s9999") == nil)
        #expect(store.case(id: "demden-v-pedder-1904") != nil)
        #expect(store.referendum(id: "1906-senate-elections") != nil)
        #expect(store.document(id: "constitution-act-1900") != nil)
    }

    @Test func sectionsForChapterAreOrdered() throws {
        let store = try makeStore()
        let chapter = try #require(store.chapter(slug: "preamble"))
        let sections = store.sections(for: chapter)
        #expect(sections.map { $0.id } == chapter.sectionIDs.filter { store.section(id: $0) != nil })
        #expect(!sections.isEmpty)
    }

    /// Every cross-reference id in the dataset must resolve to a real record.
    @Test func crossReferenceIntegrity() throws {
        let store = try makeStore()
        for section in store.sections {
            for id in section.relatedCases {
                #expect(store.case(id: id) != nil, "\(section.id) -> missing case \(id)")
            }
            for id in section.relatedReferendums {
                #expect(store.referendum(id: id) != nil, "\(section.id) -> missing referendum \(id)")
            }
            for id in section.relatedDocuments {
                #expect(store.document(id: id) != nil, "\(section.id) -> missing document \(id)")
            }
        }
        for kase in store.cases {
            for id in kase.relatedSections {
                #expect(store.section(id: id) != nil, "\(kase.id) -> missing section \(id)")
            }
        }
    }
}
