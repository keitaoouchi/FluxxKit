public protocol StoreType {

  var identifier: String { get set }

  func dispatch(action: ActionType)

  func responds(to action: ActionType) -> Bool
}
