import SwiftUI

struct ContactSupportView: View {
    @State private var selectedSubject: String = "General"
    @State private var customSubject: String = ""
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var isSubmitting = false
    @State private var submitResult: SubmitResult?
    @State private var showCustomSubject = false

    private let subjects = ["General", "Feature Suggestion", "Bug Report", "Usage Question", "Performance Issue", "UI Improvement", "Other"]
    private let backendURL = "https://feedback-board.iocompile67692.workers.dev"

    enum SubmitResult {
        case success
        case failure(String)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                subjectSection
                if showCustomSubject {
                    customSubjectField
                }
                nameField
                emailField
                messageField
                submitButton
            }
            .padding()
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subject")
                .font(.subheadline.bold())
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(subjects, id: \.self) { subject in
                    Button {
                        selectedSubject = subject
                        showCustomSubject = subject == "Other"
                    } label: {
                        Text(subject)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedSubject == subject ? Color.blue : Color.gray.opacity(0.15), in: Capsule())
                            .foregroundStyle(selectedSubject == subject ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var customSubjectField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Custom Subject")
                .font(.subheadline.bold())
            TextField("Enter your subject", text: $customSubject)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Name")
                .font(.subheadline.bold())
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Email")
                .font(.subheadline.bold())
            TextField("your@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
        }
    }

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Message")
                .font(.subheadline.bold())
            TextEditor(text: $message)
                .frame(minHeight: 120)
                .padding(4)
                .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submitFeedback() }
        } label: {
            if isSubmitting {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Submit")
                    .font(.headline)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        .disabled(isSubmitting || name.isEmpty || email.isEmpty || message.isEmpty)
    }

    private func submitFeedback() async {
        isSubmitting = true
        submitResult = nil
        let finalSubject = selectedSubject == "Other" ? customSubject : selectedSubject
        let request = FeedbackRequest(name: name, email: email, subject: finalSubject, message: message, app_name: "FileSort")
        do {
            let data = try JSONEncoder().encode(request)
            var urlRequest = URLRequest(url: URL(string: "\(backendURL)/api/feedback")!)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = data
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                submitResult = .success
                name = ""
                email = ""
                message = ""
                customSubject = ""
            } else {
                submitResult = .failure("Server error. Please try again.")
            }
        } catch {
            submitResult = .failure(error.localizedDescription)
        }
        isSubmitting = false
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}
