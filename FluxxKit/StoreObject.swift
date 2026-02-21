import Combine

@MainActor
public final class StoreObject<S: StateType & ObservableObject, A: ActionType>: ObservableObject {

  public let store: Store<S, A>

  public var state: S {
    store.state
  }

  private var cancellable: AnyCancellable?

  public init(store: Store<S, A>) {
    self.store = store
    self.cancellable = store.state.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
  }

  public convenience init(initialState: S = S(), reducer: Reducer<S, A>) {
    self.init(store: Store(initialState: initialState, reducer: reducer))
  }

  public func dispatch(_ action: A) {
    Dispatcher.shared.dispatch(action: action, identifier: store.identifier)
  }

  public func register() {
    Dispatcher.shared.register(store: store)
  }

  public func unregister() {
    Dispatcher.shared.unregister(store: store)
  }
}
