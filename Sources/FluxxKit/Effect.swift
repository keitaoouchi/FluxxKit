public enum Effect<Action: ActionType>: Sendable {
    case none
    case run(@Sendable (_ dispatch: @escaping @Sendable (Action) async -> Void) async -> Void)
    case many([Effect<Action>])
}
