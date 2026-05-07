# Roadmap

Source of truth for status. Detail lives in GitHub issues.

## Status
- **v1.0**: in progress — App Store submission target, weekend of 2026-05-09.
- **v1.1+**: planned.

## v1.0 — App Store Submission (Milestone)
Goal: ship a stable, single-plan core. Cut anything half-built.

GitHub milestone: [v1.0 App Store Submission](https://github.com/rayeddev/spend-it/milestone/1) · due 2026-05-10.

Issues are tracked there. Highlights:

- **Blockers**
  - [#1](https://github.com/rayeddev/spend-it/issues/1) Cut or stabilize Group Plans feature.
  - [#2](https://github.com/rayeddev/spend-it/issues/2) Remove or implement Subscription / IAP placeholders.
  - [#3](https://github.com/rayeddev/spend-it/issues/3) Add real Privacy Policy + Terms.
  - [#4](https://github.com/rayeddev/spend-it/issues/4) Prepare App Store submission assets.
- **High UX impact**
  - [#5](https://github.com/rayeddev/spend-it/issues/5) First-run onboarding (3 screens).
  - [#6](https://github.com/rayeddev/spend-it/issues/6) End-of-plan signal (expiring-soon badge).
  - [#7](https://github.com/rayeddev/spend-it/issues/7) Confirm dialog on history delete.
- **Release config**
  - [#8](https://github.com/rayeddev/spend-it/issues/8) Decide iPhone-only vs universal and verify iPad.

## v1.1 (planned)
- Group Plans (yearly parent + 12 monthly children) — re-introduced with tests.
- Auto-prompt for recurring plans (notification 3 days before end).
- Subscription via StoreKit 2 (if monetization is decided).

## v1.2+ (icebox)
- Excel export ($6.99 IAP).
- Carry-forward savings.
- Widgets, Siri Shortcuts, Apple Watch.
- Localization beyond English.

## Conventions
- One issue per change. Link the milestone.
- Roadmap is short. Don't restate issue bodies here.
