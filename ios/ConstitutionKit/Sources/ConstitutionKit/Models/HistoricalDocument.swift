import Foundation

public struct HistoricalDocument: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let year: Int
    public let description: String
    public let content: String
    public let relatedSections: [String]
    public let sourceUrl: String?

    private enum CodingKeys: String, CodingKey {
        case id, title, year, description, content, relatedSections, sourceUrl
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        year = try c.decode(Int.self, forKey: .year)
        description = try c.decode(String.self, forKey: .description)
        content = try c.decode(String.self, forKey: .content)
        relatedSections = try c.decodeIfPresent([String].self, forKey: .relatedSections) ?? []
        sourceUrl = try c.decodeIfPresent(String.self, forKey: .sourceUrl)
    }
}
