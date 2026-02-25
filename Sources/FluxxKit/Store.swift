import Observation

@Observable
@MainActor
public final class Store<State: StateType, Action: ActionType> {
    public private(set) var state: State
    private let _reduce: (State, Action) -> (State, Effect<Action>)

    public init(
        initialState: State,
        reducer: Reducer<State, Action>
    ) {
        self.state = initialState
        self._reduce = { state, action in reducer.reduce(state, action) }
    }

    public func dispatch(_ action: Action) {
        let (newState, effect) = _reduce(state, action)
        state = newState
        handle(effect)
    }

    private func handle(_ effect: Effect<Action>) {
        switch effect {
        case .none:
            break
        case .run(let task):
            Task { [weak self] in
                guard let self else { return }
                await task { [weak self] action in
                    await self?.dispatch(action)
                }
            }
        case .many(let effects):
            effects.forEach { handle($0) }
        }
    }
}
