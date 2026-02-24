import Combine
import FluxxKit

@MainActor
final class SearchState: StateType, ObservableObject {
  enum Phase {
    case idle
    case requesting
    case failed
    case empty
    case done
  }

  @Published var repositories: [Repository] = []
  @Published var phase: Phase = .idle

  required init() {}
}

extension SearchState {
  enum Action: ActionType {
    case search(text: String)
    case reset
    case update(repositories: [Repository])
    case transition(to: Phase)
  }

  final class Reducer: FluxxKit.Reducer<SearchState, Action> {
    override func reduce(state: SearchState, action: Action) {
      switch action {
      case .reset:
        state.repositories.removeAll()
        state.phase = .idle
      case .update(let repositories):
        state.repositories = repositories
      case .transition(let phase):
        state.phase = phase
      case .search:
        break
      }
    }
  }
}
