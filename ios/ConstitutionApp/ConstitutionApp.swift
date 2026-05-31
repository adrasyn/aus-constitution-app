import SwiftUI
import ConstitutionKit

@main
struct ConstitutionApp: App {
    let store = ContentStore.bundled()

    var body: some Scene {
        WindowGroup {
            Text("Loaded \(store.sections.count) sections")
        }
    }
}
