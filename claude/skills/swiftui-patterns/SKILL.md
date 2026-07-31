---
name: swiftui-patterns
description: SwiftUI architecture patterns, state management with @Observable, view composition, navigation, performance optimization, and modern iOS/macOS UI best practices.
---
# SwiftUI Patterns

Modern SwiftUI patterns: declarative, performant UI on Apple platforms. Covers Observation framework, view composition, type-safe navigation, performance optimization.

## When to Activate

- Building SwiftUI views, managing state (`@State`, `@Observable`, `@Binding`)
- Designing navigation flows with `NavigationStack`
- Structuring view models, data flow
- Optimizing render performance for lists, complex layouts
- Working with environment values, dependency injection in SwiftUI

## Architecture: MVVM boundaries

- **Model** — data + domain logic (types, Stores, Services). Unaware of View.
- **View** — dumb SwiftUI: renders state, forwards user events. Never reached into by VM.
- **ViewModel** — owns observable view state, translates Model → display, handles user intent,
  calls into Model layer.

Rule of thumb: **View dumb, Model unaware of View, ViewModel is translator.**

**ViewModel imports no UI framework.** `@Observable` comes from `Observation`, `@MainActor`
from concurrency — *not* SwiftUI — so VM can be `@Observable @MainActor` while importing only
`Foundation`/`Observation`. No `import SwiftUI`/`AppKit`, no `Color`/`NSImage`/`View`. Keeps
it testable without UI host, portable across UI frameworks, preserves dependency
direction (View → VM, never reverse). Expose plain data (`[Item]`, an enum), let View
decide render.

## Hosting SwiftUI in AppKit (Controller / coordinator)

Pure-SwiftUI apps use `Window`/`MenuBarExtra`/`NavigationStack` scenes, need no controller.
But when SwiftUI content lives in manually-managed window — global-hotkey panel, custom
`NSWindow`, status-bar popover — need **AppKit coordinator** (`NSWindowController`-style
object). Not part of MVVM; hosts MVVM stack inside native window.

Job: owns `NSWindow` + `NSHostingView<SomeView>`, drives show/hide lifecycle and
activation, computes on-screen positioning, **constructs and injects ViewModel**. All
`NSWindow`/`NSScreen`/AppKit glue lives here so VM stays UI-framework-free.

```swift
@MainActor
final class LauncherController {
    private var window: NSWindow?
    private let viewModel: LauncherViewModel

    init(store: any ItemStore) {
        self.viewModel = LauncherViewModel(store: store)   // composition point
    }

    func show() {
        if window == nil {
            let win = NSWindow(/* borderless panel */)
            win.contentView = NSHostingView(rootView: LauncherView(viewModel: viewModel))
            window = win
        }
        positionOnActiveScreen()
        window?.makeKeyAndOrderFront(nil)
    }

    func hide() { window?.orderOut(nil) }
}
```

## State Management

### Property Wrapper Selection

Choose simplest wrapper that fits:

| Wrapper | Use Case |
|---------|----------|
| `@State` | View-local value types (toggles, form fields, sheet presentation) |
| `@Binding` | Two-way reference to parent's `@State` |
| `@Observable` class + `@State` | Owned model with multiple properties |
| `@Observable` class (no wrapper) | Read-only reference passed from parent |
| `@Bindable` | Two-way binding to an `@Observable` property |
| `@Environment` | Shared dependencies injected via `.environment()` |

### @Observable ViewModel

Use `@Observable` (not `ObservableObject`) — tracks property-level changes so SwiftUI only re-renders views reading changed property:

```swift
@Observable
final class ItemListViewModel {
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    var searchText = ""

    private let repository: any ItemRepository

    init(repository: any ItemRepository = DefaultItemRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        items = (try? await repository.fetchAll()) ?? []
    }
}
```

### View Consuming the ViewModel

```swift
struct ItemListView: View {
    @State private var viewModel: ItemListViewModel

    init(viewModel: ItemListViewModel = ItemListViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
        }
        .searchable(text: $viewModel.searchText)
        .overlay { if viewModel.isLoading { ProgressView() } }
        .task { await viewModel.load() }
    }
}
```

### Environment Injection

Replace `@EnvironmentObject` with `@Environment`:

```swift
// Inject
ContentView()
    .environment(authManager)

// Consume
struct ProfileView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        Text(auth.currentUser?.name ?? "Guest")
    }
}
```

## View Composition

### Extract Subviews to Limit Invalidation

Break views into small, focused structs. When state changes, only subview reading that state re-renders:

```swift
struct OrderView: View {
    @State private var viewModel = OrderViewModel()

    var body: some View {
        VStack {
            OrderHeader(title: viewModel.title)
            OrderItemList(items: viewModel.items)
            OrderTotal(total: viewModel.total)
        }
    }
}
```

