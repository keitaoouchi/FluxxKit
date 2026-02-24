import FluxxKit

@MainActor
final class SearchMiddleware: MiddlewareType {

  private var currentTask: Task<Void, Never>?

  func before(dispatch action: ActionType, to store: StoreType) {
    guard case SearchState.Action.search(let text) = action else { return }

    let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else {
      currentTask?.cancel()
      store.dispatch(action: SearchState.Action.reset)
      return
    }

    store.dispatch(action: SearchState.Action.transition(to: .requesting))

    currentTask?.cancel()
    currentTask = Task {
      do {
        let repositories = try await Repository.search(text: query)
        guard !Task.isCancelled else { return }

        if repositories.isEmpty {
          store.dispatch(action: SearchState.Action.transition(to: .empty))
        } else {
          store.dispatch(action: SearchState.Action.update(repositories: repositories))
          store.dispatch(action: SearchState.Action.transition(to: .done))
        }
      } catch {
        guard !Task.isCancelled else { return }
        store.dispatch(action: SearchState.Action.transition(to: .failed))
      }
    }
  }

  func after(dispatch action: ActionType, to store: StoreType) {
    _ = action
    _ = store
  }
}
