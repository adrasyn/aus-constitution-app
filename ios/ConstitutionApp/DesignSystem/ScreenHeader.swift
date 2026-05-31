import SwiftUI

/// Serif H1 + optional sans subtitle, shown at the top of a screen's scroll
/// content (the native nav bar uses an inline title alongside this).
struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFont.screenTitle)
                .foregroundStyle(Color.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(AppFont.subtitle)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
