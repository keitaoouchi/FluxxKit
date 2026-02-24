import Testing
@testable import FluxxKit

// MARK: - Test Fixtures

struct CounterState: StateType {
    var count: Int = 0
}

enum CounterAction: ActionType {
    case increment
    case decrement
    case delayedIncrement
    case multiEffect
}

private let counterReducer = LocalReducer<CounterState, CounterAction> { state, action in
    switch action {
    case .increment:
        return (CounterState(count: state.count + 1), .none)
    case .decrement:
        return (CounterState(count: state.count - 1), .none)
    case .delayedIncrement:
        let effect = Effect<CounterAction>.run { dispatch in
            await dispatch(.increment)
        }
        return (state, effect)
    case .multiEffect:
        let effects: [Effect<CounterAction>] = [
            .run { dispatch in await dispatch(.increment) },
            .run { dispatch in await dispatch(.increment) },
        ]
        return (state, .many(effects))
    }
}

// MARK: - Tests

@Suite
struct StoreTests {

    @Test @MainActor
    func dispatchUpdatesState() {
        let store = Store(initialState: CounterState(), reducer: counterReducer)
        store.dispatch(.increment)
        #expect(store.state.count == 1)
        store.dispatch(.increment)
        #expect(store.state.count == 2)
        store.dispatch(.decrement)
        #expect(store.state.count == 1)
    }

    @Test @MainActor
    func runEffectDispatchesAction() async throws {
        let store = Store(initialState: CounterState(), reducer: counterReducer)
        store.dispatch(.delayedIncrement)
        // Effect runs in a Task, so we need to yield to let it execute
        try await Task.sleep(for: .milliseconds(100))
        #expect(store.state.count == 1)
    }

    @Test @MainActor
    func manyEffectsAllExecute() async throws {
        let store = Store(initialState: CounterState(), reducer: counterReducer)
        store.dispatch(.multiEffect)
        try await Task.sleep(for: .milliseconds(100))
        #expect(store.state.count == 2)
    }

    @Test @MainActor
    func localReducerDoesNotInvolveRelay() {
        // LocalReducer<State, Action> is Reducer<State, Action, Never>
        // This test verifies it compiles and works without any Relay setup
        let store = Store(initialState: CounterState(), reducer: counterReducer)
        store.dispatch(.increment)
        #expect(store.state.count == 1)
    }
}
