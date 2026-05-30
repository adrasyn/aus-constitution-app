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
}
