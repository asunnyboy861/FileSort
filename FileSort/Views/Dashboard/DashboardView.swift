import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SortRule.priority, order: .reverse) private var rules: [SortRule]
    @State private var viewModel = DashboardViewModel()
    @State private var showDocumentPicker = false
    @State private var showProUpgrade = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedDirectoryBookmark") private var directoryBookmarkData: Data?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    messyCountCard
                    if viewModel.isScanning {
                        ProgressView("Scanning...")
                            .padding()
                    } else if viewModel.scannedFiles.isEmpty {
                        emptyStateView
                    } else {
                        categoryBreakdown
                        sortActionsPreview
                    }
                    if viewModel.isSorting {
                        sortingProgressView
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("FileSort")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDocumentPicker = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.canUndo {
                        Button {
                            Task { await viewModel.undoLast() }
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                        }
                    }
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    Task {
                        viewModel.selectedDirectory = url
                        await viewModel.saveBookmark(for: url)
                        await viewModel.scanDirectory(url)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showPreview) {
                SortPreviewView(actions: viewModel.sortActions) {
                    Task { await viewModel.executeSort(modelContext: modelContext) }
                }
            }
            .sheet(isPresented: $viewModel.showResult) {
                SortResultView(categoryStats: viewModel.categoryStats, totalFiles: viewModel.sortActions.count)
            }
            .sheet(isPresented: $viewModel.showDuplicateView) {
                DuplicateListView(groups: viewModel.duplicateGroups) { file in
                    Task { await viewModel.deleteDuplicate(file) }
                }
            }
            .sheet(isPresented: $showProUpgrade) {
                ProUpgradeView()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
    }

    private var messyCountCard: some View {
        VStack(spacing: 12) {
            Text("\(viewModel.messyFileCount)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.appPrimary, .appSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            Text(viewModel.messyFileCount == 1 ? "Messy File Found" : "Messy Files Found")
                .font(.headline)
                .foregroundColor(.appTextSecondary)

            if viewModel.messyFileCount > 0 {
                Button {
                    if !viewModel.isPro && viewModel.messyFileCount > viewModel.freeFileLimit {
                        showProUpgrade = true
                    } else {
                        Task {
                            guard let dir = viewModel.selectedDirectory else { return }
                            await viewModel.prepareSort(rules: rules, baseDirectory: dir)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                        Text("Sort Now")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [.appPrimary, .appSecondary], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                }
                .padding(.top, 4)

                if !viewModel.isPro && viewModel.messyFileCount > viewModel.freeFileLimit {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("Free tier: \(viewModel.freeFileLimit) files max")
                            .font(.caption)
                    }
                    .foregroundColor(.appSecondary)
                }
            }
        }
        .padding(24)
        .cardStyle()
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.appTextSecondary)
            Text("Select a folder to start sorting")
                .font(.headline)
                .foregroundColor(.appTextSecondary)
            Text("Tap the folder icon in the top right to choose a directory")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("File Categories")
                .font(.headline)
                .foregroundColor(.appTextPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(FileCategory.allCases.filter { viewModel.categoryStats[$0] != nil }, id: \.self) { category in
                    HStack(spacing: 8) {
                        Image(systemName: category.systemImageName)
                            .foregroundColor(Color(hex: category.colorHex))
                            .font(.title3)
                        VStack(alignment: .leading) {
                            Text(category.displayName)
                                .font(.caption)
                                .foregroundColor(.appTextPrimary)
                            Text("\(viewModel.categoryStats[category] ?? 0) files")
                                .font(.caption2)
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: category.colorHex).opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    private var sortActionsPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Preview")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                Spacer()
                if viewModel.isPro {
                    Button {
                        Task { await viewModel.findDuplicates() }
                    } label: {
                        Label("Duplicates", systemImage: "doc.on.doc.fill")
                            .font(.caption)
                            .foregroundColor(.appSecondary)
                    }
                }
            }

            ForEach(viewModel.sortActions.prefix(5)) { action in
                HStack {
                    Image(systemName: action.category.systemImageName)
                        .foregroundColor(Color(hex: action.category.colorHex))
                    Text(action.file.name)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                    Text(action.category.folderName)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                    if action.isConflict {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.appWarning)
                    }
                }
                .padding(.vertical, 4)
            }
            if viewModel.sortActions.count > 5 {
                Text("+\(viewModel.sortActions.count - 5) more files")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding()
        .cardStyle()
    }

    private var sortingProgressView: some View {
        VStack(spacing: 16) {
            ProgressView(value: viewModel.sortProgress)
                .progressViewStyle(.linear)
                .tint(.appPrimary)
            Text("Sorting files... \(Int(viewModel.sortProgress * 100))%")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
        }
        .padding()
        .cardStyle()
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder], asCopy: false)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                let _ = url.startAccessingSecurityScopedResource()
                onPick(url)
            }
        }
    }
}
