import Foundation

/// Formats content items into shareable plain text (title, key metadata, an
/// excerpt, and attribution).
public enum ShareText {
    private static let attribution = "— Australian Constitution"
    private static let excerptLimit = 280

    public static func section(_ s: Section) -> String {
        let label = s.number == "0" ? "Preamble" : "Section \(s.number)"
        return "\(label) — \(s.title)\n\n\(excerpt(s.content))\n\n\(attribution)"
    }

    public static func legalCase(_ c: Case) -> String {
        "\(c.name)\n\(c.citation) · \(c.court), \(c.year)\n\n\(excerpt(c.principle))\n\n\(attribution)"
    }

    public static func referendum(_ r: Referendum) -> String {
        "\(r.title) (\(r.year)) — \(r.outcome.capitalized)\n\n\(excerpt(r.question))\n\n\(attribution)"
    }

    public static func document(_ d: HistoricalDocument) -> String {
        "\(d.title) (\(d.year))\n\n\(excerpt(d.description))\n\n\(attribution)"
    }

    private static func excerpt(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > excerptLimit else { return trimmed }
        let end = trimmed.index(trimmed.startIndex, offsetBy: excerptLimit)
        return trimmed[..<end].trimmingCharacters(in: .whitespaces) + "…"
    }
}
