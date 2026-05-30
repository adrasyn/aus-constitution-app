import Foundation

public struct Section: Identifiable, Codable, Hashable, Sendable {
    /// Raw number field from JSON — most sections are integers ("51", "0") but some
    /// are alphanumeric ("105A") or named ("schedule"). Stored as String to preserve
    /// the original value and avoid routing collisions.
    public let number: String
    public let title: String
    public let chapter: Int
    public let content: String
    public let relatedCases: [String]
    public let relatedReferendums: [String]
    public let relatedDocuments: [String]
    public let notes: String?

    /// Canonical id used across the app and matching the web app's routing.
    public var id: String { "s\(number)" }

    private enum CodingKeys: String, CodingKey {
        case number, title, chapter, content
        case relatedCases, relatedReferendums, relatedDocuments, notes
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // The JSON has mixed types: integers for most sections, strings for others
        // (e.g. "105A", "schedule"). Decode as String by normalising int → string.
        if let intNumber = try? c.decode(Int.self, forKey: .number) {
            number = String(intNumber)
        } else {
            number = try c.decode(String.self, forKey: .number)
        }
        title = try c.decode(String.self, forKey: .title)
        chapter = try c.decode(Int.self, forKey: .chapter)
        content = try c.decode(String.self, forKey: .content)
        relatedCases = try c.decodeIfPresent([String].self, forKey: .relatedCases) ?? []
        relatedReferendums = try c.decodeIfPresent([String].self, forKey: .relatedReferendums) ?? []
        relatedDocuments = try c.decodeIfPresent([String].self, forKey: .relatedDocuments) ?? []
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
    }
}
