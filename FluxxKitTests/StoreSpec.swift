import Quick
import Nimble
@testable import FluxxKit

class StoreSpec: QuickSpec {

  override func spec() {

    var store: Store<Spy, RespondableAction>!

    beforeEach {
      store = Store<Spy, RespondableAction>(reducer: SpyReducer())
    }

    describe(".responds") {
      it("should be true if Respondable Action is given") {
        expect(store.responds(to: RespondableAction.dummy)).to(equal(true))
      }

      it("should be false if Not Respondable Action is given") {
        expect(store.responds(to: NotRespondableAction.dummy)).to(equal(false))
      }
    }

    describe(".dispatch") {

      beforeEach {
        Dispatcher.shared.unregister(store: Store<Spy, RespondableAction>.self)
        Dispatcher.shared.register(store: store)
      }

      context("when store is not respondable to action") {

        it("should not be called") {
          Dispatcher.shared.dispatch(action: NotRespondableAction.dummy)
          expect(store.state.callCount).toEventuallyNot(equal(1))
        }

      }

      context("when store is unregistered from dispatcher") {

        beforeEach {
          Dispatcher.shared.unregister(store: store)
        }

        it("should be called") {
          Dispatcher.shared.dispatch(action: RespondableAction.dummy)
          expect(store.state.callCount).toEventuallyNot(equal(1))
        }

      }

    }

  }

}

private extension StoreSpec {

  final class Spy: StateType {
    var callCount = 0
  }

  enum RespondableAction: ActionType {
    case dummy
  }

  enum NotRespondableAction: ActionType {
    case dummy
  }

  class SpyReducer: Reducer<Spy, RespondableAction> {
    override func reduce(state: StoreSpec.Spy, action: StoreSpec.RespondableAction) {
      state.callCount += 1
    }
  }

}
