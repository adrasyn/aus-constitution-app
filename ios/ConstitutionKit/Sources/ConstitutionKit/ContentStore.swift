import Foundation

/// Loads all bundled content once and exposes id lookups and relational
/// helpers. Immutable after construction; safe to share.
public struct ContentStore: Sendable {
    public let chapters: [Chapter]
    public let sections: [Section]
    public let cases: [Case]
    public let referendums: [Referendum]
    public let documents: [HistoricalDocument]

    private let sectionsByID: [String: Section]
    private let casesByID: [String: Case]
    private let referendumsByID: [String: Referendum]
    private let documentsByID: [String: HistoricalDocument]
    private let chaptersBySlug: [String: Chapter]

    /// Loads the five JSON files from a directory that contains the standard
    /// `content/` subtree (works for both the app bundle and the repo source).
    public init(contentDirectory dir: URL) throws {
        let decoder = JSONDecoder()
        func load<T: Decodable>(_ path: String, as type: [T].Type) throws -> [T] {
            let data = try Data(contentsOf: dir.appending(path: path))
            return try decoder.decode([T].self, from: data)
        }

        chapters = try load("constitution/chapters.json", as: [Chapter].self)
        sections = try load("constitution/sections.json", as: [Section].self)
        cases = try load("cases/cases.json", as: [Case].self)
        referendums = try load("referendums/referendums.json", as: [Referendum].self)
        documents = try load("documents/documents.json", as: [HistoricalDocument].self)

        sectionsByID = Dictionary(uniqueKeysWithValues: sections.map { ($0.id, $0) })
        casesByID = Dictionary(uniqueKeysWithValues: cases.map { ($0.id, $0) })
        referendumsByID = Dictionary(uniqueKeysWithValues: referendums.map { ($0.id, $0) })
        documentsByID = Dictionary(uniqueKeysWithValues: documents.map { ($0.id, $0) })
        chaptersBySlug = Dictionary(uniqueKeysWithValues: chapters.map { ($0.slug, $0) })
    }

    // MARK: Lookups
    public func section(id: String) -> Section? { sectionsByID[id] }

    /// Resolves a section reference to its base section. References may be
    /// canonical ids ("s51"), bare numbers ("51"), alphanumeric ("105A"), or
    /// legal sub-paragraph citations ("51(ii)", "s75(v)") as used in case data.
    /// Mirrors the web app's section-link base-section extraction.
    public func section(reference ref: String) -> Section? {
        if let exact = sectionsByID[ref] { return exact }
        if let withPrefix = sectionsByID["s\(ref)"] { return withPrefix }
        let bare = ref.hasPrefix("s") ? String(ref.dropFirst()) : ref
        guard let base = Self.baseSectionToken(bare) else { return nil }
        return sectionsByID["s\(base)"]
    }

    public func `case`(id: String) -> Case? { casesByID[id] }
    public func referendum(id: String) -> Referendum? { referendumsByID[id] }
    public func document(id: String) -> HistoricalDocument? { documentsByID[id] }
    public func chapter(slug: String) -> Chapter? { chaptersBySlug[slug] }

    // MARK: Relations
    public func sections(for chapter: Chapter) -> [Section] {
        chapter.sectionIDs.compactMap { sectionsByID[$0] }
    }
    public func cases(for section: Section) -> [Case] {
        section.relatedCases.compactMap { casesByID[$0] }
    }
    public func referendums(for section: Section) -> [Referendum] {
        section.relatedReferendums.compactMap { referendumsByID[$0] }
    }
    public func documents(for section: Section) -> [HistoricalDocument] {
        section.relatedDocuments.compactMap { documentsByID[$0] }
    }

    // MARK: Private

    /// Leading digits plus an optional single uppercase letter, ignoring any
    /// trailing characters: "51(ii)" -> "51", "105A" -> "105A", "75(v)" -> "75",
    /// "(ii)" -> nil. Lowercase or extra trailing characters are dropped.
    private static func baseSectionToken(_ s: String) -> String? {
        var result = ""
        var rest = Substring(s)
        while let ch = rest.first, ch.isNumber {
            result.append(ch)
            rest = rest.dropFirst()
        }
        guard !result.isEmpty else { return nil }
        if let ch = rest.first, ch.isUppercase {
            result.append(ch)
        }
        return result
    }
}
