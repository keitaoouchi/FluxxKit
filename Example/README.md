## Getting Started

```
git clone https://github.com/keitaoouchi/FluxxKit.git
cd FluxxKit/Example
pod install
open Example.xcworkspace
```

## Scenario

1. `ViewController` creates `Store<ViewModel, ViewModel.Action>` and register it to `Dispatcher.shared`, and hold reference to it.
2. `ViewController` also creates `ViewModel.SearchMiddleware` and register it to `Dispatcher.shared`.
3. `ViewController` subscribes `ViewModel`'s `viewState` properties.
3. When user enter some text into UISearchBar, `ViewModel.Action.search` will be dispatched to `Dispatcher.shared`.
4. `ViewModel.SearchMiddleware` intercept action,
  1. dispatch `ViewModel.Action.transition(to: .requesting)`
  2. send API Request with `Repository.search`
  3. dispatch `ViewModel.Action.update` with fetched result
  4. dispatch `ViewModel.Action.transition(to: .done)`
5. `ViewController` react to `.done` state,
6. fill it's container view with `RepositoryViewController.tableView` using updated `ViewModel.repository`.
