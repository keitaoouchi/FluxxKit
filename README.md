# FluxxKit

[![CI Status](http://img.shields.io/travis/keitaoouchi/FluxxKit.svg?style=flat)](https://travis-ci.org/keitaoouchi/FluxxKit)
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://swift.org/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/FluxxKit.svg?style=flat)](http://cocoapods.org/pods/FluxxKit)
[![License](https://img.shields.io/cocoapods/l/FluxxKit.svg?style=flat)](http://cocoapods.org/pods/FluxxKit)
[![Platform](https://img.shields.io/cocoapods/p/FluxxKit.svg?style=flat)](http://cocoapods.org/pods/FluxxKit)

## Overview

Unidirectional data flow for reactive programming in iOS.

Porting [facebook's flux implementation](https://github.com/facebook/flux) in Swift, except callback called when store changes.

##### Why no callback?

We have RxSwift, ReactiveSwift, ReactiveKit or something else. All the stateful things could be implemented as Observable or Stream, and ViewController could bind and react to them.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

More complicated real world example like below is [here](https://github.com/keitaoouchi/FluxxKitExample).

![GIF](https://raw.githubusercontent.com/keitaoouchi/FluxxKitExample/master/sample.gif "GIF")

### Getting Started

1. State

  ```swift
  import FluxxKit
  import RxSwift

  final class ViewModel: StateType {
    var count = Observable<Int>(0)
  }
  ```

2. Action

  ```swift
  extension ViewModel {
    enum Action: ActionType {
      case plus
      case minus
    }
  }
  ```

3. Reducer

  ```swift
  extension ViewModel {
    final class Reducer: FluxxKit.Reducer<ViewModel, Action> {
      override func reduce(state: ViewModel, action: Action) {

        switch action {
        case .plus:
          state.count.value = state.count + 1
        case .minus:
          state.count.value = state.count - 1
        }
      }
    }
  }
  ```

4. View

  Create store and register it to dispatcher, and bind store's state:
  ```swift
  import FluxxKit
  import RxSWift

  final class ViewController: UIViewController {

    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    var store = Store<ViewModel, ViewModel.Action>(
      reducer: ViewModel.Reducer()
    )

    override func viewDidLoad() {
      super.viewDidLoad()

      Dispatcher.shared.register(store: self.store)

      store.state.count.asObservable().onserveOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] count in
          self?.counterLabel.text = "\(count)"
        })
    }

    deinit {
      Dispatcher.shared.unregister(identifier: self.store.identifier)
    }
  }
  ```

  Dispatch action with UI action:
  ```swift
  @IBAction
  func onTouchPlusButton(sender: Any) {
    Dispatcher.shared.dispatch(action: ViewModel.Action.plus)
  }

  @IBAction
  func onTouchMinusButton(sender: Any) {
    Dispatcher.shared.dispatch(action: ViewModel.Action.minus)
  }
  ```

### Architecture

(:ghost: nice diagram here :ghost:)

#### Flux

```
View -> Action -> Dispatcher -> (Middleware) -> Store -> Reducer -> Observable
```

- When a user interacts with a View(Controller), it propagates an `Action`
- through a central `Dispatcher`,
- to the various `Store`s that hold the application's data,
- `state transition` occurs in some `Store` that could responds to dispatched `Action`,
- which will emit new items to `Observable` property in these `Store`.

#### Reactive Programming

```
Observable ---> View
```

- ViewController subscribes Store's `Observable` properties,
- and react to it.

## Requirements

iOS 9 or later.
Swift3.0 or later.

## Installation

FluxxKit is available through [CocoaPods](http://cocoapods.org) or [Carthage](https://github.com/Carthage/Carthage).

### CocoaPods

```ruby
pod "FluxxKit"
```

### Carthage

```
github "keitaoouchi/FluxxKit"
```

for detail, please follow the [Carthage Instruction](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos)

## Author

keitaoouchi, keita.oouchi@gmail.com

## License

FluxxKit is available under the MIT license. See the LICENSE file for more info.
