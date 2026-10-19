import SwiftUI
import SwiftData

/// Add or edit one entry. Saving is the app's "success moment", so it feeds the review prompter.
struct EntryEditorView: View {
    let entry: Entry?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    @State private var date: Date = .now
    @State private var title = ""
    @State private var value: Double = 0
    @State private var notes = ""
    @FocusState private var titleFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("When", selection: $date)
                    TextField("Title", text: $title)
                        .focused($titleFocused)
                    TextField("Value", value: $value, format: .number)
                        .keyboardType(.decimalPad)
                }
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(entry == nil ? "New \(AppConfig.entryNoun)" : "Edit \(AppConfig.entryNoun)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.bold()
                }
            }
            .onAppear {
                if let entry {
                    date = entry.date
                    title = entry.title
                    value = entry.value
                    notes = entry.notes
                } else {
                    titleFocused = true
                }
            }
        }
        .presentationDetents([.large])
    }

    private func save() {
        if let entry {
            entry.date = date
            entry.title = title
            entry.value = value
            entry.notes = notes
        } else {
            context.insert(Entry(date: date, title: title, value: value, notes: notes))
        }
        ReviewPrompter.recordSuccess(request: requestReview)
        dismiss()
    }
}
