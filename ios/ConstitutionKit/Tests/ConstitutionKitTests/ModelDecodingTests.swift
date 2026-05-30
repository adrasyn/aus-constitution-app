import Testing
import Foundation
@testable import ConstitutionKit

@Suite struct ModelDecodingTests {
    @Test func testDecodesAllSections() throws {
        let data = try loadContent("constitution/sections.json")
        let sections = try JSONDecoder().decode([Section].self, from: data)

        #expect(sections.count == 131)

        // id is synthesised as "s<number>", not read from JSON.
        let s51 = try #require(sections.first { $0.id == "s51" })
        #expect(s51.number == "51")
        #expect(s51.chapter == 1)
        #expect(!s51.title.isEmpty)
        #expect(!s51.content.isEmpty)

        // Preamble (number 0) decodes even if it lacks related-* arrays.
        #expect(sections.first { $0.id == "s0" } != nil)
    }

    @Test func testDecodesAllChapters() throws {
        let data = try loadContent("constitution/chapters.json")
        let chapters = try JSONDecoder().decode([Chapter].self, from: data)

        #expect(chapters.count == 10)

        // Preamble: parts empty -> sectionIDs come from `sections`.
        let preamble = try #require(chapters.first { $0.slug == "preamble" })
        #expect(preamble.parts.isEmpty)
        #expect(preamble.sectionIDs.first == "s\(preamble.sections.first!)")

        // A chapter with parts: sectionIDs flatten the parts' sections.
        let withParts = try #require(chapters.first { !$0.parts.isEmpty })
        let expected = withParts.parts.flatMap(\.sections).map { "s\($0)" }
        #expect(withParts.sectionIDs == expected)
    }

    @Test func testDecodesCasesReferendumsDocuments() throws {
        let cases = try JSONDecoder().decode(
            [Case].self, from: loadContent("cases/cases.json"))
        #expect(cases.count == 41)
        let demden = try #require(cases.first { $0.id == "demden-v-pedder-1904" })
        #expect(demden.year == 1904)
        #expect(demden.citation == "(1904) 1 CLR 91")
        #expect(demden.sourceUrl != nil)

        let referendums = try JSONDecoder().decode(
            [Referendum].self, from: loadContent("referendums/referendums.json"))
        #expect(referendums.count == 45)
        let senate = try #require(referendums.first { $0.id == "1906-senate-elections" })
        #expect(senate.outcome == "carried")
        #expect(abs(senate.yesPercentage - 82.65) < 0.001)

        let documents = try JSONDecoder().decode(
            [HistoricalDocument].self, from: loadContent("documents/documents.json"))
        #expect(documents.count == 5)
        #expect(documents.first { $0.id == "constitution-act-1900" } != nil)
    }
}
