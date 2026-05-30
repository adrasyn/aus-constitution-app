import Foundation

/// Absolute URL of the repo's shared `content/` directory, derived from this
/// file's location:
/// <repo>/ios/ConstitutionKit/Tests/ConstitutionKitTests/TestSupport.swift
func repoContentDirectory() -> URL {
    URL(filePath: #filePath)
        .deletingLastPathComponent()   // ConstitutionKitTests/
        .deletingLastPathComponent()   // Tests/
        .deletingLastPathComponent()   // ConstitutionKit/
        .deletingLastPathComponent()   // ios/
        .deletingLastPathComponent()   // <repo root>
        .appending(path: "content")
}

/// Raw bytes of a content file, e.g. `loadContent("constitution/sections.json")`.
func loadContent(_ relativePath: String) throws -> Data {
    try Data(contentsOf: repoContentDirectory().appending(path: relativePath))
}
