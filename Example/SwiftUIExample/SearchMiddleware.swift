import FluxxKit

@MainActor
final class SearchMiddleware: MiddlewareType {

  func before(dispatch action: ActionType, to store: StoreType) {
    guard case SearchState.Action.search(let text) = action else { return }

    let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else {
      store.dispatch(action: SearchState.Action.reset)
      return
    }

    store.dispatch(action: SearchState.Action.transition(to: .requesting))

    Task {
      do {
        let repositories = try await Repository.search(text: query)

        if repositories.isEmpty {
          store.dispatch(action: SearchState.Action.transition(to: .empty))
        } else {
          store.dispatch(action: SearchState.Action.update(repositories: repositories))
          store.dispatch(action: SearchState.Action.transition(to: .done))
        }
      } catch {
        store.dispatch(action: SearchState.Action.transition(to: .failed))
      }
    }
  }

  func after(dispatch action: ActionType, to store: StoreType) {
    _ = action
    _ = store
  }
}
