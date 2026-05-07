# Design Conventions

Visual + interaction system for SpendIt. iPhone-first. Aligned with Apple HIG (iOS 17+) and the modern budgeting-app aesthetic (generous whitespace, oversized numbers, soft surfaces, kinetic feedback).

## 1. Voice & feel

- **Calm, not noisy.** Money apps make people anxious. We keep chrome minimal and let numbers breathe.
- **Forward-looking.** Visuals emphasize possibility (gradients, lift, motion) over judgment (no red warnings unless truly negative).
- **Tactile.** Every meaningful action gets a haptic + a micro-animation. The app should feel like a physical object.

## 2. Color

Semantic tokens — never hard-code hex outside this section.

| Token | Light | Dark | Use |
|---|---|---|---|
| `income` | systemGreen | systemGreen | Income items, positive deltas |
| `outcome` | systemRed | systemRed | Expense items, negative deltas |
| `savings` | systemBlue | systemBlue | Savings items, neutral-positive |
| `warning` | systemOrange | systemOrange | Remaining < 5% of income |
| `surface` | systemBackground | systemBackground | Page background |
| `surfaceElevated` | secondarySystemBackground | secondarySystemBackground | Cards, sheet backgrounds |
| `surfaceMuted` | tertiarySystemBackground | tertiarySystemBackground | Inset rows, calculator keys |
| `label` | label | label | Primary text |
| `labelSecondary` | secondaryLabel | secondaryLabel | Captions, meta |
| `labelTertiary` | tertiaryLabel | tertiaryLabel | Hints, disabled |
| `divider` | separator | separator | 0.33pt rules |

**Gradients** (already used in `GradientStyles`):
- `incomeGradient`: green → mint, 135°. Used on amount text in summary bar and row mini-summaries.
- `expenseGradient`: red → pink, 135°.
- `savingsGradient`: blue → cyan, 135°.

Gradients only on numbers and hero surfaces. Never on body text, never on icons.

**Frozen state:** 50% opacity on the entire row. No grayscale filter — color identity stays.

## 3. Typography

Native fonts only. SF Pro for prose, SF Pro Rounded for currency.

| Role | Font | Size | Weight | Notes |
|---|---|---|---|---|
| Display amount (calculator, summary hero) | SF Pro Rounded | 48 | Bold | Tabular figures |
| Plan title (detail) | SF Pro | 28 | Bold | `.largeTitle` |
| Section header | SF Pro | 13 | Semibold | UPPERCASE, `.tertiary` |
| Row title | SF Pro | 17 | Semibold | `.headline` |
| Row amount | SF Pro Rounded | 20 | Semibold | Tabular figures |
| Body | SF Pro | 17 | Regular | `.body` |
| Caption | SF Pro | 12 | Regular | `.caption` |
| Mini-amount (summary chip) | SF Pro Rounded | 13 | Bold | Abbreviated (1.2K) |

All sizes scale with **Dynamic Type**. Use semantic `.font(.headline)` etc. wherever possible; only override for amounts where rounded variant matters.

**Tabular figures rule:** every monetary number uses `.monospacedDigit()` or `.featureSettings("tnum")` so digits don't shift width during count-up animations.

## 4. Spacing & layout

8pt base grid. Never invent spacing values outside this scale.

| Token | pt | Use |
|---|---|---|
| `xxs` | 4 | Icon-to-label gap |
| `xs` | 8 | Inline element spacing |
| `sm` | 12 | Tight stacks |
| `md` | 16 | Edge padding, default stack |
| `lg` | 24 | Section gaps |
| `xl` | 32 | Above primary CTAs |
| `xxl` | 48 | Around hero numbers |

**Edge padding:** 16pt horizontal on all screens. Sheets get 20pt top.
**Touch targets:** 44pt minimum. Calculator keys 56pt.
**Safe areas:** respect always. Summary bar pinned above home indicator with 8pt gap.

## 5. Radii & elevation

