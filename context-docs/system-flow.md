# System Flow

```
SwiftUI Views ──▶ ViewModels (@Observable) ──▶ Core Data (NSManagedObjectContext)
                                                       │
                                                       ▼
                                          NSPersistentCloudKitContainer
                                                       │
                                                       ▼
                                          iCloud (private DB, per-user)
```

## Data
- `PlanEntity` 1—* `PlanItemEntity` (cascade delete).
- `PlanGroupEntity` (v1.1) groups one parent plan with N children.
- All money: `NSDecimalNumber`. No floats.

## Reactivity
- Views bind to Core Data via `@FetchRequest` / `@ObservedObject`.
- Computed totals (`totalIncome`, `remainingAmount`, …) live on `PlanEntity` and recompute on item change.
- Summary bar updates in <100ms.

## Sync
- CloudKit private DB only. No server.
- Conflict policy: last write wins.
- Offline writes queue and replay on reconnect.

## Side effects
- `HapticManager` for feedback.
- `CurrencyFormatter` for display.
- No network calls outside CloudKit.
