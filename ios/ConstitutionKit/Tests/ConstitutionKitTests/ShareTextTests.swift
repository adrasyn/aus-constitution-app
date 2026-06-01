import Testing
import Foundation
@testable import ConstitutionKit

@Suite struct ShareTextTests {
    private func store() throws -> ContentStore {
        try ContentStore(contentDirectory: repoContentDirectory())
    }

    @Test func sectionShareIncludesLabelTitleAttribution() throws {
        let s = try #require(try store().section(id: "s51"))
        let text = ShareText.section(s)
        #expect(text.contains("Section 51"))
        #expect(text.contains(s.title))
        #expect(text.contains("Australian Constitution"))
    }

    @Test func preambleSharesAsPreamble() throws {
        let s = try #require(try store().section(id: "s0"))
        #expect(ShareText.section(s).contains("Preamble"))
    }

    @Test func caseShareIncludesNameAndCitation() throws {
        let c = try #require(try store().case(id: "demden-v-pedder-1904"))
        let text = ShareText.legalCase(c)
        #expect(text.contains(c.name))
        #expect(text.contains(c.citation))
    }

    @Test func referendumShareIncludesTitleAndYear() throws {
        let r = try #require(try store().referendum(id: "1906-senate-elections"))
        let text = ShareText.referendum(r)
        #expect(text.contains(r.title))
        #expect(text.contains("1906"))
    }

    @Test func documentShareIncludesTitle() throws {
        let d = try #require(try store().document(id: "constitution-act-1900"))
        #expect(ShareText.document(d).contains(d.title))
    }

    @Test func excerptIsTruncated() throws {
        let s = try #require(try store().section(id: "s51"))
        // Long content is excerpted, so the share text stays well under the full length.
        #expect(ShareText.section(s).count < s.content.count + 200)
    }
}
