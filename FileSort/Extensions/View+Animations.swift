import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
    }

    func proBadge() -> some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.caption2)
            Text("PRO")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.appSecondary)
        .cornerRadius(4)
    }

    func shimmer(active: Bool) -> some View {
        self.opacity(active ? 0.6 : 1.0)
            .animation(active ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: active)
    }
}
