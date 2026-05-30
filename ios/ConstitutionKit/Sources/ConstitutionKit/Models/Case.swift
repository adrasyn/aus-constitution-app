import Foundation

public struct Case: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let shortName: String?
    public let year: Int
    public let court: String
    public let citation: String
    public let principle: String
    public let outcome: String
    public let content: String
    public let relatedSections: [String]
    public let relatedCases: [String]
    public let sourceUrl: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, shortName, year, court, citation
        case principle, outcome, content, relatedSections, relatedCases, sourceUrl
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        shortName = try c.decodeIfPresent(String.self, forKey: .shortName)
        year = try c.decode(Int.self, forKey: .year)
        court = try c.decode(String.self, forKey: .court)
        citation = try c.decode(String.self, forKey: .citation)
        principle = try c.decode(String.self, forKey: .principle)
        outcome = try c.decode(String.self, forKey: .outcome)
        content = try c.decode(String.self, forKey: .content)
        relatedSections = try c.decodeIfPresent([String].self, forKey: .relatedSections) ?? []
        relatedCases = try c.decodeIfPresent([String].self, forKey: .relatedCases) ?? []
        sourceUrl = try c.decodeIfPresent(String.self, forKey: .sourceUrl)
    }
}
