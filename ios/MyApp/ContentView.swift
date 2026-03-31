import SwiftUI

struct ContentView: View {
    @State private var items: [ItemDTO] = []
    @State private var loadError: String?
    @State private var isLoading = false
    @State private var newTitle = ""

    private let client = APIClient()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && items.isEmpty {
                    ProgressView("Loading…")
                } else if let loadError {
                    ContentUnavailableView(
                        "Could not load",
                        systemImage: "exclamationmark.triangle",
                        description: Text(loadError)
                    )
                } else {
                    List(items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .refreshable { await load() }
                }
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await load() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TextField("New item title", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        Task { await create() }
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(.bar)
            }
            .task {
                await load()
            }
        }
    }

    private func load() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }
        do {
            items = try await client.fetchItems()
        } catch {
            loadError = String(describing: error)
        }
    }

    private func create() async {
        let t = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        loadError = nil
        do {
            _ = try await client.createItem(title: t)
            newTitle = ""
            await load()
        } catch {
            loadError = String(describing: error)
        }
    }
}

#Preview {
    ContentView()
}
