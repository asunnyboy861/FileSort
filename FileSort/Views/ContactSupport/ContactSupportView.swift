import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubject = "General"
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var submitResult: SubmitResult?

    private let subjects = ["General", "Feature Suggestion", "Bug Report", "Usage Question", "Performance Issue", "UI Improvement", "Other"]
    private let backendURL = "https://feedback-board.iocompile67692.workers.dev"

    private var effectiveSubject: String {
        selectedSubject == "Other" ? customSubject : selectedSubject
    }

    private var canSubmit: Bool {
        !name.isEmpty && !email.isEmpty && !message.isEmpty && (!selectedSubject.isEmpty && (selectedSubject != "Other" || !customSubject.isEmpty))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    subjectSection
                    if selectedSubject == "Other" {
                        customSubjectField
                    }
                    nameField
                    emailField
                    messageField
                    submitButton
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Thank You!", isPresented: .constant(submitResult == .success)) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your feedback has been submitted successfully.")
            }
            .alert("Error", isPresented: .constant(submitResult == .failure)) {
                Button("OK") { submitResult = nil }
            } message: {
                Text("Failed to submit feedback. Please try again later.")
            }
        }
    }

    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Subject")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 8) {
                ForEach(subjects, id: \.self) { subject in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSubject = subject
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: subjectIcon(subject))
                                .font(.caption)
                            Text(subject)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selectedSubject == subject ? .white : .appTextPrimary)
                        .background(selectedSubject == subject ? Color.appPrimary : Color.appCardBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedSubject == subject ? Color.appPrimary : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var customSubjectField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Custom Subject")
                .font(.subheadline)
                .foregroundColor(.appTextPrimary)
            TextField("Enter your subject", text: $customSubject)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Name")
                .font(.subheadline)
                .foregroundColor(.appTextPrimary)
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email")
                .font(.subheadline)
                .foregroundColor(.appTextPrimary)
            TextField("your@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
        }
    }

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Message")
                .font(.subheadline)
                .foregroundColor(.appTextPrimary)
            TextEditor(text: $message)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color.appCardBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submitFeedback() }
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                }
                Text(isSubmitting ? "Submitting..." : "Submit Feedback")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSubmit ? Color.appPrimary : Color.gray)
            .cornerRadius(14)
        }
        .disabled(!canSubmit || isSubmitting)
    }

    private func subjectIcon(_ subject: String) -> String {
        switch subject {
        case "General": return "message.fill"
        case "Feature Suggestion": return "lightbulb.fill"
        case "Bug Report": return "ladybug.fill"
        case "Usage Question": return "questionmark.circle.fill"
        case "Performance Issue": return "gauge.with.dots.needle.67percent"
        case "UI Improvement": return "paintbrush.fill"
        case "Other": return "ellipsis.circle.fill"
        default: return "message.fill"
        }
    }

    private func submitFeedback() async {
        isSubmitting = true
        let request = FeedbackRequest(
            name: name,
            email: email,
            subject: effectiveSubject,
            message: message,
            app_name: "FileSort"
        )
        do {
            var urlRequest = URLRequest(url: URL(string: "\(backendURL)/api/feedback")!)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(request)
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                submitResult = .success
            } else {
                submitResult = .failure
            }
        } catch {
            submitResult = .failure
        }
        isSubmitting = false
    }

    enum SubmitResult {
        case success
        case failure
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}
