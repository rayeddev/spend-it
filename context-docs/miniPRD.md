# SpendIt — Mini PRD

## Problem
Most budget apps track spending **after** it happens. By then it's too late.

## Promise
Decide where money goes **before** spending. Answer "can I afford this?" in under 5 seconds.

## Target user
Anyone who wants forward-looking budget control. Single-user, private. No social, no advisors.

## Core loop
1. Create a plan for a date range (default: month).
2. Add items as Income, Outcome, or Savings.
3. Read the live Remaining balance at the bottom.
4. Freeze items to model "what-if" scenarios without deleting them.
5. At plan end, clone forward (recurring or one-tap).

## Differentiators
- Forward-looking, not ledger-based.
- Freeze/unfreeze for what-ifs.
- Custom calculator with expression entry.
- Private by design: CloudKit only, no analytics, no servers.

## Non-goals (v1.0)
- Bank syncing / transaction import.
- Multi-user / family sharing.
- Reports, charts, insights.
- Cross-platform.

## Platform
- iOS 17.6+ (universal binary; iPhone first-class, iPad acceptable).
- SwiftUI + Core Data + CloudKit (private DB).
- No third-party SDKs.

## Monetization (v1.0)
Free. Subscription and Excel export deferred to v1.1+.

## Success signals
- D1 retention: user creates ≥1 item after creating a plan.
- D7 retention: user returns to the same plan or clones it.
- Crash-free sessions ≥ 99.5%.
