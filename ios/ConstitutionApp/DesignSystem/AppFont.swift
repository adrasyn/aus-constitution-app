import SwiftUI

/// Typography tokens mirroring the web app: Georgia serif for titles and
/// reading, the system sans for UI text, system monospaced for numerics.
/// All scale with Dynamic Type via `relativeTo:`.
enum AppFont {
    static let screenTitle = Font.custom("Georgia", size: 28, relativeTo: .largeTitle)
    static let cardTitle = Font.custom("Georgia", size: 17, relativeTo: .headline)
    static let readingTitle = Font.custom("Georgia", size: 24, relativeTo: .title)
    static let readingBody = Font.custom("Georgia", size: 17, relativeTo: .body)
    static let subtitle = Font.subheadline
    static let body = Font.subheadline
    static let badge = Font.system(.caption2, design: .default).weight(.semibold)
    static let mono = Font.system(.caption, design: .monospaced)
    static let monoSmall = Font.system(.caption2, design: .monospaced)
}
