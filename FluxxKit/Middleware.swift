@MainActor
public protocol MiddlewareType: AnyObject {

  func before(dispatch action: ActionType, to store: StoreType)

  func after(dispatch action: ActionType, to store: StoreType)
}
