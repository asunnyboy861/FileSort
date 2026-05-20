import SwiftUI

struct DashboardView: View {
    @State private var scannerVM = ScannerViewModel()
    @State private var showDirectoryPicker = false
    @State private var showSortPreview = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(PurchaseManager.self) private var purchaseManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroSection
                    if scannerVM.isScanning {
                        ProgressView("Scanning files...")
                            .padding()
                    } else if let error = scannerVM.scanError {
                        errorBanner(error)
                    } else if scannerVM.scannedFiles.isEmpty {
                        emptyState
                    } else {
                        scanResultsSection
                        quickActionsSection
                    }
                }
                .padding()
            }
            .navigationTitle("FileSort")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showDirectoryPicker) {
                DirectoryPickerView { url in
                    Task { await scannerVM.scanDirectory(url) }
                }
            }
            .navigationDestination(isPresented: $showSortPreview) {
                SortPreviewView(scannedFiles: scannerVM.scannedFiles, sourceDirectory: scannerVM.selectedDirectory)
            }
            .fullScreenCover(isPresented: Binding(get: { !hasSeenOnboarding }, set: { hasSeenOnboarding = $0 })) {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.gearshape.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
            Text("Sort Files Instantly")
                .font(.title2.bold())
            Text("Select a folder to scan and organize your files automatically")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showDirectoryPicker = true
            } label: {
                Label("Select Folder", systemImage: "folder.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var emptyState: some View {
        ContentUnavailableView("No Files Scanned", systemImage: "doc.text.magnifyingglass", description: Text("Select a folder to start scanning"))
    }

    private var scanResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scan Results")
                    .font(.headline)
                Spacer()
                Text("\(scannerVM.scannedFiles.count) files")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(scannerVM.categoryBreakdown, id: \.category) { item in
                    CategoryCard(category: item.category, count: item.count, percentage: item.percentage)
                }
            }
            HStack {
                Image(systemName: "internaldrive.fill")
                Text("Total Size: \(scannerVM.formattedTotalSize)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Button {
                showSortPreview = true
            } label: {
                Label("Sort Now", systemImage: "arrow.triangle.branch")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            NavigationLink {
                DuplicateScanView(files: scannerVM.scannedFiles)
            } label: {
                Label("Find Duplicates", systemImage: "doc.on.doc.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!purchaseManager.isPremium)
            Button {
                scannerVM.clearResults()
            } label: {
                Label("Clear Results", systemImage: "trash")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
        }
        .padding()
        .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct CategoryCard: View {
    let category: FileCategory
    let count: Int
    let percentage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: category.systemImage)
                    .foregroundStyle(.blue)
                Text(category.displayName)
                    .font(.subheadline.bold())
            }
            Text("\(count) files")
                .font(.caption)
                .foregroundStyle(.secondary)
            ProgressView(value: percentage, total: 100)
                .tint(.blue)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
    }
}
