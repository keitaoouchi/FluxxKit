import Foundation

open class Reducer<S: StateType, A: ActionType> {
  public init() {}

  open func reduce(action: A, to state: S) {
  }
}
