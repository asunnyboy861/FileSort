# FileSort - iOS Development Guide

## Executive Summary

**FileSort** is an iOS-native automatic file organizer that transforms chaotic iCloud Drive, Downloads, and custom folders into perfectly sorted structures with a single tap. Unlike existing file managers (Documents by Readdle, FileBrowser) that focus on browsing, FileSort creates a new category: **automatic file organizer** — open the app, see the mess, tap once, done.

**Target Audience**: iPhone/iPad users who accumulate files in Downloads/iCloud Drive and want effortless organization without manual sorting discipline.

**Key Differentiators**:
- One-tap sorting with smart recommendations (90% of users just tap "Sort Now")
- Rule engine with visual, zero-code rule editor
- Built-in duplicate file detection (SHA256)
- Deep iCloud Drive integration
- Home Screen Widget for instant sorting
- Siri Shortcuts for automation
- Celebration animations for satisfaction feedback ("数字清零" — numbers go to zero)

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Documents by Readdle | 4.8 rating, full-featured file manager, cloud integration | Feature bloat, not automated, steep learning curve, expensive IAP ($49.99-$89.99) | One-tap auto-sort vs manual browsing; zero learning curve |
| FileBrowser | 4.5 rating, network protocol support | Complex UI, $14.99 one-time, no automation | Free basic features + modern SwiftUI + auto-organize |
| Apple Files App | Built-in, free, iCloud native | No automation, no rules, no batch operations, no duplicate detection | Rule engine + auto-execution + duplicate detection + widget |
| Easy File Organizer | Simple file type mapping | macOS only, limited features | iOS native + iCloud deep integration + undo system |
| My File Organizer | Beginner-friendly | 3.0 rating, outdated UI, 3 years no update | Modern SwiftUI design + active development + widget |
| Total Files | Advanced search, PDF annotation | Ads/upselling, crashes on large files | Clean UI, stable performance, focused on organization |

