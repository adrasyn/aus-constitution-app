import Foundation

/// Grouped search results, one bucket per content type.
public struct SearchResults: Sendable, Equatable {
    public var sections: [Section] = []
    public var cases: [Case] = []
    public var referendums: [Referendum] = []
    public var documents: [HistoricalDocument] = []

    public var totalCount: Int {
        sections.count + cases.count + referendums.count + documents.count
    }
    public var isEmpty: Bool { totalCount == 0 }
}

/// In-memory full-text-ish search over all content. Built once from a
/// `ContentStore`; precomputes a lowercased searchable string per item.
/// A query matches an item when every whitespace-separated token appears
/// (case-insensitive substring) in that item's searchable text.
public struct SearchIndex: Sendable {
    private let sectionDocs: [(text: String, item: Section)]
    private let caseDocs: [(text: String, item: Case)]
    private let referendumDocs: [(text: String, item: Referendum)]
    private let documentDocs: [(text: String, item: HistoricalDocument)]

    public init(store: ContentStore) {
        sectionDocs = store.sections.map {
            (Self.corpus([$0.title, $0.content, "section \($0.number)"]), $0)
        }
        caseDocs = store.cases.map {
            (Self.corpus([$0.name, $0.shortName ?? "", $0.citation, $0.principle, $0.content]), $0)
        }
        referendumDocs = store.referendums.map {
            (Self.corpus([$0.title, $0.question, $0.content, String($0.year)]), $0)
        }
        documentDocs = store.documents.map {
            (Self.corpus([$0.title, $0.description, $0.content, String($0.year)]), $0)
        }
    }

    public func search(_ query: String) -> SearchResults {
        let tokens = query.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
        guard !tokens.isEmpty else { return SearchResults() }
        func matches(_ text: String) -> Bool { tokens.allSatisfy { text.contains($0) } }
        return SearchResults(
            sections: sectionDocs.filter { matches($0.text) }.map(\.item),
            cases: caseDocs.filter { matches($0.text) }.map(\.item),
            referendums: referendumDocs.filter { matches($0.text) }.map(\.item),
            documents: documentDocs.filter { matches($0.text) }.map(\.item)
        )
    }

    private static func corpus(_ parts: [String]) -> String {
        parts.joined(separator: " ").lowercased()
    }
}
