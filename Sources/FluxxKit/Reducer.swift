public struct Reducer<State: StateType, Action: ActionType>: Sendable {
    public let reduce: @Sendable (State, Action) -> (State, Effect<Action>)

    public init(
        reduce: @Sendable @escaping (State, Action) -> (State, Effect<Action>)
    ) {
        self.reduce = reduce
    }
}
