import Foundation

public struct Chapter: Identifiable, Codable, Hashable, Sendable {
    public struct Part: Codable, Hashable, Sendable {
        public let number: Int
        public let title: String
        public let sections: [Int]
    }

    public let number: Int
    public let title: String
    public let slug: String
    public let parts: [Part]
    public let sections: [Int]

    public var id: Int { number }

    /// Section ids in order: from parts when present, else the flat `sections`.
    public var sectionIDs: [String] {
        let nums = parts.isEmpty ? sections : parts.flatMap(\.sections)
        return nums.map { "s\($0)" }
    }

    private enum CodingKeys: String, CodingKey {
        case number, title, slug, parts, sections
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        number = try c.decode(Int.self, forKey: .number)
        title = try c.decode(String.self, forKey: .title)
        slug = try c.decode(String.self, forKey: .slug)
        parts = try c.decodeIfPresent([Part].self, forKey: .parts) ?? []
        sections = try c.decodeIfPresent([Int].self, forKey: .sections) ?? []
    }
}
