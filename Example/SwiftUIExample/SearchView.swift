import SwiftUI
import FluxxKit

struct SearchView: View {
  @StateObject private var store = StoreObject<SearchState, SearchState.Action>(
    reducer: SearchState.Reducer()
  )
  @State private var query: String = ""
  @State private var searchTask: Task<Void, Never>?
  @State private var isRegistered = false

  var body: some View {
    NavigationStack {
      Group {
        switch store.state.phase {
        case .idle:
          ContentUnavailableView("Search repositories", systemImage: "magnifyingglass")
        case .requesting:
          ProgressView("Loading...")
        case .failed:
          ContentUnavailableView("Request failed", systemImage: "wifi.exclamationmark")
        case .empty:
          ContentUnavailableView("No results", systemImage: "tray")
        case .done:
          List(store.state.repositories) { repo in
            Text(repo.fullName)
          }
        }
      }
      .navigationTitle("FluxxKit")
    }
    .searchable(text: $query)
    .onChange(of: query) { _, newValue in
      searchTask?.cancel()
      searchTask = Task {
        try? await Task.sleep(nanoseconds: 300_000_000)
        guard !Task.isCancelled else { return }
        store.dispatch(.search(text: newValue))
      }
    }
    .onAppear {
      guard !isRegistered else { return }
      Dispatcher.shared.register(middleware: SearchMiddleware())
      store.register()
      isRegistered = true
    }
    .onDisappear {
      searchTask?.cancel()
      Dispatcher.shared.unregister(middleware: SearchMiddleware.self)
      store.unregister()
      isRegistered = false
    }
  }
}
