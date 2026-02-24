# FluxxKit v2

## 概要

FluxxKit v1（RxSwift依存のFlux実装）をSwiftUI / Swift 6向けにフルスクラッチで再構築する。

**設計の核心:**
- Reducerは型ではなく関数値として扱う（合成可能）
- グローバル状態への作用経路を`Relay`として型で表現する
- 外部依存ゼロ、`@Observable` + Swift Concurrencyのみ

---

## ディレクトリ構成

```
Sources/FluxxKit/
├── ActionType.swift
├── StateType.swift
├── Effect.swift
├── Reducer.swift
├── Relay.swift
└── Store.swift
Tests/FluxxKitTests/
├── StoreTests.swift
└── RelayTests.swift
```

---

## 型定義と実装仕様

### `StateType.swift` / `ActionType.swift`

```swift
public protocol StateType: Sendable {}
public protocol ActionType: Sendable {}
```

### `Effect.swift`

副作用の表現。合成はSwift Concurrencyのネイティブな道具（`async let`, `TaskGroup`）に委ねるため、最小限のケースのみ持つ。

```swift
public enum Effect<Action: ActionType>: Sendable {
    case none
    case run(@Sendable (_ dispatch: @escaping @Sendable (Action) async -> Void) async -> Void)
    case many([Effect<Action>])
}
```

### `Relay.swift`

ローカルStoreのEffectからグローバルActionを発行するための橋渡し。
Reducerのシグネチャに`Relay`が現れることで、「このReducerはグローバルに作用する可能性がある」ことをコードレビューで追跡可能にする。

```swift
public struct Relay<Action: ActionType>: Sendable {
    public let dispatch: @Sendable (Action) async -> Void

    public init(dispatch: @Sendable @escaping (Action) async -> Void) {
        self.dispatch = dispatch
    }

    /// グローバルStoreから生成するファクトリ
    public static func from(_ store: Store<some StateType, Action>) -> Relay<Action> {
        Relay { action in await store.dispatch(action) }
    }
}
```

Relayを持たないReducerと持つReducerの両方を自然に書けるように、Reducerの定義を2種類サポートする（後述）。

### `Reducer.swift`

**Reducerは関数値**として扱う。protocolではなくstruct。
ローカル専用とグローバル連携ありの2種類を同一の型で表現する。

```swift
public struct Reducer<State: StateType, Action: ActionType, GlobalAction: ActionType>: Sendable {
    public let reduce: @Sendable (State, Action, Relay<GlobalAction>) -> (State, Effect<Action>)

    public init(
        reduce: @Sendable @escaping (State, Action, Relay<GlobalAction>) -> (State, Effect<Action>)
    ) {
        self.reduce = reduce
    }
}

// グローバル連携が不要なReducerのためのtypealias
// GlobalActionをNeverにすることでRelayが使えないことを型で表現する
public typealias LocalReducer<State: StateType, Action: ActionType> =
    Reducer<State, Action, Never>

// Never用のRelayはdispatchが呼ばれないダミー
extension Relay where Action == Never {
    public static var unused: Relay<Never> {
        Relay { _ in }
    }
}

// LocalReducer用の簡潔なイニシャライザ
extension Reducer where GlobalAction == Never {
    public init(
        reduce: @Sendable @escaping (State, Action) -> (State, Effect<Action>)
    ) {
        self.reduce = { state, action, _ in reduce(state, action) }
    }
}
```

#### 使用例

```swift
// グローバル連携なし
let counterReducer = LocalReducer<CounterState, CounterAction> { state, action in
    switch action {
    case .increment: return (.init(count: state.count + 1), .none)
    case .decrement: return (.init(count: state.count - 1), .none)
    }
}

// グローバル連携あり（型シグネチャでそれが明示される）
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

### `Store.swift`

`@Observable`でSwiftUIに薄く接続するだけ。ローカル・グローバル兼用の単一実装。

```swift
@Observable
@MainActor
public final class Store<State: StateType, Action: ActionType> {
    public private(set) var state: State
    private let _dispatch: @MainActor (Action) -> Void

