# FluxxKit

Lightweight Flux-style state management for SwiftUI, built on `@Observable` and Swift Concurrency.

- Zero external dependencies
- Swift 6 strict concurrency safe
- Reducer as a composable function value (not a protocol)
- `Relay` type for explicit global state coordination

## Requirements

| Target | Version |
|---|---|
| iOS | 17.0+ |
| macOS | 14.0+ |
| Swift | 6.0+ |

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/nicoryo/FluxxKit.git", from: "2.0.0")
]
```

## Quick Start

### 1. Define State and Action

```swift
import FluxxKit

struct CounterState: StateType {
    var count: Int = 0
}

enum CounterAction: ActionType {
    case increment
    case decrement
}
```

### 2. Define a Reducer

Reducers are pure functions — no protocol conformance needed.

```swift
let counterReducer = LocalReducer<CounterState, CounterAction> { state, action in
    switch action {
    case .increment:
        return (CounterState(count: state.count + 1), .none)
    case .decrement:
        return (CounterState(count: state.count - 1), .none)
    }
}
```

### 3. Use in SwiftUI

```swift
struct CounterView: View {
    @State private var store = Store(
        initialState: CounterState(),
        reducer: counterReducer
    )

    var body: some View {
        VStack {
            Text("\(store.state.count)")
            Button("+") { store.dispatch(.increment) }
            Button("-") { store.dispatch(.decrement) }
        }
    }
}
```

## Side Effects

Use `Effect.run` for async operations. The dispatch function is injected so actions flow back through the store.

```swift
enum SearchAction: ActionType {
    case search(query: String)
    case loaded([Result])
}

let searchReducer = LocalReducer<SearchState, SearchAction> { state, action in
    switch action {
    case .search(let query):
        let effect = Effect<SearchAction>.run { dispatch in
            let results = await API.search(query)
            await dispatch(.loaded(results))
        }
        return (state, effect)
    case .loaded(let results):
        return (SearchState(results: results), .none)
    }
}
```

Use `.many` to combine multiple effects:

```swift
return (newState, .many([effect1, effect2]))
```

## Global State Coordination with Relay

`Relay` bridges a local store's effects to a global store. The type signature makes cross-store communication explicit and traceable.

### Define a global store

```swift
struct AppState: StateType {
    var loggedIn: Bool = true
}

enum AppAction: ActionType {
    case logout
}

let appReducer = LocalReducer<AppState, AppAction> { state, action in
    switch action {
    case .logout:
        return (AppState(loggedIn: false), .none)
    }
}
```

### Create a local store with Relay

```swift
// The type Reducer<ProfileState, ProfileAction, AppAction> makes it
// explicit that this reducer can dispatch to the global store.
let profileReducer = Reducer<ProfileState, ProfileAction, AppAction> { state, action, relay in
    switch action {
    case .logoutTapped:
        let effect = Effect<ProfileAction>.run { _ in
            await relay.dispatch(.logout)
        }
        return (state, effect)
    }
}
```

### Wire it up in SwiftUI

```swift
@main
struct MyApp: App {
    @State private var appStore = Store(
        initialState: AppState(),
        reducer: appReducer
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appStore)
        }
    }
}

struct ProfileView: View {
    @Environment(Store<AppState, AppAction>.self) var appStore
    @State private var store: Store<ProfileState, ProfileAction>?

    var body: some View {
        Group {
            if let store {
                Button("Logout") { store.dispatch(.logoutTapped) }
            }
        }
        .onAppear {
            store = Store(
                initialState: ProfileState(),
                reducer: profileReducer,
                relay: .from(appStore)
            )
        }
    }
}
```

## Architecture

```
View → Action → Store.dispatch → Reducer(State, Action) → (NewState, Effect)
                                                                ↓
                                                          Effect.run → dispatch(Action)
```

- `LocalReducer<State, Action>` — no global coordination (uses `Never` for GlobalAction)
- `Reducer<State, Action, GlobalAction>` — can dispatch to a global store via `Relay`

## License

FluxxKit is available under the MIT license. See the LICENSE file for more info.
