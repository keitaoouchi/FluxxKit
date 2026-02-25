# FluxxKit

Lightweight Flux-style state management for SwiftUI, built entirely on `@Observable` and Swift Concurrency. Zero external dependencies.

## Concepts

### 1. Swift is already powerful enough

`enum`, `struct`, `@Observable`, `async/await` — Swift already has everything needed for state management. FluxxKit does not replace these primitives. It simply provides a methodology to organize them.

### 2. Algebraic Data Types as the source of truth

Swift's `enum` functions as an algebraic data type (sum type). By defining Actions as ADTs:

- The complete set of operations a component can perform is fixed at compile time.
- The `switch` exhaustiveness check turns unhandled Actions into compiler errors.
- When a new Action is added, every Reducer that fails to handle it is flagged immediately.

This solves the same problem XState addresses with finite state machines — defining state transitions declaratively and exhaustively.

### 3. Reducer as a pure function

All state transition logic is consolidated into a pure function: `(State, Action) -> (State, Effect)`. This means:

- No "spooky action at a distance" — state only changes in one place.
- Testing is just calling a function. No UI, no mocks required.
- Code review is self-contained: reading the Reducer tells you everything that can happen on a given screen.

### 4. Effects as first-class values

Side effects (API calls, timers, global actions) are expressed as return values from the Reducer. Making effects visible ensures:

- Reducer purity is preserved.
- The presence of side effects is traceable during code review.

## Architecture

```
View → Action → Store.dispatch → Reducer(State, Action) → (NewState, Effect)
                                                                ↓
                                                          Effect.run → dispatch(Action)
```

**Four types compose the entire library:**

| Type | Role | File |
|---|---|---|
| `StateType` / `ActionType` | Sendable marker protocols | `StateType.swift` / `ActionType.swift` |
| `Effect<Action>` | Side effect representation (`.none` / `.run` / `.many`) | `Effect.swift` |
| `Reducer<State, Action>` | Struct wrapping a pure function `(State, Action) -> (State, Effect)` | `Reducer.swift` |
| `Store<State, Action>` | `@Observable` `@MainActor` state container | `Store.swift` |

## Design Constraints

- **No external dependencies** — do not add entries to `dependencies` in `Package.swift`
- **Reducer stays as a function value** — do not convert to a protocol
- **Minimal effect composition** — use `.many` and Swift Concurrency (`async let`, `TaskGroup`). Do not add operators like `concat`/`merge`
- **Swift 6 strict concurrency warnings must remain at zero**

## Build & Test

```sh
swift build
swift test
```

- Platforms: iOS 17+, macOS 14+
- swift-tools-version: 6.0
- Test framework: Swift Testing (`import Testing`)
- Test file: `Tests/FluxxKitTests/StoreTests.swift`
