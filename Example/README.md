## SwiftUI Example (Recommended)

This repository now recommends Combine + SwiftUI usage.

The `SwiftUIExample/` folder contains a modern sample implementation targeting iOS 16+.

### Quick start

```bash
git clone https://github.com/keitaoouchi/FluxxKit.git
cd FluxxKit
open Example/SwiftUIExample
```

### Sample scenario

1. `SearchState` is an `ObservableObject` + `StateType`.
2. `StoreObject<SearchState, SearchAction>` connects FluxxKit store to SwiftUI updates.
3. `SearchMiddleware` performs async API requests and dispatches transition/update actions.
4. SwiftUI view binds to `state.phase` and `state.repositories`.
