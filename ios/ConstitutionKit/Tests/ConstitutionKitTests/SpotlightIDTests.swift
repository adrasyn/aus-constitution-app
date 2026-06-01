import Testing
@testable import ConstitutionKit

@Suite struct SpotlightIDTests {
    @Test func roundTripsSection() {
        let id = SpotlightID.make(kind: .section, id: "s51")
        #expect(id == "section:s51")
        let parsed = SpotlightID.parse(id)
        #expect(parsed?.kind == .section)
        #expect(parsed?.id == "s51")
    }

    @Test func roundTripsCaseWithHyphens() {
        // Case ids contain hyphens; only the FIRST colon separates kind from id.
        let id = SpotlightID.make(kind: .legalCase, id: "demden-v-pedder-1904")
        #expect(id == "case:demden-v-pedder-1904")
        let parsed = SpotlightID.parse(id)
        #expect(parsed?.kind == .legalCase)
        #expect(parsed?.id == "demden-v-pedder-1904")
    }

    @Test func rejectsUnknownOrMalformed() {
        #expect(SpotlightID.parse("widget:1") == nil)
        #expect(SpotlightID.parse("nocolon") == nil)
    }
}
