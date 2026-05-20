import SwiftUI

struct CelebrationView: View {
    let movedCount: Int
    let savedSpace: String
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.green.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)
                    .scaleEffect(scale)
            }
            Text("All Sorted!")
                .font(.title.bold())
            VStack(spacing: 4) {
                Text("\(movedCount) files organized")
                    .font(.headline)
                Text("Space reclaimed: \(savedSpace)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                scale = 1.0
            }
        }
    }
}

struct StatsCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
