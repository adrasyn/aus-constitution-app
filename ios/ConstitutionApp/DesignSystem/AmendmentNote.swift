import SwiftUI

/// Burgundy-tinted note box with a leading stripe, for a section's amendment note.
struct AmendmentNote: View {
    let text: String
    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(Color.accentBurgundy).frame(width: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text("NOTE")
                    .font(AppFont.badge)
                    .tracking(0.5)
                    .foregroundStyle(Color.accentBurgundy)
                Text(text)
                    .font(AppFont.body)
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.tintBurgundy)
        .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 6, topTrailingRadius: 6))
    }
}