### Styling: token → modifier → style → environment

Centralize design decisions with **smallest tool that fully expresses the role**, in this
order of reach. Reaching too big = over-engineering; too small = drift.

| Tool | Reach | Use when role is… |
|------|-------|------------------------|
| **Semantic token** (`Font`/`Color` extension) | one property | single value, named by role: `.font(.settingsLabel)` |
| **`ViewModifier`** (`.settingsLabel()`) | bundle on one view | font **+** color + spacing + tracking together |
| **Custom `*Style`** (`ButtonStyle`, `ToggleStyle`, `LabeledContentStyle`) | interactive control | control with press/focus/disabled state |
| **`@Entry` environment value** | whole subtree | metric many views should inherit (padding, row width) |

**1. Tokens** — role-named, backed by Apple's semantic styles, never custom fixed sizes. Names give
clarity; semantic styles give Dynamic Type + platform defaults free:

```swift
extension Font {
    static let settingsLabel   = Font.body       // not .system(size: 13)
    static let settingsBadge   = Font.caption
    static let launcherTitle   = Font.system(.title2, design: .rounded)
}
```

**2. `ViewModifier`** — real unit of reusable *view* logic. Token centralizes one property;
reach here moment role means font + color + spacing. Tokens are base layer underneath:

```swift
struct SettingsLabel: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.settingsLabel).foregroundStyle(.secondary)
    }
}
extension View { func settingsLabel() -> some View { modifier(SettingsLabel()) } }

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding().background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
extension View { func cardStyle() -> some View { modifier(CardModifier()) } }
```

**3. Custom `*Style`** — for controls with state, prefer built-in style seams over hand-rolled
modifiers: get press/focus/disabled free, compose through environment.

**4. `@Entry` environment values** (iOS 17+/macOS 14+) — shared metrics subtree inherits, instead
of threading constants through inits:

```swift
extension EnvironmentValues {
    @Entry var settingsRowSpacing: CGFloat = 16
}
```

Don't build modifiers/styles speculatively — font-only role fully served by token. Promote to
next tier only when role actually needs more reach.

## Navigation

### Type-Safe NavigationStack

Use `NavigationStack` with `NavigationPath` for programmatic, type-safe routing:

```swift
@Observable
final class Router {
    var path = NavigationPath()

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}

enum Destination: Hashable {
    case detail(Item.ID)
    case settings
    case profile(User.ID)
}

struct RootView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Destination.self) { dest in
                    switch dest {
                    case .detail(let id): ItemDetailView(itemID: id)
                    case .settings: SettingsView()
                    case .profile(let id): ProfileView(userID: id)
                    }
                }
        }
        .environment(router)
    }
}
```

## Performance

### Use Lazy Containers for Large Collections

`LazyVStack` and `LazyHStack` create views only when visible:

```swift
ScrollView {
    LazyVStack(spacing: 8) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

### Stable Identifiers

Always use stable, unique IDs in `ForEach` — avoid array indices:

```swift
// Use Identifiable conformance or explicit id
ForEach(items, id: \.stableID) { item in
    ItemRow(item: item)
}
```

### Avoid Expensive Work in body

- Never do I/O, network calls, heavy computation inside `body`
- Use `.task {}` for async work — cancels automatically when view disappears
- Use `.sensoryFeedback()` and `.geometryGroup()` sparingly in scroll views
- Minimize `.shadow()`, `.blur()`, `.mask()` in lists — trigger offscreen rendering

### Equatable Conformance

For views with expensive bodies, conform to `Equatable` to skip unneeded re-renders:

```swift
struct ExpensiveChartView: View, Equatable {
    let dataPoints: [DataPoint] // DataPoint must conform to Equatable

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.dataPoints == rhs.dataPoints
    }

    var body: some View {
        // Complex chart rendering
    }
}
```

## Previews

Use `#Preview` macro with inline mock data for fast iteration:

```swift
#Preview("Empty state") {
    ItemListView(viewModel: ItemListViewModel(repository: EmptyMockRepository()))
}

#Preview("Loaded") {
    ItemListView(viewModel: ItemListViewModel(repository: PopulatedMockRepository()))
}
```

## References

See skill: `swiftui-anti-patterns` for SwiftUI pitfalls (async in `body`, misplaced
`@State`, styling drift, background-actor list resets).
See rules: `rules/swift/swift-anti-patterns.md` for forbidden list + structure conventions.
See skill: `swift-actor-persistence` for actor-based persistence, Service/Store pattern.
See skill: `swift-protocol-di-testing` for protocol-based DI, testing with Swift Testing.