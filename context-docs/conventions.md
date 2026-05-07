# Conventions

## Code
- Swift 5.10+, SwiftUI, iOS 17.6+.
- MVVM. ViewModels use `@Observable` (iOS 17+). Avoid `ObservableObject` unless interop needs it.
- Core Data entities expose computed properties for derived data; views never recompute totals.
- Money: `NSDecimalNumber` / `Decimal` only. Never `Double`/`Float` for currency.
- Errors on Core Data saves: `try` inside `do/catch`, surface to user with haptic warning. Never silently swallow.
- File layout: one type per file. Group by feature folder under `Views/`.
- No third-party SDKs without a roadmap entry. Keep the dependency graph empty.

## SwiftUI
- Prefer `NavigationStack` + value-based `navigationDestination`.
- Reusable styles live in `Components/`. View modifiers (`.planCard()`, `.adaptiveBackground()`) are preferred over duplicated chrome.
- Every interactive element gets `accessibilityLabel`.
- Use semantic system colors so dark mode is automatic.

## Design
See [`design-conv.md`](design-conv.md) for the full design system (color, type, spacing, motion, haptics, components, HIG divergences). Don't duplicate values here.

## Git
- Short, scannable commit subjects. Imperative ("add onboarding", "fix history delete").
- One concern per commit. Squash WIP before merge.
- Branch names: `feat/<slug>`, `fix/<slug>`, `chore/<slug>`.
- PRs reference an issue: `Closes #123`.

## Issues & PRs
- Title is the change, not the area. ("Cut Group Plans menu" not "Group Plans").
- Body: **Why**, **What**, **Acceptance**. Keep under 15 lines when possible.
- Labels: `bug`, `enhancement`, `blocker`, `polish`, `docs`, `release`.

## Testing
- Unit-testable logic lives in ViewModels and entity extensions, not Views.
- A change is "done" only after a real-device smoke test of the affected flow.