## Feature Inventory (MANDATORY — Every Feature Must Be Listed)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | **File Scanner** | 1. User opens app → 2. App auto-scans selected directories → 3. Displays messy file count | Directory paths (Downloads, iCloud Drive, custom) | Traverse directory, extract file attributes (name, extension, MIME type, size, creation date, modification date, UTType tags) | ScannedFile[] with metadata | None (transient scan result) | Scan completes within 5s for 1000 files; all file types detected correctly |
| 2 | **Smart Recommendations** | 1. After scan → 2. App suggests "We found N messy files. Sort them now?" → 3. User taps "Sort Now" | ScannedFile[] from scanner | Analyze file distribution, generate default category suggestions (Documents, Images, Videos, Archives, Audio, Code) | SortAction[] with suggested destinations | None (transient suggestion) | 90%+ of common file types correctly categorized by default rules |
| 3 | **Rule Engine** | 1. User taps "Custom Rules" → 2. Creates/edits rule → 3. Sets conditions and target folder → 4. Saves rule | Rule conditions (type, name pattern, date range, size range) + target folder path | Match files against rules by priority, generate target paths, detect conflicts | SortAction[] (source→destination mappings) + Conflict[] | SwiftData SortRule entity | Rules persist across app launches; priority ordering works; conflict detection triggers |
| 4 | **File Mover** | 1. User reviews sort preview → 2. Taps "Execute" → 3. Files move to target folders → 4. Result summary shown | SortAction[] from rule engine | Execute move operations, handle conflicts (skip/rename/overwrite), record undo history | Move results (success/fail count) + undo batch | SwiftData MoveHistory entity | Files moved correctly; undo restores original state within 50 batches |
| 5 | **Duplicate Detector** | 1. User taps "Find Duplicates" → 2. App scans for duplicates → 3. Shows duplicate groups → 4. User selects which to delete | ScannedFile[] or directory scan | SHA256 hash comparison, size+modification date quick comparison | DuplicateGroup[] with file references | None (transient scan result) | SHA256 matches are true duplicates; quick comparison catches obvious duplicates |
| 6 | **Sort Result Preview** | 1. After rule matching → 2. Preview shows source→destination → 3. Conflicts highlighted → 4. User confirms or adjusts | SortAction[] + Conflict[] | Render preview list with conflict indicators | Visual preview of all pending moves | None (transient) | All moves visible before execution; conflicts clearly marked in red |
| 7 | **Home Screen Widget** | 1. User adds widget to home screen → 2. Widget shows messy file count → 3. User taps "Sort Now" on widget | Widget configuration (target directory) | Read file count from shared container, trigger sort via App Intent | Messy file count + sort trigger | UserDefaults (shared App Group) | Widget updates count within 5 minutes; tap triggers sort in app |
| 8 | **Siri Shortcuts** | 1. User creates shortcut in Shortcuts app → 2. Triggers auto-sort → 3. Shortcut runs rule engine silently | App Intent parameters (directory, rules) | Execute sort via App Intent, return result summary | Sort result (files sorted count) | App Intent donation | Shortcuts can trigger sort without opening app; result returned to Shortcuts |
| 9 | **Undo System** | 1. After sort execution → 2. User taps "Undo" → 3. All files in batch restore to original locations | MoveHistory batch ID | Reverse all moves in batch, restore original file locations | Files restored to original paths | SwiftData MoveHistory (max 50 batches) | Undo restores exact original state; works within 50-batch limit |
| 10 | **Celebration & Stats** | 1. Sort completes → 2. Celebration animation plays → 3. Stats summary shown → 4. User can share | Sort result data | Calculate stats (files by category, space organized), trigger animation | Stats view + share sheet | None (transient) | Animation plays on completion; stats accurate; share works via UIActivityViewController |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | File Scanner | Directory Selection | User picks which directories to scan (Downloads, iCloud Drive, custom paths) | Tap to select from list; + button for custom path via document picker |
| 1.2 | File Scanner | File Type Detection | System uses UTType to detect file category (document, image, video, archive, audio, code) | Automatic, no user action needed |
| 2.1 | Smart Recommendations | Default Category Mapping | Pre-configured mappings: PDF→Documents, JPG/PNG→Images, MP4→Videos, ZIP→Archives, MP3→Audio, Swift→Code | Automatic; user can modify defaults |
| 2.2 | Smart Recommendations | One-Tap Sort | Single "Sort Now" button executes all recommended sorts | Tap large button |
| 3.1 | Rule Engine | Visual Rule Editor | Drag-and-drop condition builder: IF [file type] = [PDF] AND [size] > [5MB] THEN move to [/Work/Contracts] | Tap to add condition; dropdown selectors for fields |
| 3.2 | Rule Engine | Rule Priority | Rules execute in priority order; first match wins | Drag to reorder rules |
| 3.3 | Rule Engine | Conflict Detection | When two rules match same file, or target path already exists | Visual warning badge on conflicting actions |
| 4.1 | File Mover | Move vs Copy | User can choose to move (default) or copy files | Toggle in execution confirmation |
| 4.2 | File Mover | Conflict Resolution | When target file exists: Skip / Rename / Overwrite options | Alert dialog with three choices |
| 5.1 | Duplicate Detector | Quick Comparison | Compare by file size + modification date (fast, may have false positives) | Automatic first pass |
| 5.2 | Duplicate Detector | Hash Verification | SHA256 hash comparison (slow but accurate) for files that pass quick comparison | Automatic second pass; progress indicator shown |
| 5.3 | Duplicate Detector | Batch Delete | Select and delete multiple duplicates at once | Swipe to delete or select-all + delete |
| 7.1 | Widget | Small Widget | Shows messy file count + "Sort Now" button | Tap widget to sort |
| 7.2 | Widget | Medium Widget | Shows messy count + category breakdown (Documents: N, Images: N, etc.) | Tap category to sort that type |
| 9.1 | Undo System | Batch Undo | Undo entire sort batch at once | Tap "Undo" button in history |
| 9.2 | Undo System | History Limit | Maximum 50 undo batches; oldest auto-deleted | Automatic; user sees batch count |
| 10.1 | Celebration | Confetti Animation | Lottie confetti animation on sort completion | Automatic |
| 10.2 | Celebration | Share Stats | Share "I organized N files with FileSort!" via social media | Tap share button |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Scan → Recommend | File Scanner | Smart Recommendations | ScannedFile[] | Scan completes |
| Scan → Duplicate | File Scanner | Duplicate Detector | ScannedFile[] | User taps "Find Duplicates" |
| Recommend → Preview | Smart Recommendations | Sort Result Preview | SortAction[] | Recommendations generated |
| Rules → Preview | Rule Engine | Sort Result Preview | SortAction[] + Conflict[] | Rules matched |
| Preview → Execute | Sort Result Preview | File Mover | SortAction[] | User confirms |
| Execute → Undo | File Mover | Undo System | MoveHistory batch | Sort executed |
| Execute → Celebrate | File Mover | Celebration & Stats | Sort result data | Sort completes |
| Widget → Scanner | Home Screen Widget | File Scanner | Directory config | Widget "Sort Now" tapped |
| Shortcuts → Engine | Siri Shortcuts | Rule Engine + File Mover | App Intent params | Shortcut triggered |

