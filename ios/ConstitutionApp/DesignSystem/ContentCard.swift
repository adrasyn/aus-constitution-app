import SwiftUI

/// The signature parchment card: a 3pt leading accent stripe, hairline border,
/// and trailing-rounded corners. Content is laid out leading-aligned.
struct ContentCard<Content: View>: View {
    var accent: Color = .accentGreen
    @ViewBuilder var content: Content

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0,
                               bottomTrailingRadius: 8, topTrailingRadius: 8)
    }

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(accent).frame(width: 3)
            VStack(alignment: .leading, spacing: 6) { content }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .clipShape(shape)
        .overlay(shape.stroke(Color.cardBorder, lineWidth: 0.5))
    }
}
