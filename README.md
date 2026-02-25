# FluxxKit

Lightweight Flux-style state management for SwiftUI, built on `@Observable` and Swift Concurrency.

- Zero external dependencies
- Swift 6 strict concurrency safe
- Reducer as a composable function value

## Concepts

### Swift is already powerful enough

`enum`, `struct`, `@Observable`, `async/await` — Swift already has everything needed for state management. FluxxKit does not replace these primitives. It simply provides a methodology to organize them.

### Algebraic Data Types as the source of truth

Swift's `enum` functions as an algebraic data type (sum type). By defining Actions as ADTs, the complete set of operations a component can perform is fixed at compile time. The `switch` exhaustiveness check turns unhandled Actions into compiler errors, and when a new Action is added, every Reducer that fails to handle it is flagged immediately.

### Reducer as a pure function

All state transition logic is consolidated into a pure function: `(State, Action) -> (State, Effect)`. No "spooky action at a distance" — state only changes in one place. Testing is just calling a function. Code review is self-contained: reading the Reducer tells you everything that can happen on a given screen.

### Effects as first-class values

Side effects (API calls, timers, global actions) are expressed as return values from the Reducer. Reducer purity is preserved, and the presence of side effects is traceable during code review.

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
let counterReducer = Reducer<CounterState, CounterAction> { state, action in
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

let searchReducer = Reducer<SearchState, SearchAction> { state, action in
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

## Example App

[FluxxKitExample](https://github.com/keitaoouchi/FluxxKitExample) — A real-world sample app built with FluxxKit.

## Architecture

```
View → Action → Store.dispatch → Reducer(State, Action) → (NewState, Effect)
                                                                ↓
                                                          Effect.run → dispatch(Action)
```

## License

FluxxKit is available under the MIT license. See the LICENSE file for more info.
