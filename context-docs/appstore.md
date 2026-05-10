# App Store Submission Kit

Source-of-truth copy + checklist for submitting SpendIt to the App Store. Update for each version.

---

## v1.0

**Status:** drafting · target submission ≤ 2026-05-10.

### App identity

| Field | Value |
|---|---|
| App name (App Store) | `SpendIt` |
| Subtitle (≤ 30 char) | `Plan before you spend.` |
| Bundle ID | `com.raedali.spenditapp` |
| Primary category | Finance |
| Secondary category | Productivity |
| Age rating | 4+ (no objectionable content; questionnaire all "No") |
| Pricing | Free, all territories |
| Devices | iPhone only (per [#8](https://github.com/rayeddev/spend-it/issues/8)) |

### Promotional text (≤ 170 chars — updateable without resubmit)

> Decide where your money goes — before you spend it. SpendIt is the planner for people who'd rather feel in control than guilty. No banks. No tracking.

### Description (≤ 4000 chars)

```
Most apps tell you where your money went. By then, it's too late.

SpendIt is different. It helps you decide where your money should go BEFORE you spend it. Plan your month in five minutes, then go live your life knowing exactly what's safe to spend.

— PLAN, DON'T TRACK —
Create a plan for any date range — a month, a paycheck cycle, a vacation. Add what you'll earn, what you'll spend, what you'll save. SpendIt shows you instantly whether the numbers work.

— LIVE BALANCE —
Every change recalculates the moment you make it. Add a $200 expense, watch your remaining balance drop in real time. No spreadsheets, no end-of-month surprises.

— FREEZE FOR WHAT-IFS —
Tempted to skip the gym membership this month? Freeze it. The number disappears from your balance without losing the item. Unfreeze when you're ready. Model your decisions before you make them.

— BUILT-IN CALCULATOR —
Quick math, right inside the amount field. Type "1500 + 200" and the app figures it out. No switching apps to add up your dinners.

— PRIVATE BY DEFAULT —
SpendIt has no servers. Your data lives only on your devices and your private iCloud. No accounts to create, no analytics, no third parties, no ads. Ever.

— ICLOUD SYNC —
Edit on your iPhone, see it on your iPad and Mac (coming soon). Sync is automatic and end-to-end private to your Apple ID.

— DESIGNED FOR iOS —
Native SwiftUI. Dark mode. Dynamic Type. VoiceOver. Built the way iOS apps should feel: fast, tactile, calm.

—

SpendIt is free. Forever. We don't sell your data and we don't run ads, because we don't have any data on you to sell.

Plan first. Spend confident.
```

### Keywords (≤ 100 chars, comma-separated, no spaces)

```
budget,planner,money,finance,spending,savings,allowance,monthly,paycheck,track,plan,budgeting
```

(94 chars)

### What's New in This Version (release notes)

```
First release. Plan your spending before you spend it.
```

### URLs

| Field | URL |
|---|---|
| Privacy Policy | `https://rayeddev.github.io/spend-it/privacy/` |
| Terms (EULA) | Apple Standard EULA (don't fill custom) |
| Marketing URL | `https://rayeddev.github.io/spend-it/` |
| Support URL | `https://github.com/rayeddev/spend-it/issues` |

### Export compliance

- Uses non-exempt encryption: **No** (only HTTPS via system frameworks).
- ITSAppUsesNonExemptEncryption: skip declaration in Info.plist or set to `false`.

### Age rating questionnaire

All answers: **None / No**. The app is a budgeting calculator with no UGC, network social features, or content delivery.

---

## Screenshots

Required: **6.7" iPhone display** (iPhone 17 Pro Max simulator, 1290 × 2796px). Optional 6.5" supported. iPhone-only target = no iPad screenshots needed.

Capture on the simulator with seeded data:

```bash
xcrun simctl boot "iPhone 17 Pro Max"
# … run the app, navigate, then capture:
xcrun simctl io booted screenshot ~/Desktop/01-home.png
```

### Screenshot order + captions (≤ 30 chars each, shown above the image)

| # | Screen | Caption | Notes |
|---|---|---|---|
| 1 | Home — plan list with 2-3 plans | "Plan your money." | Hero shot; show variety: 1 active, 1 upcoming, 1 historical |
| 2 | Plan detail — items + summary bar | "Live balance, live." | Show 6-8 items, mix of income/expense/savings, summary bar visible |
| 3 | Calculator open over an item | "Quick math, built in." | Mid-expression: `1500 + 200` |
| 4 | Plan detail — one item frozen | "Freeze to see what-if." | Frozen item at 50% opacity, balance reflects without it |
| 5 | Onboarding screen 2 | "Color-coded clarity." | Or use empty state with CTA visible |

Both **light and dark mode**: submit 5 light + 5 dark, or alternate (Apple allows up to 10).

### Seeding script (manual, before capture)

1. Erase simulator content.
2. Skip onboarding.
3. Create plan: `April Budget`, $4,200 income, recurring monthly.
4. Add items:
   - Income: Salary $4,000, Freelance $200
   - Expenses: Rent $1,500, Groceries $400, Utilities $120, Gym $60, Dining $150, Phone $50
   - Savings: Emergency Fund $300, Vacation $200
5. Create another plan: `Summer Trip`, upcoming, smaller numbers.
6. Capture each screenshot per the table above.

---

## Submission checklist

Run through in order. Tick as completed.

### Before archiving
- [ ] All v1.0 PRs merged
- [ ] `MARKETING_VERSION` = `1.0`, `CURRENT_PROJECT_VERSION` = `1` in `project.pbxproj`
- [ ] `TARGETED_DEVICE_FAMILY` = `"1"` (iPhone only)
- [ ] Privacy Policy URL resolves: `https://rayeddev.github.io/spend-it/privacy/`
- [ ] Terms URL resolves: `https://rayeddev.github.io/spend-it/terms/`
- [ ] In-app Settings: both legal links open the right pages
- [ ] App icon present in Asset Catalog (1024×1024 marketing icon mandatory)
- [ ] Real-device smoke test: create plan → add items → freeze → clone → CloudKit roundtrip → delete history (with confirm) → onboarding replays after fresh install

### Archive + upload
- [ ] Xcode → Product → Destination: `Any iOS Device (arm64)`
- [ ] Product → Archive
- [ ] Validate App in Organizer (catches signing/icon issues)
- [ ] Distribute App → App Store Connect → Upload
- [ ] Wait for "ready to submit" email (~10 min)

### App Store Connect metadata
- [ ] Create new app: bundle ID `com.raedali.spenditapp`, primary language English (US), name `SpendIt`, SKU `spendit-ios-1`
- [ ] Paste copy from this doc into all metadata fields
- [ ] Upload 5–10 screenshots (light + dark)
- [ ] Set Privacy Policy URL
- [ ] Complete Privacy Nutrition Label: "Data Not Collected" for all categories
- [ ] Age rating questionnaire: all None
- [ ] Export compliance: no non-exempt encryption
- [ ] Pricing & Availability: Free, all territories
- [ ] Select uploaded build
- [ ] Submit for Review

### After submission
- [ ] Review timer starts (typically 24-48h)
- [ ] If rejected: read feedback, fix on a `fix/asc-<reason>` branch, resubmit
- [ ] On approval: choose "Manual Release" so you push the button when ready

---

## Notes

- Apple's review is fastest when copy + screenshots match what the app actually does. Don't overpromise (no "AI", no "investment advice").
- **Privacy Nutrition Label** is required and audited. Since SpendIt has no analytics/SDKs/servers, every category answers "Data Not Collected".
- **CloudKit** does not count as data collection by the developer — Apple stores it for the user.
- **Subscription / IAP** removed for v1.0. If you re-add in v1.1, this kit needs an "In-App Purchases" section.
- Re-uploading after rejection requires bumping `CURRENT_PROJECT_VERSION`. Marketing version stays `1.0` until v1.1.
