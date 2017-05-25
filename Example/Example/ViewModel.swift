import FluxxKit
import RxSwift

final class ViewModel: StateType {
  var repositories: [Repository] = []
  var viewState = Variable<ViewModel.ViewState>(.done)

  enum ViewState {
    case requesting
    case failed
    case empty
    case done
  }
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

      guard let queryString = text, !queryString.isEmpty else {
        store.dispatch(action: Action.reset)
        return
      }

      store.dispatch(
        action: Action.transition(to: .requesting)
      )

      _ = Repository
        .search(text: queryString)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .observeOn(MainScheduler.instance)
        .subscribe { event in
          switch event {
          case .next(let repositories):

            if repositories.isEmpty {
              store.dispatch(
                action: Action.transition(to: .empty)
              )
            } else {
              store.dispatch(
                action: Action.update(repositories: repositories)
              )
            }

            store.dispatch(
              action: Action.transition(to: .done)
            )
          case .error:

            store.dispatch(
              action: Action.transition(to: .failed)
            )

          case .completed:
            break
          }
        }
    }

    func after(dispatch action: ActionType, to store: StoreType) {
      print(store)
    }

  }

  // Handle action
  final class Reducer: FluxxKit.Reducer<ViewModel, Action> {
    override func reduce(state: ViewModel, action: Action) {

      switch action {
      case .reset:
        state.repositories.removeAll()
        state.viewState.value = .done

      case .update(let repositories):
        state.repositories = repositories

      case .transition(let viewState):
        state.viewState.value = viewState

      case .search:
        break
      }
    }
  }

}
