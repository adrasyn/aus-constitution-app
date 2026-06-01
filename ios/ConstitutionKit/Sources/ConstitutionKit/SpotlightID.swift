import Foundation

/// The content kinds exposed to Spotlight.
public enum SpotlightKind: String, Sendable {
    case section
    case legalCase = "case"
}

/// Encodes/decodes a Spotlight unique identifier as `"<kind>:<id>"`. Content
/// ids may contain hyphens, so decoding splits on the FIRST colon only.
public enum SpotlightID {
    public static func make(kind: SpotlightKind, id: String) -> String {
        "\(kind.rawValue):\(id)"
    }

    public static func parse(_ identifier: String) -> (kind: SpotlightKind, id: String)? {
        let parts = identifier.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2,
              let kind = SpotlightKind(rawValue: String(parts[0])),
              !parts[1].isEmpty
        else { return nil }
        return (kind, String(parts[1]))
    }
}
