# FluxxKit

[![Version](https://img.shields.io/cocoapods/v/FluxxKit.svg?style=flat)](http://cocoapods.org/pods/FluxxKit)
[![License](https://img.shields.io/cocoapods/l/FluxxKit.svg?style=flat)](http://cocoapods.org/pods/FluxxKit)
[![Platform](https://img.shields.io/cocoapods/p/FluxxKit.svg?style=flat)](http://cocoapods.org/pods/FluxxKit)

## Overview

FluxxKit is a lightweight Flux-style state container for iOS.

- Unidirectional data flow (`View -> Action -> Dispatcher -> Store -> Reducer -> State`)
- Reactive-library agnostic core
- **Recommended integration: Combine + SwiftUI**

## Requirements

| Target | Version |
|---|---|
| iOS | 16.0+ |
| Swift | 6.0+ |

## Getting Started (Combine + SwiftUI)

### 1. Define a state

```swift
import Combine
import FluxxKit

@MainActor
final class CounterState: StateType, ObservableObject {
  @Published var count: Int = 0

  required init() {}
}
```

### 2. Define actions

```swift
extension CounterState {
  enum Action: ActionType {
    case plus
    case minus
  }
}
```

### 3. Define a reducer

```swift
extension CounterState {
  final class Reducer: FluxxKit.Reducer<CounterState, Action> {
    override func reduce(state: CounterState, action: Action) {
      switch action {
      case .plus:
        state.count += 1
      case .minus:
        state.count -= 1
      }
    }
  }
}
```

### 4. Bind in SwiftUI

```swift
import SwiftUI
import FluxxKit

struct CounterView: View {
  @StateObject private var store = StoreObject<CounterState, CounterState.Action>(
    reducer: CounterState.Reducer()
  )

  var body: some View {
    VStack(spacing: 16) {
      Text("\(store.state.count)")
        .font(.system(size: 48, weight: .bold, design: .rounded))

      HStack {
        Button("-") { store.dispatch(.minus) }
        Button("+") { store.dispatch(.plus) }
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .onAppear { store.register() }
    .onDisappear { store.unregister() }
  }
}
```

## Architecture

### Flux

```
View -> Action -> Dispatcher -> (Middleware) -> Store -> Reducer -> State
```

- User interaction dispatches an `Action`.
- `Dispatcher` routes actions to matching stores.
- `Reducer` performs state transition.
- UI updates by observing state (for example via `@Published`).

### Reactive layer

FluxxKit does not force a specific reactive framework.

- Recommended: **Combine / SwiftUI**
- Also possible: Any stream/observation mechanism your project uses.

## Installation

FluxxKit supports CocoaPods and Carthage.

### CocoaPods

```ruby
pod "FluxxKit"
```

### Carthage

```
github "keitaoouchi/FluxxKit"
```

## Author

keitaoouchi, keita.oouchi@gmail.com

## License

FluxxKit is available under the MIT license. See the LICENSE file for more info.
