import Foundation

public protocol StoreType: class {

  var identifier: String { get set }

  func responds(to: ActionType) -> Bool

  func dispatch(action: ActionType)
}

public final class Store<S: StateType, A: ActionType>: StoreType {

  public var identifier: String = Util.uuid()

  private let reducer: Reducer<S, A>

  private var _state: S = S()

  public var state: S {
    return self._state
  }

  public init(reducer: Reducer<S, A>) {
    self.reducer = reducer
  }

  public func dispatch(action: ActionType) {
    guard let action = action as? A, responds(to: action) else {
      return
    }
    self.reducer.reduce(action: action, to: self.state)
  }

  public func responds(to action: ActionType) -> Bool {
    guard let _ = action as? A else {
      return false
    }
    return true
  }

}