## Apple Design Guidelines Compliance

- **File Management Pattern**: Use system document picker for directory selection; support iCloud Drive natively via `NSUbiquitousContainerIdentifiers`
- **Privacy & Permissions**: Request `NSDocumentsFolderUsageDescription` and `NSPhotoLibraryUsageDescription` only when needed; explain purpose clearly in permission dialogs
- **Auto-Save**: Follow HIG guidance — no explicit save button needed; changes persist automatically via SwiftData
- **Quick Look**: Support Quick Look previews for files that the app cannot open directly
- **Document Launcher**: Leverage iOS 18 DocumentGroupLaunchScene for file browsing consistency
- **Widget**: Follow WidgetKit guidelines — small/medium sizes, no interactive buttons except App Intents
- **Shortcuts**: Use App Intents framework for Siri Shortcuts integration; donate intents for user discovery
- **Haptics**: Use UIImpactFeedbackGenerator for sort completion; UINotificationFeedbackGenerator for errors
- **Dark Mode**: Full support via SwiftUI automatic color scheme adaptation
- **Accessibility**: VoiceOver labels on all interactive elements; Dynamic Type support

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), WidgetKit, App Intents
- **Data Persistence**: SwiftData (SortRule, MoveHistory, FileRecord)
- **File Operations**: FileManager + Security-Scoped Bookmarks for iCloud Drive access
- **Hashing**: CryptoKit (SHA256) for duplicate detection
- **File Type Detection**: UniformTypeIdentifiers framework (UTType)
- **Animations**: Lottie for celebration effects
- **Concurrency**: Swift Structured Concurrency (async/await, Actor)

## Module Structure

```
FileSort/
├── App/
│   ├── FileSortApp.swift
│   └── AppDelegate.swift
├── Views/
│   ├── Main/
│   │   ├── MainTabView.swift
│   │   └── DashboardView.swift
│   ├── Scanner/
│   │   ├── ScanView.swift
│   │   └── ScanResultView.swift
│   ├── Rules/
│   │   ├── RuleListView.swift
│   │   ├── RuleEditView.swift
│   │   └── ConditionBuilderView.swift
│   ├── Sort/
│   │   ├── SortPreviewView.swift
│   │   ├── SortResultView.swift
│   │   └── ConflictResolutionView.swift
│   ├── Duplicates/
│   │   ├── DuplicateScanView.swift
│   │   └── DuplicateListView.swift
│   ├── History/
│   │   └── HistoryView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       ├── SortNowButton.swift
│       ├── FileCategoryIcon.swift
│       ├── CelebrationView.swift
│       └── StatsCardView.swift
├── ViewModels/
│   ├── ScannerViewModel.swift
│   ├── RuleEngineViewModel.swift
│   ├── SortViewModel.swift
│   ├── DuplicateViewModel.swift
│   └── HistoryViewModel.swift
├── Models/
│   ├── ScannedFile.swift
│   ├── SortRule.swift
│   ├── SortAction.swift
│   ├── Conflict.swift
│   ├── DuplicateGroup.swift
│   └── MoveHistory.swift
├── Services/
│   ├── FileScanService.swift
│   ├── RuleEngineService.swift
│   ├── FileMoveService.swift
│   ├── DuplicateDetectService.swift
│   ├── UndoService.swift
│   └── SecurityScopedBookmarkService.swift
├── Intents/
│   ├── SortNowIntent.swift
│   └── SortDirectoryIntent.swift
├── Widget/
│   ├── FileSortWidget.swift
│   └── FileSortWidgetBundle.swift
└── Resources/
    ├── Assets.xcassets/
    └── celebration.json
```

