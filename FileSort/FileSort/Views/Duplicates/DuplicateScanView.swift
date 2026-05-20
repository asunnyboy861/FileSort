import SwiftUI

struct DuplicateScanView: View {
    let files: [ScannedFile]
    @State private var duplicateVM = DuplicateViewModel()
    @Environment(PurchaseManager.self) private var purchaseManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if duplicateVM.isScanning {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Scanning for duplicates...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else if duplicateVM.duplicateGroups.isEmpty && !files.isEmpty {
                    noDuplicatesView
                } else {
                    summarySection
                    duplicateGroupsSection
                    if !duplicateVM.selectedForDeletion.isEmpty {
                        deleteButton
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Duplicates")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if purchaseManager.isPremium {
                await duplicateVM.scanForDuplicates(in: files)
            }
        }
        .overlay {
            if !purchaseManager.isPremium {
                paywallOverlay
            }
        }
    }

    private var noDuplicatesView: some View {
        ContentUnavailableView("No Duplicates Found", systemImage: "checkmark.circle.fill", description: Text("All files are unique"))
    }

    private var summarySection: some View {
        HStack(spacing: 20) {
            VStack {
                Text("\(duplicateVM.duplicateCount)")
                    .font(.title.bold())
                    .foregroundStyle(.orange)
                Text("Duplicates")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            VStack {
                Text(duplicateVM.formattedWastedSpace)
                    .font(.title2.bold())
                    .foregroundStyle(.red)
                Text("Wasted Space")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var duplicateGroupsSection: some View {
        VStack(spacing: 12) {
            ForEach(duplicateVM.duplicateGroups) { group in
                DuplicateGroupCard(group: group, selectedForDeletion: duplicateVM.selectedForDeletion, onToggle: { url in
                    duplicateVM.toggleSelection(url: url)
                }, onKeepFirst: {
                    if let first = group.files.first {
                        duplicateVM.selectDuplicatesInGroup(group, keeping: first)
                    }
                })
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            Task { let _ = await duplicateVM.deleteSelected() }
        } label: {
            Label("Delete \(duplicateVM.selectedForDeletion.count) Selected", systemImage: "trash")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .controlSize(.large)
    }

    private var paywallOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                Text("Premium Feature")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Upgrade to find and remove duplicate files")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                NavigationLink {
                    PaywallView()
                } label: {
                    Text("Upgrade to Pro")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
    }
}

struct DuplicateGroupCard: View {
    let group: DuplicateGroup
    let selectedForDeletion: Set<URL>
    let onToggle: (URL) -> Void
    let onKeepFirst: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.on.doc.fill")
                    .foregroundStyle(.orange)
                Text("\(group.files.count) identical files")
                    .font(.subheadline.bold())
                Spacer()
                Text(group.formattedWastedSpace)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            Button("Keep first, select rest") {
                onKeepFirst()
            }
            .font(.caption)
            .foregroundStyle(.blue)
            ForEach(group.files) { file in
                HStack {
                    Image(systemName: selectedForDeletion.contains(file.url) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selectedForDeletion.contains(file.url) ? .red : .gray)
                        .onTapGesture { onToggle(file.url) }
                    VStack(alignment: .leading) {
                        Text(file.url.lastPathComponent)
                            .font(.caption)
                        Text(file.formattedSize)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