- **Pill / chip:** fully rounded (`Capsule()`). Used for badges (Recurring, Group Plan, Ends in N days).
- **Card:** 16pt corner radius. Modern budgeting apps lean softer than HIG's default 10pt.
- **Sheet / modal:** system default (top-rounded).
- **Button:** 12pt corner radius. CTA buttons 14pt.
- **Calculator key:** 12pt.

**Elevation** (light mode):
- Cards: no shadow. Use `surfaceElevated` background for separation.
- Floating elements (FAB, snackbar): `shadow(color: .black.opacity(0.08), radius: 12, y: 4)`.
- Dark mode: replace shadows with a hairline `divider` stroke at 0.5pt — shadows disappear on dark surfaces.

**Materials:** prefer `.regularMaterial` for sheet backgrounds when content scrolls beneath. Use `.ultraThinMaterial` for the summary bar to give the "floating glass" feel iOS 17+ apps now expect.

## 6. Components

### Plan card (home list row)
- 16pt radius, `surfaceElevated` background, 16pt internal padding.
- Header: title (left) + status badge (right).
- Middle: date range (left, secondary) + remaining amount (right, color-coded).
- Footer: 3-column mini-summary (Income / Expenses / Savings), gradient text.
- Tap: full card. Long-press: context menu (Clone, Archive, Delete).

### Summary bar (plan detail, fixed bottom)
- 100pt tall. `.ultraThinMaterial` background. 16pt corner radius on top corners.
- Hero: Remaining amount, 36pt rounded bold, gradient (matches sign).
- Below: 3 chips (Income / Outcome / Savings) with mini-amounts.
- Updates animate in <100ms with count-up (see §7).

### Calculator
- Modal sheet, slides up. 300ms ease-out.
- Display: 48pt rounded bold, right-aligned, `surfaceMuted` background.
- Keys: 4×5 grid. 56pt targets. Operators in `savings` blue, equals in `income` green, clear in `labelSecondary`.
- Each tap: light haptic + 100ms key-press scale (0.96 → 1.0).

### List row (plan item)
- Leading: SF Symbol icon in colored circle (24pt symbol in 40pt circle).
- Title + optional note (single-line, truncate).
- Trailing: amount (rounded semibold) + freeze toggle (small switch).
- Swipe-leading: freeze/unfreeze. Swipe-trailing: delete (red).

### Floating Action Button (FAB)
- Bottom-trailing on plan detail. 56pt circle. `income` background. White SF Symbol.
- Shadow as defined in §5. Rises 4pt on press.
- Single action: "Add item." If multi-action ever needed, use a context menu, not a speed-dial.

### Sheets
- Use `.presentationDetents([.medium, .large])` for entry forms.
- Drag indicator visible. Background: `.regularMaterial`.
- Cancel = leading toolbar; Save = trailing toolbar, bold.

### Empty states
- Icon: 64pt SF Symbol with `.gradient` foreground.
- Title: 22pt bold.
- Body: 17pt regular, `labelSecondary`, max 2 lines, centered.
- CTA: filled prominent button below, 14pt corner radius.

### Badges
- Capsule, 10pt horizontal padding, 4pt vertical.
- Background: source color at 12% opacity. Foreground: source color at 100%.
- Examples: "Recurring" (savings blue), "Group Plan" (purple), "Ends in 3d" (warning orange).

## 7. Motion

Timing tokens — pick one, don't invent.

| Token | Duration | Curve | Use |
|---|---|---|---|
| `instant` | 100ms | easeOut | Key press, toggle ack |
| `quick` | 200ms | easeInOut | Opacity, color, freeze toggle |
| `standard` | 300ms | easeInOut | Sheet, summary update, calculator |
| `expressive` | 350ms | spring(response: 0.35, damping: 0.75) | Reorder, drop, hero appear |

**Principles:**
1. **Numbers count, they don't snap.** Summary amounts animate digit-by-digit on change (use `contentTransition(.numericText())`). 200-300ms.
2. **Springs for objects, easing for opacity.** A list row that drops uses spring; a fade-in uses ease.
3. **Origin matters.** A new item animates in from where it was added (FAB position). A deleted item collapses, doesn't disappear.
4. **Reduce Motion respected.** When enabled: replace all springs with 100ms cross-fade. Never disable feedback entirely.

