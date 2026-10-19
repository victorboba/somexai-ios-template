import SwiftUI
import SwiftData

/// The core loop: a list of entries grouped by day, one tap to add, swipe to delete, export in the toolbar.
struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Entry.date, order: .reverse) private var entries: [Entry]

    @State private var showingNewEntry = false
    @State private var editingEntry: Entry?
    @State private var showingSettings = false
    @State private var exportFile: ExportFile?
    @State private var exportError: String?

    private var groupedEntries: [(day: Date, entries: [Entry])] {
        let groups = Dictionary(grouping: entries, by: \.day)
        return groups.keys.sorted(by: >).map { (day: $0, entries: groups[$0] ?? []) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView {
                        Label("No \(AppConfig.entryNounPlural)", systemImage: "list.bullet.clipboard")
                    } description: {
                        Text("Tap + to record your first \(AppConfig.entryNoun.lowercased()).")
                    } actions: {
                        Button("Add \(AppConfig.entryNoun)") { showingNewEntry = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(groupedEntries, id: \.day) { group in
                            Section(group.day.formatted(date: .abbreviated, time: .omitted)) {
                                ForEach(group.entries) { entry in
                                    Button { editingEntry = entry } label: { EntryRow(entry: entry) }
                                        .buttonStyle(.plain)
                                }
                                .onDelete { offsets in delete(offsets.map { group.entries[$0] }) }
                            }
                        }
                    }
                }
            }
            .navigationTitle(AppConfig.appName)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button { showingSettings = true } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel("Settings")
                    NavigationLink { HowToView() } label: { Image(systemName: "questionmark.circle") }
                        .accessibilityLabel("How do I use this app")
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button("Export PDF", systemImage: "doc.richtext") { export(.pdf) }
                        Button("Export CSV", systemImage: "tablecells") { export(.csv) }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(entries.isEmpty)
                    .accessibilityLabel("Export")

                    Button { showingNewEntry = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add \(AppConfig.entryNoun)")
                }
            }
            .sheet(isPresented: $showingNewEntry) { EntryEditorView(entry: nil) }
            .sheet(item: $editingEntry) { entry in EntryEditorView(entry: entry) }
            .sheet(isPresented: $showingSettings) { SettingsView() }
            .sheet(item: $exportFile) { file in ShareSheet(url: file.url) }
            .alert("Export failed", isPresented: Binding(get: { exportError != nil }, set: { if !$0 { exportError = nil } })) {
                Button("OK") { exportError = nil }
            } message: {
                Text(exportError ?? "")
            }
        }
        .task {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-sampleData"), entries.isEmpty { SampleData.insert(into: context) }
            #endif
        }
        .onChange(of: entries.count, initial: true) { WidgetSync.update(with: entries) }
        .onChange(of: scenePhase, initial: true) { _, phase in
            guard phase == .active else { return }
            openNewEntryIfRequestedByShortcut()
        }
    }

    private enum ExportKind { case pdf, csv }

    private func export(_ kind: ExportKind) {
        do {
            let url = kind == .pdf ? try PDFExporter.export(entries) : try CSVExporter.export(entries)
            exportFile = ExportFile(url: url)
        } catch {
            exportError = error.localizedDescription
        }
    }

    private func delete(_ toDelete: [Entry]) {
        for entry in toDelete { context.delete(entry) }
    }

    private func openNewEntryIfRequestedByShortcut() {
        let defaults = WidgetSnapshot.defaults
        guard defaults.bool(forKey: LogEntryIntent.pendingKey) else { return }
        defaults.removeObject(forKey: LogEntryIntent.pendingKey)
        showingNewEntry = true
    }
}

struct EntryRow: View {
    let entry: Entry

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title.isEmpty ? AppConfig.entryNoun : entry.title)
                    .font(.body)
                if !entry.notes.isEmpty {
                    Text(entry.notes).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(CSVExporter.formatted(entry.value)).font(.body).monospacedDigit()
                Text(entry.date.formatted(date: .omitted, time: .shortened)).font(.caption).foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}
