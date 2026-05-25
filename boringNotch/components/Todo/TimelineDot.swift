import SwiftUI

struct TimelineDot: View {
    let color: Color
    let isCompleted: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.gray.opacity(0.3) : color)
                .frame(width: 10, height: 10)
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 24)
    }
}