## 8. Haptics

Map every haptic to an emotional intent, not a UI event.

| Pattern | Intent | Examples |
|---|---|---|
| Light impact | "Acknowledged" | Calculator tap, freeze toggle, switch |
| Medium impact | "Picked up" | Reorder pickup, FAB press |
| Rigid impact | "Locked in" | Save complete, plan created |
| Soft impact | "Released" | Reorder drop |
| Success notification | "Win" | Plan cloned, balanced, saved $ |
| Warning notification | "Slow down" | Destructive swipe, approaching $0 |
| Error notification | "Stop" | Save failed, validation error |

Never haptic-spam. Max 1 haptic per interaction. Skip on scroll.

## 9. Iconography

- **Library:** SF Symbols 5+. No custom icon set.
- **Variant:** `.fill` for selected/active, default for inactive.
- **Sizing:** match text baseline. `.font(.body).symbolRenderingMode(.hierarchical)`.
- **Color:** match the role (income items use a green-tinted symbol, etc.). For neutral chrome (toolbar, settings), use `label`.
- **Multicolor:** allowed for hero illustrations (empty states, onboarding) only.

## 10. Money & numbers

- **Always** `NSDecimalNumber` underneath. Never `Double`.
- **Currency formatter** is shared (`CurrencyFormatter.shared`). Always pass `currencyCode`.
- **Sign:** never show "+" for income (color carries the meaning). Show "−" for outcome only when displayed alongside income on the same row.
- **Abbreviation:** in tight UI (mini-summary chips, badges) use `abbreviatedString` (1.2K, 3.4M). Full precision in detail views.
- **Zero state:** "$0" not "$0.00" in chips. Full precision in calculator and detail.
- **Big numbers** get `.minimumScaleFactor(0.7)` so a $999,999.99 plan doesn't truncate.

## 11. Dark mode

- All colors are semantic — dark mode is automatic.
- Hairline `separator` instead of shadows on cards.
- Gradients keep their hue but lower saturation 10%.
- Test every screen in both modes. Screenshots for App Store: half light, half dark.

## 12. Accessibility floor

Non-negotiable. Every PR is checked against this list.

- VoiceOver label on every interactive element. Money rows: "Groceries, expense, $120, frozen" — composite label, not 4 separate reads.
- Dynamic Type: text scales from XS to AX5. Truncation acceptable on title rows; never on amounts.
- Contrast: WCAG AA minimum (4.5:1 body, 3:1 large). Test gradients against background.
- Reduce Motion: see §7.
- Reduce Transparency: replace materials with solid `surfaceElevated`.
- Bold Text: respected automatically via system fonts.
- Hit area: 44pt × 44pt minimum, even when visual is smaller.

## 13. HIG alignment

We follow HIG strictly except where modern budgeting apps have moved past it. Documented divergences:

| Topic | HIG default | Our choice | Why |
|---|---|---|---|
| Card corner radius | 10pt | 16pt | Softer, more "physical card" feel matches category leaders |
| Summary bar | toolbar/tab | floating glass material | Continuous visibility of remaining balance is the app's core promise |
| Empty state CTA | text button | filled prominent button | Single most important action on first run |
| Number changes | snap | count-up | Reinforces "live" recalculation, the differentiator |

Everywhere else: HIG wins. Navigation patterns, sheet presentation, swipe actions, share sheet, context menus — all stock.

## 14. Don't list

- No custom fonts.
- No custom icons (SF Symbols only).
- No skeuomorphic shadows or bevels.
- No emoji in UI strings (allowed in user data).
- No more than 3 colors in a single screen's chrome.
- No animation longer than 400ms.
- No modal stacked on modal.
- No tutorial popovers in the main flow (use onboarding instead).
- No badges that aren't actionable or informational about state.
