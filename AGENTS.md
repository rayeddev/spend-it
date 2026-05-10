# AGENTS.md

Operating manual for AI agents working on this repo.

> Human-facing intent lives in [`context-docs/`](context-docs/). Read those before editing.

## 1. Read first (every session)
1. [`context-docs/miniPRD.md`](context-docs/miniPRD.md) — what we're building and why.
2. [`context-docs/roadmap.md`](context-docs/roadmap.md) — current status + active milestone.
3. [`context-docs/system-flow.md`](context-docs/system-flow.md) — architecture in one screen.
4. [`context-docs/conventions.md`](context-docs/conventions.md) — code, git rules.
5. [`context-docs/design-conv.md`](context-docs/design-conv.md) — UI/UX design system (read before any view change).
6. [`context-docs/appstore.md`](context-docs/appstore.md) — App Store submission kit (copy, screenshots, checklist).

If a fact lives in code or `git log`, do **not** duplicate it here.

## 2. Workflow (agent-native)

Each unit of work follows this loop. Never skip steps.

```
plan ─▶ issue ─▶ implement ─▶ review ─▶ test ─▶ release ─▶ changelog ─▶ submit
```

| Step | Action | Required signal |
|---|---|---|
| **plan** | Restate the goal in 3–5 lines. Identify files to touch. Ask before designing for hypothetical needs. | Plan written in chat or PR description. |
| **issue** | Use `gh issue create`. Attach to active milestone. Apply labels. One concern per issue. | `Closes #N` will appear in PR. |
| **implement** | Smallest change that satisfies the acceptance criteria. No drive-by refactors. Follow `conventions.md`. | Diff is scoped to the issue. |
| **review** | Self-review the diff against [`context-docs/conventions.md`](context-docs/conventions.md). Use the `Explore` agent for a second pass on non-trivial changes. | "Reviewed by …" note in PR. |
| **test** | Build the project. Run unit tests if present. Smoke-test the affected flow on Simulator (and on a real device for anything touching CloudKit, haptics, or notifications). | Test results pasted in PR. |
| **release** | Bump `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` only when cutting a build. Tag `vX.Y.Z` in git. | Tag pushed, archive built. |
| **changelog** | Append to `CHANGELOG.md` (create if missing). One bullet per user-visible change. Group by version. | New version section present. |
| **submit** | Archive in Xcode → upload via Organizer or `xcodebuild -exportArchive`. Update App Store Connect metadata. | Build appears in App Store Connect. |

**Branching:** `feat/<slug>`, `fix/<slug>`, `chore/<slug>`. PR title mirrors the issue title.

**Commits:** short, scannable, imperative. ("cut group plans menu", not "Refactored the home screen to remove the group plans entry").

## 3. Required signals for proper docs

Update these whenever the listed trigger occurs. If you didn't update them, the change isn't done.

| Trigger | Update |
|---|---|
| New feature shipped | `context-docs/miniPRD.md` (only if it changes the promise / non-goals), `CHANGELOG.md` |
| Milestone changed or issues moved | `context-docs/roadmap.md` |
| New entity, sync rule, or data flow | `context-docs/system-flow.md` |
| New code rule introduced or violated then corrected | `context-docs/conventions.md` |
| New visual/interaction pattern, motion, or HIG divergence | `context-docs/design-conv.md` |
| Architectural shift (e.g. add a dependency, change minimum iOS) | `context-docs/system-flow.md` + `miniPRD.md` |
| Build / test / submission process changes | this file (`AGENTS.md`) |

Do **not** create new top-level docs without removing or merging an old one.

## 4. Project essentials

### Build
```bash
# Open in Xcode
open spenditapp.xcodeproj

# Or build from CLI
xcodebuild -project spenditapp.xcodeproj \
  -scheme spenditapp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build
```

- **Bundle ID:** `com.raedali.spenditapp`
- **Team:** `B85UCT5Q28`
- **iOS deployment:** 17.6+
- **Target devices:** iPhone + iPad (universal)
- **Marketing version / build:** `1.0` / `1`
- **iCloud container:** private CloudKit DB
- **No external dependencies.** Do not introduce SPM/CocoaPods packages without a roadmap entry.

### Test
```bash
xcodebuild -project spenditapp.xcodeproj \
  -scheme spenditapp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  test
```

No test target exists yet. When adding one, create `spenditappTests/` and use the standard `XCTest` template. CloudKit and haptic flows must be smoke-tested on a real device — Simulator does not exercise either reliably.

### Submission (App Store)
1. `Product → Archive` in Xcode (or `xcodebuild archive`).
2. Validate in Organizer.
3. Upload to App Store Connect.
4. Required in App Store Connect:
   - Privacy Policy URL (real, app-specific — not a generic placeholder).
   - Age rating questionnaire.
   - Export compliance: "No" (app does not implement custom encryption).
   - Screenshots: 6.7" + 6.5" iPhone, plus 12.9" iPad if shipping universal.

## 5. Suggested MCP / plugins for testing

The harness this repo runs under has these available — use them before building anything custom.

- **`agent-browser` skill** — for any web-side flow (Privacy Policy hosting, App Store Connect navigation, Gist/GitHub Pages setup). Trigger words: "open", "fill form", "screenshot", "submit form".
- **`gh` CLI** — issues, PRs, milestones (via `gh api repos/:owner/:repo/milestones`), releases. Already authenticated.
- **`xcodebuild` + `xcrun simctl`** — build, install on simulator, capture screenshots:
  ```bash
  xcrun simctl io booted screenshot ~/Desktop/spendit-home.png
  ```
  Useful for generating App Store screenshots from seeded data.
- **`Explore` agent** — for broad codebase questions (>3 searches). Use this instead of grepping repeatedly.
- **`review` skill / `/review`** — pre-merge review of a PR or branch.
- **`security-review` skill** — run before submission to catch obvious issues.

### Not currently wired (consider adding if needed)
- An MCP server for **App Store Connect API** would let agents update metadata, screenshots, and submit builds without leaving the loop. None is configured today. If submission tempo increases, add one.
- **Snapshot testing** (e.g. `pointfreeco/swift-snapshot-testing`) would let agents verify UI changes without a device. Not present yet — would be a v1.1 addition.

## 6. Hard rules

- Never commit secrets. The `.gitignore` is authoritative.
- Never disable signing or skip hooks (`--no-verify`) without explicit user approval.
- Never run destructive git ops (`reset --hard`, `push --force`, branch delete) on shared branches without confirming.
- Never add a dependency, analytics SDK, or background network call. The privacy story is a feature.
- If a memory or doc contradicts the code, trust the code and update the doc.
