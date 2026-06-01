import Testing
import Foundation
@testable import ConstitutionKit

@Suite struct SearchIndexTests {
    private func makeIndex() throws -> SearchIndex {
        SearchIndex(store: try ContentStore(contentDirectory: repoContentDirectory()))
    }

    @Test func emptyQueryReturnsNothing() throws {
        let index = try makeIndex()
        #expect(index.search("").isEmpty)
        #expect(index.search("   ").isEmpty)
    }

    @Test func findsCaseByName() throws {
        let results = try makeIndex().search("Pedder")
        #expect(results.cases.contains { $0.id == "demden-v-pedder-1904" })
    }

    @Test func findsReferendumByTitle() throws {
        let results = try makeIndex().search("Senate Elections")
        #expect(results.referendums.contains { $0.id == "1906-senate-elections" })
    }

    @Test func findsDocumentByTitleTokens() throws {
        let results = try makeIndex().search("constitution act")
        #expect(results.documents.contains { $0.id == "constitution-act-1900" })
    }

    @Test func findsSections() throws {
        #expect(!(try makeIndex().search("Parliament").sections.isEmpty))
    }

    @Test func allTokensMustMatch() throws {
        // "banana" matches nothing, so the AND semantics exclude the referendum.
        let results = try makeIndex().search("senate banana")
        #expect(!results.referendums.contains { $0.id == "1906-senate-elections" })
    }

    @Test func nonsenseReturnsNothing() throws {
        #expect(try makeIndex().search("qzxnomatchqzx").totalCount == 0)
    }
}
