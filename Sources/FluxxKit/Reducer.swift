public struct Reducer<State: StateType, Action: ActionType, GlobalAction: ActionType>: Sendable {
    public let reduce: @Sendable (State, Action, Relay<GlobalAction>) -> (State, Effect<Action>)

    public init(
        reduce: @Sendable @escaping (State, Action, Relay<GlobalAction>) -> (State, Effect<Action>)
    ) {
        self.reduce = reduce
    }
}

public typealias LocalReducer<State: StateType, Action: ActionType> =
    Reducer<State, Action, Never>

extension Reducer where GlobalAction == Never {
    public init(
        reduce: @Sendable @escaping (State, Action) -> (State, Effect<Action>)
    ) {
        self.reduce = { state, action, _ in reduce(state, action) }
    }
}
