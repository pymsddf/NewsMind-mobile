# NewsMind AI — Full Layout Redesign Plan

Adopt the **Stitch "Editorial Clarity"** layouts (in `stitch_newsmind_ai_journalism_app/`) across the whole app, while keeping the project's existing **Newsprint / Verdict Desk** identity untouched: same colors, same logo, same fonts.

> **One sentence:** We borrow Stitch's *structure and composition*, never its *skin*. Every color, font, and the wordmark stay as they are today.

---

## Status (June 2026 — live)

**Key finding:** the app was already ~90% re-skinned to the Newsprint/editorial identity in the June re-skin ([[verdict-desk-redesign]]). Most screens already use `AppColors`/`AppType`/`VectorCard` and the signature widgets (`VerdictStamp`, `CredibilityArc`, `BiasSpectrum`, `DeskLabel`, `ProofMark`) — i.e. **CP-2's components already exist**. So this effort is targeted gap-filling, not a wholesale rewrite. Churning the already-editorial screens would destroy good work.

- **CP-0 baseline** — ✅ `flutter analyze` clean.
- **Intelligence (the real gap)** — ✅ `todays_intelligence_screen.dart` rewritten to match web `/intelligence` (hero, pulse-dot+time eyebrow, topic chip, Fraunces headline, Newsreader preview, 5-bar credibility meter, ink arrow). The merge: `news_feed_screen.dart` is dead code (only self-referenced) → retire.
- **Login** — ✅ hero title moved to Fraunces masthead for consistency.
- **Already editorial (verified, left as-is):** fact-checking, bias-detection, splash, history (standalone), notification (standalone). These are done — do NOT rewrite.
- **Routing (CP-1)** — ✅ added GoRoutes `/notifications`, `/history`, `/subscription` (the standalone screens were styled but orphaned). Home notification icon now pushes `/notifications` (full screen > dialog on mobile).
  - **Deviation from earlier decision:** history stays as the `HistoryPanel` overlay in `home_screen`, NOT promoted to the standalone route — the overlay has tap-to-prefill-tab (`_openHistoryItem`) that the standalone read-only `HistoryScreen` lacks. Promoting it would *lose* that feature. The `/history` route exists for deep-linking; the in-app entry keeps the richer overlay.
- **Remaining (optional):** register/forgot-password/profile/news-generation/subscription polish (already token-correct; cosmetic only), `/verify-email` screen (only if the register flow actually needs an OTP step — not currently wired), `/article/:id` route (detail already opens via `Navigator.push`).

---

## 0. Non‑negotiable guardrails (do NOT change)

These are the project's source of truth and must be preserved exactly:

- **Colors** — only `AppColors.*` tokens from `lib/theme/intelligence_design_system.dart`. No raw hex from Stitch (`#003fdd`, `#f9f9f7`, etc.). Stitch's indigo/blue brand is forbidden.
- **Logo** — `assets/logo.png` + `NewsMindBrandTitle` (`lib/widgets/newsmind_brand_title.dart`). "NewsMind" ink + "AI" press‑red italic. Do not redraw or recolor.
- **Fonts** — `AppType` only: Fraunces (`headline`), Newsreader (`display`/serif), Schibsted Grotesk (`ui`/sans), IBM Plex Mono (`data`). Stitch's Inter/JetBrains Mono are NOT introduced.
- **Radius** — `AppRadius` (4/6/8, squared editorial). Do NOT adopt Stitch's 16px soft cards.
- **Runtime palette rule** — colors are mutable statics swapped by `AppColors.applyMode()`. **Never wrap color‑bearing widgets in `const`** (the `prefer_const_*` lints are disabled for this reason). New widgets follow the same rule.
- **Backend** — `lib/config/api_config.dart` stays `https://newsmindexp.ddfrl.com`. No API/model/service changes. This is a **layout‑only** redesign.
- **Feature parity** — Basic vs Generator tab logic, history prefill, auth redirects must keep working identically.

---

