import Quick
import Nimble
@testable import FluxxKit

class MiddlewareSpec: QuickSpec {

  //swiftlint:disable function_body_length next
  override func spec() {

    var store: Store<DummyState, Action>!
    var middleware: Middleware!

    beforeEach {
      middleware = Middleware()
      store = Store<DummyState, Action>(reducer: DummyReducer())
      Dispatcher.shared.unregister(middleware: Middleware.self)
      Dispatcher.shared.unregister(store: Store<DummyState, Action>.self)
      Dispatcher.shared.register(middleware: middleware)
    }

    describe(".before(dispatch action...)") {

      context("no respondable store is registered") {

        it("should not be called") {
          Dispatcher.shared.dispatch(action: Action.dummy)
          expect(middleware.beforeCallCount).toEventually(equal(0))
          expect(store.state.totalCallCount).toEventually(equal(0))
        }

      }

      context("respondable store is registered") {

        beforeEach {
          Dispatcher.shared.register(store: store)
        }

        it("should be called") {
          Dispatcher.shared.dispatch(action: Action.dummy)
          expect(middleware.beforeCallCount).toEventually(equal(1))
          expect(store.state.totalCallCount).toEventually(equal(1))
        }

      }

    }

    describe(".after(dispatch action...)") {

      context("when no respondable store is registered") {

        it("should not be called") {
          Dispatcher.shared.dispatch(action: Action.dummy)
          expect(middleware.afterCallCount).toEventually(equal(0))
          expect(store.state.totalCallCount).toEventually(equal(0))
        }

      }

      context("when respondable store is registered") {

        beforeEach {
          Dispatcher.shared.register(store: store)
        }

        it("should be called") {
          Dispatcher.shared.dispatch(action: Action.dummy)
          expect(middleware.afterCallCount).toEventually(equal(1))
          expect(store.state.totalCallCount).toEventually(equal(1))
        }

      }

    }

    describe("both .before/.afer(dispatch action ...)") {

      context("when dispatch is called directly to store") {

        it("should not be called") {
          store.dispatch(action: Action.dummy)
          expect(middleware.beforeCallCount).toEventually(equal(0))
          expect(middleware.afterCallCount).toEventually(equal(0))
          expect(store.state.totalCallCount).toEventually(equal(1))
        }

      }

      context("when multiple store is registered") {

        beforeEach {
          let anotherStore = Store<DummyState, Action>(reducer: DummyReducer())
          Dispatcher.shared.register(store: store)
          Dispatcher.shared.register(store: anotherStore)
        }

        it("should call multiple time") {
          Dispatcher.shared.dispatch(action: Action.dummy)
          expect(middleware.beforeCallCount).toEventually(equal(2))
          expect(middleware.afterCallCount).toEventually(equal(2))
          expect(store.state.totalCallCount).toEventually(equal(1))
        }

      }
    }

  }

}

// MARK: - Test target
private extension MiddlewareSpec {

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
    override func reduce(state: MiddlewareSpec.DummyState, action: MiddlewareSpec.Action) {
      switch action {
      case .dummy:
        state.totalCallCount += 1
      }
    }
  }

}
