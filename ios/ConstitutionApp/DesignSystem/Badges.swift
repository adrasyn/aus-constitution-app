import SwiftUI

/// Monospace year chip on the surface colour.
struct YearBadge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(AppFont.monoSmall)
            .foregroundStyle(Color.textSecondary)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 4))
    }
}

/// Uppercase tinted outcome badge (e.g. CARRIED / DEFEATED).
struct OutcomeBadge: View {
    let text: String
    let foreground: Color
    let background: Color
    var body: some View {
        Text(text.uppercased())
            .font(AppFont.badge)
            .tracking(0.5)
            .foregroundStyle(foreground)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(background, in: Capsule())
    }
}
