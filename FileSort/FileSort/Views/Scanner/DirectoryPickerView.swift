import SwiftUI
import UniformTypeIdentifiers

struct DirectoryPickerView: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

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
        private var accessedURL: URL?

        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                accessedURL?.stopAccessingSecurityScopedResource()
                let _ = url.startAccessingSecurityScopedResource()
                accessedURL = url
                try? BookmarkService().saveBookmark(for: url)
                onPick(url)
            }
        }

        deinit {
            accessedURL?.stopAccessingSecurityScopedResource()
        }
    }
}