    /// グローバル連携なし（LocalReducer用）
    public init(
        initialState: State,
        reducer: LocalReducer<State, Action>
    ) {
        self.state = initialState
        // _dispatchはself参照が必要なため後から設定
        var dispatchRef: (@MainActor (Action) -> Void)!
        self._dispatch = { action in dispatchRef(action) }
        dispatchRef = { [weak self] action in
            guard let self else { return }
            let (newState, effect) = reducer.reduce(self.state, action, .unused)
            self.state = newState
            self.handle(effect)
        }
    }

    /// グローバル連携あり（Relay付きReducer用）
    public init<GlobalAction: ActionType>(
        initialState: State,
        reducer: Reducer<State, Action, GlobalAction>,
        relay: Relay<GlobalAction>
    ) {
        self.state = initialState
        var dispatchRef: (@MainActor (Action) -> Void)!
        self._dispatch = { action in dispatchRef(action) }
        dispatchRef = { [weak self] action in
            guard let self else { return }
            let (newState, effect) = reducer.reduce(self.state, action, relay)
            self.state = newState
            self.handle(effect)
        }
    }

    public func dispatch(_ action: Action) {
        _dispatch(action)
    }

    private func handle(_ effect: Effect<Action>) {
        switch effect {
        case .none:
            break
        case .run(let task):
            Task { [weak self] in
                await task { action in
                    await self?.dispatch(action)
                }
            }
        case .many(let effects):
            effects.forEach { handle($0) }
        }
    }
}
```

---

## SwiftUIでの使い方

### ローカルState（グローバル連携なし）

```swift
struct CounterView: View {
    @State private var store = Store(
        initialState: CounterState(count: 0),
        reducer: counterReducer
    )

    var body: some View {
        VStack {
            Text("\(store.state.count)")
            Button("+") { store.dispatch(.increment) }
        }
    }
}
```

### グローバルState連携

```swift
// AppStoreをEnvironmentで流す
@main
struct MyApp: App {
    @State private var appStore = Store(
        initialState: AppState(),
        reducer: appReducer
    )

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appStore)
        }
    }
}

// 子ViewはRelayを通じてグローバルに作用する
struct ProfileView: View {
    @Environment(Store<AppState, AppAction>.self) var appStore
    @State private var store: Store<ProfileState, ProfileAction>?

    var body: some View {
        Group {
            if let store {
                Text(store.state.username)
                Button("Logout") { store.dispatch(.logoutTapped) }
            }
        }
        .onAppear {
            store = Store(
                initialState: ProfileState(),
                reducer: profileReducer,
                relay: .from(appStore)  // グローバルへの経路を注入
            )
        }
    }
}
```

---

## テスト要件

Reducerは純粋関数なのでモック不要。`Store`のテストも`await`で直接確認できる。

### StoreTests.swift でカバーすること

- `dispatch`後にstateが更新されること
- `.run` Effectが実行されActionが返ってくること
- `.many` Effectが全て実行されること
- `LocalReducer`でRelayが関与しないこと

### RelayTests.swift でカバーすること

- `Relay.from(store)`経由でグローバルStoreにActionが届くこと
- ローカルStoreのEffectからグローバルActionが発行されるシナリオ

---

## Package.swift

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FluxxKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "FluxxKit", targets: ["FluxxKit"])
    ],
    targets: [
        .target(name: "FluxxKit"),
        .testTarget(name: "FluxxKitTests", dependencies: ["FluxxKit"])
    ]
)
```

---

## 設計上の制約（変更禁止）

- 外部依存は追加しない
- `Reducer`をprotocolにしない（関数値として保つ）
- `Store`と`GlobalStore`を分離しない（Relayで経路を表現する）
- Effect合成（concat/merge等）は追加しない。必要なら`.many`とSwift Concurrencyで対応する
- Swift 6 strict concurrency警告をゼロに保つ

---

## 完了条件

- [ ] `swift build` が通る
- [ ] `swift test` が全て通る
- [ ] Swift 6 strict concurrency警告ゼロ
- [ ] 外部依存ゼロ（`Package.swift`にdependenciesなし）
- [ ] README.mdを更新する（別ファイル`README.md`参照）
