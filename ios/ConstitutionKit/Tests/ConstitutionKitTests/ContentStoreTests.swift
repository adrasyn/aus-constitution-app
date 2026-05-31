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
                #expect(store.section(reference: id) != nil, "case \(kase.id) -> missing section \(id)")
            }
        }
        for referendum in store.referendums {
            for id in referendum.relatedSections {
                #expect(store.section(reference: id) != nil, "referendum \(referendum.id) -> missing section \(id)")
            }
        }
        for document in store.documents {
            for id in document.relatedSections {
                #expect(store.section(reference: id) != nil, "document \(document.id) -> missing section \(id)")
            }
        }
    }

    @Test func resolvesSectionReferences() throws {
        let store = try makeStore()
        #expect(store.section(reference: "51")?.id == "s51")
        #expect(store.section(reference: "s51")?.id == "s51")
        #expect(store.section(reference: "51(ii)")?.id == "s51")
        #expect(store.section(reference: "75(v)")?.id == "s75")
        #expect(store.section(reference: "105A")?.id == "s105A")
        #expect(store.section(reference: "nope") == nil)
    }

    @Test func sectionsForReferencesDedupsAndPreservesOrder() throws {
        let store = try makeStore()
        // "51(ii)" and "51(vi)" both resolve to s51 -> appear once; order preserved.
        let result = store.sections(forReferences: ["75(v)", "51(ii)", "51(vi)"])
        #expect(result.map(\.id) == ["s75", "s51"])
        // Unresolvable refs are dropped.
        #expect(store.sections(forReferences: ["nope", "51"]).map(\.id) == ["s51"])
        #expect(store.sections(forReferences: []).isEmpty)
    }
}
