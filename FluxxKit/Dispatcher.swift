import Foundation

public final class Dispatcher {

  public static let shared = Dispatcher()

  private var stores: [StoreType] = []

  private var middlewares: [MiddlewareType] = []

  public func register(middleware: MiddlewareType) {
    precondition(Thread.isMainThread)

    self.middlewares.append(middleware)
  }

  public func unregister(middleware middlewareType: MiddlewareType.Type) {
    precondition(Thread.isMainThread)

    self.middlewares = self.middlewares.filter { type(of: $0) != middlewareType }
  }

  public func register(store: StoreType) {
    precondition(Thread.isMainThread)

    self.stores.append(store)
  }

  public func unregister(store identifier: String) {
    precondition(Thread.isMainThread)

    self.stores = self.stores.filter { $0.identifier != identifier }
  }

  public func unregister(store: StoreType) {
    self.unregister(store: store.identifier)
  }

  public func unregister(store storeType: StoreType.Type) {
    precondition(Thread.isMainThread)

    self.stores = self.stores.filter { type(of: $0) != storeType }
  }

  public func dispatch(action: ActionType, identifier: String? = nil) {
    var stores = self.stores
    if let identifier = identifier {
      stores = self.stores.filter { $0.identifier == identifier }
    }
    for store in stores where store.responds(to: action) {
      execute(action: action, in: store)
    }
  }

  private func execute(action: ActionType, in store: StoreType) {

    for middleware in self.middlewares {
      middleware.before(dispatch: action, to: store)
    }

    store.dispatch(action: action)

    for middleware in self.middlewares {
      middleware.after(dispatch: action, to: store)
    }

  }
}
