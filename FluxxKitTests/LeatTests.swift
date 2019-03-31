import XCTest
import XCTAssertNoLeak
@testable import FluxxKit

class LeatTests: XCTestCase {

  func testNoLeaks() {
    let middleware = Middleware()
    let store = Store<DummyState, Action>(reducer: DummyReducer())
    Dispatcher.shared.register(middleware: middleware)
    Dispatcher.shared.register(store: store)
    Dispatcher.shared.unregister(middleware: Middleware.self)
    Dispatcher.shared.unregister(store: store)

    XCTAssertNoLeak(store)
    XCTAssertNoLeak(middleware)
  }
}

// MARK: - Test target
private extension LeatTests {

  enum Action: ActionType {
    case dummy
  }

  class Middleware: MiddlewareType {

    var beforeCallCount = 0
    var afterCallCount = 0

    func before(dispatch action: ActionType, to store: StoreType) {
      self.beforeCallCount += 1
    }

    func after(dispatch action: ActionType, to store: StoreType) {
      self.afterCallCount += 1
    }
  }

  final class DummyState: StateType {
    var totalCallCount = 0
  }

  class DummyReducer: Reducer<DummyState, Action> {
    override func reduce(state: LeatTests.DummyState, action: LeatTests.Action) {
      switch action {
      case .dummy:
        state.totalCallCount += 1
      }
    }
  }

}
