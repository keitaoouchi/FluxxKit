import Combine
import FluxxKit

@MainActor
final class ViewModel: StateType, ObservableObject {
  @Published var repositories: [Repository] = []
  @Published var viewState: ViewModel.ViewState = .done

  enum ViewState {
    case requesting
    case failed
    case empty
    case done
  }

  required init() {}
}

// MARK: - FLUX
extension ViewModel {

  // Action for Reducer
  enum Action: ActionType {
    case search(text: String?)
    case reset
    case update(repositories: [Repository])
    case transition(to: ViewState)
  }

  // Handle async action
  final class SearchMiddleware: MiddlewareType {

    func before(dispatch action: ActionType, to store: StoreType) {
      guard case Action.search(let text) = action else { return }

      let query = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
      guard !query.isEmpty else {
        store.dispatch(action: Action.reset)
        return
      }

      store.dispatch(action: Action.transition(to: .requesting))

      Task {
        do {
          let repositories = try await Repository.search(text: query)

          if repositories.isEmpty {
            store.dispatch(action: Action.transition(to: .empty))
          } else {
            store.dispatch(action: Action.update(repositories: repositories))
            store.dispatch(action: Action.transition(to: .done))
          }
        } catch {
          store.dispatch(action: Action.transition(to: .failed))
        }
      }
    }

    func after(dispatch action: ActionType, to store: StoreType) {
      _ = action
      _ = store
    }

  }

  // Handle action
  final class Reducer: FluxxKit.Reducer<ViewModel, Action> {
    override func reduce(state: ViewModel, action: Action) {

      switch action {
      case .reset:
        state.repositories.removeAll()
        state.viewState = .done

      case .update(let repositories):
        state.repositories = repositories

      case .transition(let viewState):
        state.viewState = viewState

      case .search:
        break
      }
    }
  }

}
