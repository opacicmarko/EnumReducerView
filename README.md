# EnumReducerView

EnumReducerView is a Swift macro that generates a View declaration for a TCA enum Reducer.

## Usage
The `EnumReducerView` macro currently assumes that you structure your child features like this:
```swift
import SwiftUI
import ComposableArchitecture

@Reducer
struct Feature {
    // The declaration of the feature's view is nested within the reducer body or extension.
    // The name of the view is the name of the feature with the "View" suffix appended.
    struct FeatureView: View {
    ...
    }
}
```

To use the macro, apply it to the desired enum Reducer type together with the `@Reducer` macro.
```swift
import ComposableArchitecture
import EnumReducerView

@EnumReducerView
@Reducer(state: .equatable)
enum Home {
    case details(Details)
    case settings(Settings)
}
```

The expansion in the example above results in the following code:
```swift
import ComposableArchitecture
import EnumReducerView

@Reducer(state: .equatable)
enum Home {
    case details(Details)
    case settings(Settings)
}
extension Home {
    public struct View: SwiftUI.View {
        let store: Store<State, Action>
        public var body: some SwiftUI.View {
            switch store.state {
            case .details:
                if let store = store.scope(state: \.details, action: \.details) {
                    Details.DetailsView(store: store)
                }
            case .settings:
                if let store = store.scope(state: \.settings, action: \.settings) {
                    Settings.SettingsView(store: store)
                } 
            }
        }
    }
}
```
