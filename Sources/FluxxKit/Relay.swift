public struct Relay<Action: ActionType>: Sendable {
    public let dispatch: @Sendable (Action) async -> Void

    public init(dispatch: @Sendable @escaping (Action) async -> Void) {
        self.dispatch = dispatch
    }

    public static func from(_ store: Store<some StateType, Action>) -> Relay<Action> {
        Relay { action in await store.dispatch(action) }
    }
}

extension Relay where Action == Never {
    public static var unused: Relay<Never> {
        Relay { _ in }
    }
}