## 1. Stitch → App token translation (apply this to every screen)

| Stitch "Editorial Clarity" | → Project token | Notes |
|---|---|---|
| Paper `#f9f9f7` | `AppColors.paper` | warm cream |
| Card white `#ffffff` | `AppColors.surface` | warm white stock |
| Input field | `AppColors.surfaceAlt` | |
| Editorial Indigo `#003fdd` (brand/links/nav) | `AppColors.ink` (primary) + `AppColors.redline` (the one accent) | **kill the blue** |
| Section labels (blue caps) | `AppColors.redline` or `AppColors.neutral` | use mono `AppType.data` for the eyebrow |
| Verified green | `AppColors.verified` | |
| Bias amber | `AppColors.caution` | |
| Critical red | `AppColors.redline` | |
| Neutral/info | `AppColors.neutral` (ink‑blue) | |
| Newsreader headline | `AppType.headline(...)` (Fraunces) | screen titles/verdicts |
| Inter body/UI | `AppType.ui(...)` (Schibsted Grotesk) | |
| Inter long‑form | `AppType.display(...)` (Newsreader) | article reading |
| JetBrains Mono data | `AppType.data(...)` (IBM Plex Mono) | scores, timestamps |
| 16px card radius | `AppRadius.lg` (8) | |
| 8px button radius | `AppRadius.md` (6) | |
| Pill chips | `AppRadius.pill` | keep pills for credibility chips |
| 20px screen margin | `AppSpace.md`–`lg` | |

---

## 2. Route map

Current routing (`lib/config/router.dart`) is shallow: `/`, `/login`, `/register`, `/forgot-password`, `/home`. Everything else lives as IndexedStack tabs / popups / panels inside `HomeScreen`. The redesign **keeps the shell** but promotes detail screens to real routes so Stitch's dedicated screens have a home.

| # | Route | Screen file | Stitch source | Status |
|---|---|---|---|---|
| 1 | `/` | `splash_screen.dart` | `splash_screen` + `newsmind_ai_logo` | exists |
| 2 | `/login` | `login_screen.dart` | `login` | exists |
| 3 | `/register` | `register_screen.dart` | `register` | exists |
| 4 | `/verify-email` | `verify_email_screen.dart` | `verify_your_email` | **NEW** |
| 5 | `/forgot-password` | `forgot_password_screen.dart` | `reset_password` | exists |
| 6 | `/home` | `home_screen.dart` (shell) | bottom nav | exists |
| 6a | tab → Home (merged) | `todays_intelligence_screen.dart` (keep) | `today_s_intelligence` + `news_feed` | **merge** |
| ~~6b~~ | ~~Feed~~ | `news_feed_screen.dart` | folded into 6a | **consolidate/remove** |
| 6c | tab → Generate | `news_generation_screen.dart` | `generate_news` | exists (Generator only) |
| 6d | tab → Verify | `fact_checking_screen.dart` | `fact_check_result` | exists |
| 6e | tab → Bias | `bias_detection_screen.dart` | `bias_analysis` | exists |
| 6f | tab → Profile | `profile_screen.dart` | `profile_settings` | exists |
| 7 | `/article/:id` | `news_detail_screen.dart` | `article_detail` | promote to route |
| 8 | `/notifications` | `notification_screen.dart` | `notifications` | promote to route |
| 9 | `/history` | `history_screen.dart` | `activity_history` | promote to route |
| 10 | `/subscription` | `subscription_screen.dart` | `premium_plans` | promote to route |
| 11 | `/subscription/create` | `create_subscription_screen.dart` | — | promote to route |

