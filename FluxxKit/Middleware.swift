import Foundation

public protocol MiddlewareType {

  func before(dispatch action: ActionType, to store: StoreType)

  func after(dispatch action: ActionType, to store: StoreType)
}
