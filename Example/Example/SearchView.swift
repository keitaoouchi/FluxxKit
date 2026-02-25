import SwiftUI
import FluxxKit

struct SearchView: View {
    @State private var store = Store(
        initialState: SearchState(),
        reducer: searchReducer
    )
    @State private var query = ""

    var body: some View {
        NavigationStack {
            Group {
                switch store.state.phase {
                case .idle:
                    ContentUnavailableView(
                        "Search GitHub",
                        systemImage: "magnifyingglass",
                        description: Text("Enter a keyword to find repositories.")
                    )
                case .loading:
                    ProgressView()
                case .loaded:
                    repositoryList
                case .empty:
                    ContentUnavailableView.search(text: query)
                case .failed:
                    ContentUnavailableView(
                        "Request Failed",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Please try again later.")
                    )
                }
            }
            .navigationTitle("GitHub Search")
            .searchable(text: $query, prompt: "Search repositories")
            .onSubmit(of: .search) {
                store.dispatch(.search(query: query))
            }
        }
    }

    private var repositoryList: some View {
        List(store.state.repositories) { repo in
            VStack(alignment: .leading, spacing: 4) {
                Text(repo.fullName)
                    .font(.headline)
                if let description = repo.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                HStack(spacing: 12) {
                    Label("\(repo.stargazersCount)", systemImage: "star")
                    if let language = repo.language {
                        Label(language, systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}