> **Resolved:** **Merge** `news_feed` + `today_s_intelligence` into ONE home list (tab 1). The two Stitch takes ("Your Daily Briefing" header + the prioritized claim list) become a single surface; `news_feed_screen.dart` and `todays_intelligence_screen.dart` consolidate (keep one, fold the other's best bits in, delete or redirect the spare). Update `_screens` order and `_switchTab`/`_openHistoryItem` indices accordingly.

---

## 3. Shared components (build first — every screen depends on these)

Redesign these once in `lib/widgets/`, then reuse. Match Stitch composition, paint with `AppColors`/`AppType`.

- [ ] **C1 — News card** (`vector_card.dart` / `swipeable_news_card.dart`): thumbnail, mono eyebrow (category · time), Fraunces headline, source row, credibility chip top‑right. Stitch `news_feed`.
- [ ] **C2 — Credibility chip / pill** (in `verdict_stamp.dart`): Verified/Bias/Disputed pills using `verified`/`caution`/`redline` + `verifiedSoft` etc.
- [ ] **C3 — Score gauge** (`score_indicator.dart` / `data_visualization.dart`): circular "Source Credibility 85%" ring in IBM Plex Mono. Stitch `fact_check_result`.
- [ ] **C4 — Verdict banner** (`verdict_stamp.dart`): full‑width "VERDICT: FALSE" bar (`redline`/`verified`/`caution`). Stitch `fact_check_result`.
- [ ] **C5 — Bias spectrum meter** (`data_visualization.dart` `BiasSpectrum`): left/right lean bar. Stitch `bias_analysis`.
- [ ] **C6 — Bottom nav** (in `home_screen.dart`): Stitch 5‑tab frosted bar, active = `AppColors.indigo`(ink) icon + 2px indicator. Keep Basic(4)/Generator(5) variants.
- [ ] **C7 — Evidence/source card** (verify + bias): source type chip, title, snippet, external‑link affordance.
- [ ] **C8 — Section eyebrow** label helper: mono uppercase (`CLAIM ANALYZED`, `EVIDENCE SOURCES`).

---

## 4. Phased checkpoints

Each checkpoint is independently shippable and must end green: `flutter analyze` clean + app builds + **light AND dark mode verified** for every screen touched in that phase. Do **not** start a phase before the previous one's box is checked.

### ✅ CP‑0 — Baseline & safety net
- [ ] `flutter analyze` recorded as baseline; note any pre‑existing warnings.
- [ ] Confirm app runs (`flutter run`) on current theme; screenshot Intelligence + Verify for before/after.
- [ ] Re‑read guardrails (§0) — confirm no token/logo/font edits will happen.

### ✅ CP‑1 — Routing skeleton
- [ ] Add routes 4, 7–11 to `lib/config/router.dart` (keep redirect/auth logic intact).
- [ ] Create `verify_email_screen.dart` stub wired into the register → verify flow.
- [ ] **Promote** notifications + history from `showDialog`/overlay panel to full routed screens (`/notifications`, `/history`); switch entry points to `context.push(...)` and retire the popup/panel paths once the screens land in CP‑7.
- **Accept:** every route navigates without crashing; auth redirect still gates protected routes.

### ✅ CP‑2 — Shared components (§3 C1–C8)
- [ ] Build/redesign C1–C8 against `AppColors`/`AppType`/`AppRadius`.
- [ ] No raw hex, no `const` on color‑bearing widgets, no new font families.
- **Accept:** a throwaway gallery screen renders all 8 components correctly in **both** light and dark (`AppColors.applyMode`).

### ✅ CP‑3 — Auth & onboarding cluster
Screens: splash, login, register, verify‑email, forgot/reset‑password.
- [ ] Apply Stitch layouts (centered masthead, generous spacing, paper bg, ink buttons).
- [ ] Logo via `NewsMindBrandTitle` only.
- **Accept:** full signup → verify → login → reset loop works; visuals match Stitch composition in project skin.

### ✅ CP‑4 — Home shell + merged home list
Screens: `home_screen` (shell, app bar, bottom nav C6), `todays_intelligence_screen` (now the single home list).
- [ ] **Merge** `news_feed_screen` into `todays_intelligence_screen`: one list = "Your Daily Briefing" header + prioritized claim cards (C1). Delete/redirect the spare file.
- [ ] App bar: masthead left; history + notification actions now `push('/history')` / `push('/notifications')`; logout action.
- [ ] "Load More" footer; scroll/refresh preserved.
- [ ] Re‑index Basic/Generator tab sets after the merge; update `_switchTab` + `_openHistoryItem` to match.
- **Accept:** both tiers show correct tabs; merged list scrolls/refreshes; **dark mode verified**.

### ✅ CP‑5 — Analysis screens
Screens: `fact_checking_screen` (C3/C4/C7), `bias_detection_screen` (C5/C7), `news_generation_screen`.
- [ ] Verify: claim eyebrow → verdict banner → credibility gauge → AI analysis → evidence sources.
- [ ] Bias: spectrum meter → dimension breakdown → key phrases → recommendations.
- [ ] Generate: input controls → streamed/result article body in Newsreader.
- [ ] Keep history **prefill** (`prefill()` on each screen's State) working.
- **Accept:** run a real fact‑check, bias, and generation end‑to‑end against the live backend; results render in new layout.

### ✅ CP‑6 — Article detail & content
Screen: `news_detail_screen` via `/article/:id`.
- [ ] Stitch `article_detail`: hero, Fraunces headline, mono byline/meta, Newsreader body, inline credibility.
- **Accept:** open an article from a feed card → detail route renders; share/back work.

### ✅ CP‑7 — Profile, notifications, history, subscription
Screens: `profile_screen`, `notification_screen`, `history_screen`, `subscription_screen`, `create_subscription_screen`.
- [ ] Profile: settings groups + **Appearance** card with the existing light/dark toggle (`ThemeController`) preserved.
- [ ] Notifications: full routed screen (`/notifications`), Stitch list; mark‑read. Remove old popup.
- [ ] History (activity): full routed screen (`/history`), Stitch `activity_history` list; tapping an item routes back into the right analysis tab via `_openHistoryItem` (using post‑merge indices). Remove old overlay panel.
- [ ] Premium: Stitch `premium_plans` tiers → existing subscription flow.
- **Accept:** theme toggle still swaps palette app‑wide; subscription purchase flow unbroken.

### ✅ CP‑8 — Polish & verification
- [ ] Full pass for stray Stitch hex / Inter / 16px radii / accidental `const` (grep).
- [ ] Light **and** dark mode sweep of every screen.
- [ ] `flutter analyze` clean (no new warnings vs CP‑0 baseline).
- [ ] Side‑by‑side before/after screenshots of all screens.
- **Accept:** sign‑off; update the `verdict-desk-redesign` memory if the layout system changed materially.

---

## 5. Risks & watch‑outs

- **`const` regressions** — adding `const` to a color widget freezes it at light‑mode values; dark mode breaks silently. Lints won't catch it (disabled). Verify dark mode every phase.
- **Tab index coupling** — `home_screen._switchTab` / `_openHistoryItem` hardcode Basic vs Generator indices. Changing tab order breaks history navigation. Don't reorder tabs without updating both.
- **Generator‑only Generate tab** — `_canGenerate` gates a 4‑ vs 5‑tab nav. Test both tiers.
- **Stitch ≠ feature‑complete** — Stitch mockups omit edge states (errors, empty, loading skeletons via `vector_skeleton.dart`). Carry those over from current screens.
- **Promoting popups to routes** — notifications/history currently render as `showDialog`/overlay panel. If routing causes regressions, keep them as overlays and only restyle. Decide per‑screen in CP‑1/CP‑7.

---

## 6. Resolved decisions

1. **Home list** — ✅ **Merge** `news_feed` + `today_s_intelligence` into one home surface (tab 1). See §2 / CP‑4.
2. **Notifications & History** — ✅ **Promote to full routes** (`/notifications`, `/history`); retire the popup/overlay. See CP‑1 / CP‑7.
3. **Dark mode** — ✅ **Verify dark mode every phase** (each CP's acceptance includes a light + dark check), not deferred to a final sweep.
