import Testing
@testable import FluxxKit

// MARK: - Test Fixtures

struct AppState: StateType {
    var loggedOut: Bool = false
}

enum AppAction: ActionType {
    case logout
}

private let appReducer = LocalReducer<AppState, AppAction> { state, action in
    switch action {
    case .logout:
        return (AppState(loggedOut: true), .none)
    }
}

struct ProfileState: StateType {
    var username: String = "user"
}

enum ProfileAction: ActionType {
    case logoutTapped
}

private let profileReducer = Reducer<ProfileState, ProfileAction, AppAction> { state, action, relay in
    switch action {
    case .logoutTapped:
        let effect = Effect<ProfileAction>.run { _ in
            await relay.dispatch(.logout)
        }
        return (state, effect)
    }
}

// MARK: - Tests

@Suite
struct RelayTests {

    @Test @MainActor
    func relayFromStoreDispatchesToGlobalStore() async throws {
        let appStore = Store(initialState: AppState(), reducer: appReducer)
        let relay = Relay.from(appStore)
        await relay.dispatch(.logout)
        #expect(appStore.state.loggedOut == true)
    }

    @Test @MainActor
    func localEffectRelaysToGlobalStore() async throws {
        let appStore = Store(initialState: AppState(), reducer: appReducer)
        let profileStore = Store(
            initialState: ProfileState(),
            reducer: profileReducer,
            relay: .from(appStore)
        )
        profileStore.dispatch(.logoutTapped)
        try await Task.sleep(for: .milliseconds(100))
        #expect(appStore.state.loggedOut == true)
    }
}
