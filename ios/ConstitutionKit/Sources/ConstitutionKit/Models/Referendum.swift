import Foundation

public struct Referendum: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let year: Int
    public let date: String?
    public let title: String
    public let question: String
    public let outcome: String
    public let yesPercentage: Double
    public let statesFor: Int?
    public let statesAgainst: Int?
    public let content: String
    public let relatedSections: [String]

    private enum CodingKeys: String, CodingKey {
        case id, year, date, title, question, outcome
        case yesPercentage, statesFor, statesAgainst, content, relatedSections
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        year = try c.decode(Int.self, forKey: .year)
        date = try c.decodeIfPresent(String.self, forKey: .date)
        title = try c.decode(String.self, forKey: .title)
        question = try c.decode(String.self, forKey: .question)
        outcome = try c.decode(String.self, forKey: .outcome)
        yesPercentage = try c.decode(Double.self, forKey: .yesPercentage)
        statesFor = try c.decodeIfPresent(Int.self, forKey: .statesFor)
        statesAgainst = try c.decodeIfPresent(Int.self, forKey: .statesAgainst)
        content = try c.decode(String.self, forKey: .content)
        relatedSections = try c.decodeIfPresent([String].self, forKey: .relatedSections) ?? []
    }
}
