import SwiftUI

struct SortResultView: View {
    let categoryStats: [FileCategory: Int]
    let totalFiles: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.appSuccess)
                        .scaleEffect(showConfetti ? 1.0 : 0.5)
                        .animation(.spring(response: 0.5), value: showConfetti)

                    Text("All Sorted!")
                        .font(.title.bold())
                        .foregroundColor(.appTextPrimary)

                    Text("\(totalFiles) files organized")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(FileCategory.allCases.filter { categoryStats[$0] != nil }, id: \.self) { category in
                            VStack(spacing: 6) {
                                Image(systemName: category.systemImageName)
                                    .font(.title2)
                                    .foregroundColor(Color(hex: category.colorHex))
                                Text(category.displayName)
                                    .font(.caption)
                                    .foregroundColor(.appTextPrimary)
                                Text("\(categoryStats[category] ?? 0)")
                                    .font(.title3.bold())
                                    .foregroundColor(Color(hex: category.colorHex))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: category.colorHex).opacity(0.08))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Sort Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                showConfetti = true
            }
        }
    }
}
