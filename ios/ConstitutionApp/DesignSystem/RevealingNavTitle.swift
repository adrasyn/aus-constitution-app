import SwiftUI

private struct RevealNavTitleModifier: ViewModifier {
    let title: String
    @State private var revealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y > 44
            } action: { _, newValue in
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                    revealed = newValue
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(AppFont.navTitle)
                        .foregroundStyle(Color.textPrimary)
                        .opacity(revealed ? 1 : 0)
                        .accessibilityHidden(!revealed)
                }
            }
    }
}

extension View {
    /// Hides the nav-bar title at rest (the serif body heading is the hero) and
    /// fades `title` into the bar once the content scrolls up. Back button is
    /// chevron-only.
    func revealingNavigationTitle(_ title: String) -> some View {
        modifier(RevealNavTitleModifier(title: title))
    }
}
