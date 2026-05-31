import Foundation
import ConstitutionKit

extension ContentStore {
    /// Loads content from the `content/` folder reference inside the app bundle.
    static func bundled() -> ContentStore {
        guard let resourceURL = Bundle.main.resourceURL else {
            fatalError("Missing app bundle resourceURL")
        }
        do {
            return try ContentStore(contentDirectory: resourceURL.appending(path: "content"))
        } catch {
            fatalError("Failed to load bundled content: \(error)")
        }
    }
}
