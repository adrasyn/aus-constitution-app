import SwiftUI

/// A row of selectable pills (filter or sort). The selected pill fills with its
/// `activeColor`; others are outlined.
struct FilterPills<Value: Hashable>: View {
    struct Option: Identifiable {
        let id = UUID()
        let title: String
        let value: Value
        var activeColor: Color = .textPrimary
    }

    let options: [Option]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options) { option in
                let isActive = option.value == selection
                Button {
                    selection = option.value
                } label: {
                    Text(option.title)
                        .font(AppFont.subtitle.weight(.medium))
                        .foregroundStyle(isActive ? Color.white : Color.textSecondary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(isActive ? option.activeColor : Color.appBackground, in: Capsule())
                        .overlay(Capsule().stroke(Color.cardBorder, lineWidth: isActive ? 0 : 0.5))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
