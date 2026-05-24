import SwiftUI
import SwiftData

struct SortPreviewView: View {
    let scannedFiles: [ScannedFile]
    let sourceDirectory: URL?
    @State private var sortVM = SortViewModel()
    @State private var navigateToResult = false
    @State private var showPaywall = false
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchaseManager.self) private var purchaseManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if sortVM.isSorting {
                    ProgressView("Generating sort plan...")
                        .padding()
                } else if sortVM.sortResult != nil {
                    Color.clear
                        .navigationDestination(isPresented: $navigateToResult) {
                            SortResultView(
                                successCount: sortVM.sortResult?.successCount ?? 0,
                                failCount: sortVM.sortResult?.failCount ?? 0,
                                totalFiles: sortVM.sortResult?.totalFiles ?? 0,
                                failedFiles: sortVM.sortResult?.failedFiles ?? []
                            )
                        }
                        .hidden()
                } else if sortVM.sortActions.isEmpty {
                    planGenerationPrompt
                } else {
                    sortPlanSection
                    conflictSection
                    executeButton
                }
            }
            .padding()
        }
        .navigationTitle("Sort Preview")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if sortVM.sortActions.isEmpty {
                await generatePlan()
            }
        }
    }

    private var planGenerationPrompt: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Analyzing files and matching rules...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var sortPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sort Plan")
                    .font(.headline)
                Spacer()
                Text("\(sortVM.sortActions.count) files")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(FileCategory.allCases, id: \.self) { category in
                let actions = sortVM.sortActions.filter { $0.file.category == category }
                if !actions.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: category.systemImage)
                            Text(category.displayName)
                                .font(.subheadline.bold())
                            Text("(\(actions.count))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ForEach(actions) { action in
                            SortActionRow(action: action)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var conflictSection: some View {
        Group {
            if sortVM.hasConflicts {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("\(sortVM.conflicts.count) Conflicts Found")
                            .font(.subheadline.bold())
                    }
                    Picker("Resolution", selection: $sortVM.conflictResolution) {
                        Text("Rename").tag(Conflict.ConflictResolution.rename)
                        Text("Skip").tag(Conflict.ConflictResolution.skip)
                        Text("Overwrite").tag(Conflict.ConflictResolution.overwrite)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var executeButton: some View {
        VStack(spacing: 12) {
            if purchaseManager.canSortFree() {
                Button {
                    Task {
                        await sortVM.executeSort(modelContext: modelContext)
                        if sortVM.sortResult != nil {
                            purchaseManager.consumeFreeSort()
                            navigateToResult = true
                        }
                    }
                } label: {
                    Label("Execute Sort", systemImage: "arrow.triangle.branch")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(sortVM.isSorting)
                if !purchaseManager.isPremium && purchaseManager.freeSortsRemaining > 0 {
                    Text("Uses 1 of \(purchaseManager.freeSortsRemaining) free sort\(purchaseManager.freeSortsRemaining == 1 ? "" : "s") left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    Label("Upgrade to Sort — Pro", systemImage: "crown.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                Text("You've used all \(AppConstants.Limits.freeMonthlySorts) free sorts this month")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView()
            }
        }
    }

    private func generatePlan() async {
        guard let sourceDir = sourceDirectory else { return }
        var rules = (try? modelContext.fetch(FetchDescriptor<SortRule>())) ?? []
        if rules.isEmpty {
            let ruleVM = RuleEngineViewModel()
            ruleVM.createDefaultRules(modelContext: modelContext)
            rules = (try? modelContext.fetch(FetchDescriptor<SortRule>())) ?? []
        }
        await sortVM.generateSortPlan(files: scannedFiles, rules: rules, targetBaseURL: sourceDir)
    }
}

struct SortActionRow: View {
    let action: SortAction

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: action.file.category.systemImage)
                .font(.caption)
                .foregroundStyle(.blue)
            Text(action.file.url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)
            Spacer()
            Image(systemName: "arrow.right")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(action.destinationURL.deletingLastPathComponent().lastPathComponent)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
    }
}