## Data Flow Diagram (MANDATORY — Every Feature's Data Lifecycle)

```
Feature 1: File Scanner
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Select directories (Downloads, iCloud, custom)       │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── ScannerViewModel → call FileScanService.scan()       │
│       └── FileManager.contentsOfDirectory → UTType mapping│
│       │                                                   │
│  Model/Persistence                                        │
│  └── ScannedFile[] (transient, not persisted)             │
│       │                                                   │
│  Display Output                                           │
│  └── ScanResultView: file count, category breakdown       │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── ScannedFile[] → Smart Recommendations / Duplicates   │
└───────────────────────────────────────────────────────────┘

Feature 2: Smart Recommendations
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap "Sort Now" or view recommendations              │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── ScannerViewModel → apply default category rules      │
│       └── Map UTType → category → target subfolder        │
│       │                                                   │
│  Model/Persistence                                        │
│  └── SortAction[] (transient, passed to preview)          │
│       │                                                   │
│  Display Output                                           │
│  └── DashboardView: "We found N messy files. Sort now?"   │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── SortAction[] → Sort Result Preview                   │
└───────────────────────────────────────────────────────────┘

Feature 3: Rule Engine
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Create/edit rule: conditions + target folder         │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── RuleEngineViewModel → validate rule → save           │
│       └── RuleEngineService.match(files, rules) → actions │
│       │                                                   │
│  Model/Persistence                                        │
│  └── SwiftData SortRule entity (persisted)                │
│       │                                                   │
│  Display Output                                           │
│  └── RuleListView: list of rules with priority            │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── SortAction[] + Conflict[] → Sort Result Preview      │
└───────────────────────────────────────────────────────────┘

Feature 4: File Mover
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Confirm sort preview → tap "Execute"                 │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── SortViewModel → FileMoveService.execute(actions)     │
│       └── FileManager.moveItem → handle conflicts         │
│       │                                                   │
│  Model/Persistence                                        │
│  └── SwiftData MoveHistory entity (persisted, max 50)     │
│       │                                                   │
│  Display Output                                           │
│  └── SortResultView: success/fail count + celebration     │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── MoveHistory → Undo System; Result → Celebration      │
└───────────────────────────────────────────────────────────┘

Feature 5: Duplicate Detector
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap "Find Duplicates" → select directory             │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── DuplicateViewModel → DuplicateDetectService.scan()   │
│       └── Quick compare (size+date) → SHA256 verify       │
│       │                                                   │
│  Model/Persistence                                        │
│  └── DuplicateGroup[] (transient, not persisted)          │
│       │                                                   │
│  Display Output                                           │
│  └── DuplicateListView: grouped duplicates with actions   │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Selected duplicates → File Mover (delete operation)  │
└───────────────────────────────────────────────────────────┘

Feature 6: Sort Result Preview
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Review pending moves → adjust conflicts → confirm    │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── SortViewModel → merge SortAction[] + Conflict[]      │
│       └── Render preview list with conflict indicators    │
│       │                                                   │
│  Model/Persistence                                        │
│  └── None (reads from SortAction[] + Conflict[])          │
│       │                                                   │
│  Display Output                                           │
│  └── SortPreviewView: move list with conflict badges      │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Confirmed SortAction[] → File Mover                  │
└───────────────────────────────────────────────────────────┘

Feature 7: Home Screen Widget
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Add widget → tap "Sort Now" on widget                │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── FileSortWidget (TimelineProvider) → read shared data │
│       └── Read messy file count from App Group container  │
│       │                                                   │
│  Model/Persistence                                        │
│  └── UserDefaults (shared App Group) for file count       │
│       │                                                   │
│  Display Output                                           │
│  └── Widget: messy count + "Sort Now" button              │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Tap → Open app → trigger File Scanner + Sort         │
└───────────────────────────────────────────────────────────┘

Feature 8: Siri Shortcuts
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Create shortcut in Shortcuts app → trigger sort      │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── App Intent → RuleEngineService + FileMoveService     │
│       └── Execute sort pipeline silently, return result   │
│       │                                                   │
│  Model/Persistence                                        │
│  └── SortRule (read from SwiftData) + MoveHistory (write) │
│       │                                                   │
│  Display Output                                           │
│  └── Shortcuts: result summary (files sorted count)       │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── None (self-contained execution pipeline)             │
└───────────────────────────────────────────────────────────┘

Feature 9: Undo System
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap "Undo" in history or result view                 │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── HistoryViewModel → UndoService.undo(batchId)         │
│       └── Reverse all moves in batch via FileManager      │
│       │                                                   │
│  Model/Persistence                                        │
│  └── SwiftData MoveHistory → read batch → delete record   │
│       │                                                   │
│  Display Output                                           │
│  └── HistoryView: updated list with undone batch removed  │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── None (self-contained undo operation)                 │
└───────────────────────────────────────────────────────────┘

Feature 10: Celebration & Stats
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Automatic on sort completion; tap "Share" for stats  │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── SortViewModel → calculate stats from MoveHistory     │
│       └── Count files by category, compute space saved    │
│       │                                                   │
│  Model/Persistence                                        │
│  └── None (reads from transient sort result)              │
│       │                                                   │
│  Display Output                                           │
│  └── CelebrationView: confetti + stats cards + share      │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Share → UIActivityViewController (social media)      │
└───────────────────────────────────────────────────────────┘
```

