import FluxxKit

// MARK: - State

struct SearchState: StateType {
    var repositories: [Repository] = []
    var phase: Phase = .idle

    enum Phase: Sendable {
        case idle
        case loading
        case loaded
        case failed
        case empty
    }
}

// MARK: - Action

enum SearchAction: ActionType {
    case search(query: String)
    case loaded([Repository])
    case failed
    case reset
}

// MARK: - Reducer

let searchReducer = Reducer<SearchState, SearchAction> { state, action in
    switch action {
    case .search(let query):
        var newState = state
        newState.phase = .loading
        newState.repositories = []
        let effect = Effect<SearchAction>.run { dispatch in
            do {
                let repos = try await GitHubAPI.search(query: query)
                await dispatch(repos.isEmpty ? .loaded([]) : .loaded(repos))
            } catch {
                await dispatch(.failed)
            }
        }
        return (newState, effect)

    case .loaded(let repos):
        var newState = state
        newState.repositories = repos
        newState.phase = repos.isEmpty ? .empty : .loaded
        return (newState, .none)

    case .failed:
        var newState = state
        newState.phase = .failed
        newState.repositories = []
        return (newState, .none)

    case .reset:
        return (SearchState(), .none)
    }
}
