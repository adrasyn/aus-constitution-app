import SwiftUI
import ConstitutionKit

@main
struct ConstitutionApp: App {
    let store = ContentStore.bundled()

    var body: some Scene {
        WindowGroup {
            RootTabView(store: store)
                .tint(.accentGreen)
        }
    }
}