## Implementation Flow

1. **Project Setup**: Create Xcode project with SwiftUI, configure bundle ID, capabilities (iCloud, App Groups, File Access)
2. **Data Models**: Define SwiftData models (SortRule, MoveHistory, ScannedFile)
3. **File Scanner Service**: Implement directory traversal with UTType detection
4. **Rule Engine Service**: Implement rule matching with priority and conflict detection
5. **File Move Service**: Implement move/copy with security-scoped bookmarks and undo recording
6. **Duplicate Detector Service**: Implement quick compare + SHA256 verification
7. **Dashboard View**: Main screen with "Sort Now" button and messy file count
8. **Rule Editor Views**: Visual condition builder with drag-to-reorder priority
9. **Sort Preview & Result Views**: Preview before execution, celebration after
10. **Settings View**: App configuration, directory selection, policy page links
11. **Widget**: Home screen widget with App Intent for quick sort
12. **Siri Shortcuts**: App Intents for automated sorting
13. **IAP Integration**: Subscription paywall for premium features
14. **Contact Support**: Feedback form via backend URL

## UI/UX Design Specifications

- **Color Scheme**: 
  - Primary: #007AFF (iOS Blue) for main actions
  - Accent: #34C759 (Green) for success/sorted state
  - Warning: #FF9500 (Orange) for conflicts
  - Error: #FF3B30 (Red) for failures
  - Background: System background (auto dark mode)
- **Typography**: SF Pro, Dynamic Type support
  - Large Title: 34pt for dashboard headings
  - Title 2: 22pt for section headers
  - Body: 17pt for content
  - Caption: 12pt for file details
- **Layout**: 
  - Tab-based navigation: Dashboard, Rules, Duplicates, History, Settings
  - Card-based dashboard with category breakdown
  - Large "Sort Now" button (60pt height, prominent)
- **Animations**:
  - Sort progress: files "flying" into folders (matchedGeometryEffect)
  - Completion: Lottie confetti celebration
  - Number counter: animated count from N→0
  - Haptic feedback: success impact on completion
- **Iconography**: SF Symbols for file categories (doc.fill, photo.fill, film.fill, archivebox.fill, music.note, chevron.left.forwardslash.chevron.right)

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming, clear file structure
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI/Swift frameworks
- Use SwiftData for persistence (not CoreData)
- Use Swift Structured Concurrency (async/await) for file operations
- Use Security-Scoped Bookmarks for persistent iCloud Drive access
- Use UTType for file type detection (not file extension alone)
- Use CryptoKit SHA256 for duplicate detection
- Use App Intents for Shortcuts and Widget interaction
- Use App Groups for Widget shared data

## Build & Deployment Checklist

1. Verify Xcode project builds without errors
2. Verify all capabilities configured (iCloud, App Groups, File Access)
3. Verify Info.plist has all required usage descriptions
4. Verify Widget target builds and runs
5. Verify App Intents appear in Shortcuts app
6. Test on iPhone simulator (iOS 17.0+)
7. Test on iPad simulator (iOS 17.0+)
8. Verify iCloud Drive file access works
9. Verify SwiftData persistence works
10. Push to GitHub repository
