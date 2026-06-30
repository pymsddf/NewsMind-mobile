# NewsMind AI — Topic-Based Real News Feed (Epic Plan)

Pivot the home **Intelligence** feed from per-user AI-generated subscription articles to a **shared, real-time, aggregated real-news feed** filtered by each user's chosen topics, with real photos and a per-user swipe-to-dismiss.

> Spans **mobile** (`newsmind_mobile`) **and backend** (`NewsMind AI/backend`). See the blocker in §1 before starting backend work.

---

## 0. Locked decisions (from the user)

| Question | Decision |
|---|---|
| What is each feed article? | **Real aggregated headlines** (real published news, real-time) — no longer AI-written |
| Image source | **Scrape `og:image`** from each article's source URL; fall back to RSS media, then topic stock image |
| Swipe action | **Per-user dismiss/hide** (remove from *this user's* feed, KEEP in DB for the future "search news" feature) — NOT a hard global delete |
| Subscriptions | **No manual creation, no time settings** — the user's ≤3 topic picks ARE the subscription; delivery cadence is just "daily/continuous" |
| Onboarding | First signup/login → topic picker, choose **max 3** topics |
| Home tab | Intelligence (already the home tab) |

---

## 1. Backend source — present & editable (earlier "blocker" was a false alarm)

The full backend IS on disk at `D:\Internships projects\DDF\NewsMind AI\backend` and editable. A direct `ls` confirms all the relevant files exist:
- `routes/subscriptionRoutes.js`, `routes/agentRoutes.js`, `routes/paymentRoutes.js`, …
- `services/schedulerService.js`, `services/ai/`, …
- `models/subscriptionModel.js`, `models/generatedNewsModel.js`, `models/userModel.js`, …

(An earlier note here claimed the checkout was incomplete — that was wrong; `Glob` returned false negatives on the space-containing sibling path. Both halves of this epic, §5 mobile and §6 backend, can be built from here.)

The real, separate fact (verified by live probes): production serves these routes but over an **empty data pool** — no active subscriptions ⇒ no generated news ⇒ empty feed in-app. That emptiness is exactly what the aggregator (§6) fixes; it is NOT a source-availability problem.

---

## 2. Architecture: before → after

**Before:** `Subscription` (per user, with topic + style + tone + preferredTimes + frequency) → `schedulerService` cron → LLM+Tavily generates `GeneratedNews` per subscription → `/api/subscriptions/news/all` returns that user's generated articles.

**After:**
- A **shared `NewsArticle` pool** aggregated from real sources (RSS) per topic, deduped, enriched with an `og:image`. One global fetch job, not per-user generation.
- Each **`User`** has `topics: [String]` (≤3). The feed = latest `NewsArticle`s where `topic ∈ user.topics`, minus the user's dismissed set.
- A per-user **`dismissed`** set (array of articleIds, or a `DismissedArticle` collection) drives swipe-to-hide. Articles stay in the pool for future search.
- Manual subscription creation, time settings, and the per-user LLM generation cron are **retired** for this feed. (AI generation can remain available as a separate "Generate" feature — unrelated to this feed.)

---

## 3. Topics

Fixed set (user picks ≤3). Each maps to curated RSS sources. **Movies & Music are split out** (not lumped under Entertainment), per the user:

`Technology · Business · Politics · World · Science · Health · Sports · Movies · Music · Environment · Finance`

(Final list is cheap to change — store as a constant shared by onboarding UI + aggregator.)

---

## 4. API contract (build mobile + backend against this)

| Method | Path | Purpose | Body / Query | Returns |
|---|---|---|---|---|
| `GET` | `/api/topics` | Available topics (optional; can be a client constant) | — | `{ topics: [{ id, label, icon }] }` |
| `GET` | `/api/user/topics` | Current user's chosen topics | — | `{ topics: [String] }` |
| `PUT` | `/api/user/topics` | Save chosen topics (validate ≤3) | `{ topics: [String] }` | `{ success, topics }` |
| `GET` | `/api/news/feed` | Daily feed for the user's topics, dismissed excluded, paginated | `?limit=30&cursor=…` | `{ news: [NewsArticle], nextCursor }` |
| `POST` | `/api/news/:id/dismiss` | Hide an article from this user's feed | — | `{ success }` |
| `GET` | `/api/news/search` *(future)* | Search the pool | `?q=…&topic=…` | `{ news: [...] }` |

**`NewsArticle` shape** (additive on the existing `generatedNewsModel` or a new `newsArticleModel`):
```jsonc
{
  "id": "…", "topic": "Technology", "title": "…", "summary": "…",
  "imageUrl": "https://…/og-image.jpg",   // from og:image, may be null
  "sourceName": "BBC", "sourceUrl": "https://…", "publishedAt": "ISO-8601"
}
```

Onboarding trigger: `user.topics` empty/absent ⇒ mobile shows the topic picker after auth.

---

## 5. Mobile work (`newsmind_mobile`)

- [ ] **M1 — Topics constant** `lib/config/topics.dart`: the §3 list (id, label, icon).
- [ ] **M2 — Onboarding screen** `lib/screens/onboarding_topics_screen.dart`: editorial grid of topic chips/cards, "pick up to 3" rule (disable >3, show counter), Continue → `PUT /api/user/topics` → `/home`. Painted in `AppColors`/`AppType` like the rest.
- [ ] **M3 — Routing/gating**: in `router.dart` (or `splash`/auth redirect), after login if `user.topics` is empty → `/onboarding`. Add `/onboarding` route.
- [ ] **M4 — User model/provider**: add `topics` to `user_model.dart` + `AuthProvider`; expose `hasTopics`.
- [ ] **M5 — Feed rewrite**: point `todays_intelligence_screen` at `GET /api/news/feed` (new `NewsService`/extend `SubscriptionService`). Card now shows the **real image** (`imageUrl`, with placeholder), source name + time eyebrow, headline, summary. Keep the editorial card style already built; swap the credibility meter for source/section since these are real headlines (or keep a "source" chip).
- [ ] **M6 — Swipe-to-dismiss**: wrap each card in `Dismissible` (right-swipe → `POST /api/news/:id/dismiss`, optimistic remove, undo snackbar). 
- [ ] **M7 — Retire manual subscription UX**: remove the "create subscription"/time-settings entry points from `profile_screen` and delete/triage `subscription_screen` + `create_subscription_screen` (or repurpose to a read-only "My Topics" editor that reuses M2). Remove time-setting fields from the model/service.
- [ ] **M8 — Empty/edge states**: no topics yet, feed empty, image load failure, offline.
- [ ] **M9** — `flutter analyze` clean + light/dark verified each step.

## 6. Backend work (`NewsMind AI/backend`) — editable now (see §1)

- [ ] **B1 — `User.topics`** field (≤3, validated) + `GET/PUT /api/user/topics`.
- [ ] **B2 — `NewsArticle` model** (§4 shape) + indexes on `{topic, publishedAt}`.
- [ ] **B3 — Aggregator service** `services/newsAggregatorService.js`: per topic, pull RSS (publisher feeds first, Google News RSS `…/rss/search?q=<topic>` as broad fallback), parse items, dedupe by URL/title.
- [ ] **B4 — Image enrichment**: for each new item, fetch the article URL and extract `<meta property="og:image">` (fallback: RSS `media:content`/`enclosure`, then a per-topic stock image). Cache; never block the feed on a missing image.
- [ ] **B5 — Schedule**: replace per-user generation cron with one global aggregation job (e.g. every 15–30 min) in `schedulerService`.
- [ ] **B6 — `GET /api/news/feed`**: topic-filtered, dismissed-excluded, paginated.
- [ ] **B7 — Dismiss**: `POST /api/news/:id/dismiss` → per-user dismissed set (article stays in pool).
- [ ] **B8 — Retire** per-user subscription generation for this feed (keep `/api/agents/*` generation as its own feature if still used).
- [ ] **B9 — CORS** already fine; if mobile-web dev continues, keep using whitelisted ports (`4010`/`3000`).

> **og:image + Google News caveat:** Google News RSS links are redirect URLs; resolve the redirect to the real article before scraping `og:image`, or prefer direct publisher feeds (cleaner links, often already carry `media:content` images).

## 6b. Admin-editable feed config — ✅ DONE (backend + web admin UI)

`AppSettings.newsFeed` = `{ retentionDays:60, refreshMinutes:30, feeds:[{topic,url,source}] }`, all admin-editable:
- Schema + defaults + self-heal (`appSettingsModel.js`, `appSettingsService.js`); shared default feeds in `config/newsFeeds.js`.
- Admin write path `PATCH /api/admin/settings/app` whitelists+validates `newsFeed` (`adminController.js`); `GET` returns it.
- Aggregator reads configured feeds (fallback defaults); scheduler reads `refreshMinutes` (per-minute gate, live) + prunes per `retentionDays`. Replaced the fixed TTL index with cron-prune so the window is editable.
- **Web admin UI**: "Topic News Feed" panel in `frontend/app/admin/page.jsx` Config tab — retention/refresh number inputs + add/remove/edit RSS sources (topic dropdown + url + source). Save reuses existing `saveAppSettings` (spreads `newsFeed`). All backend files `node --check` clean; JSX structurally verified (no Next build run locally — confirm with `npm run build`).

## 7. Web parity (optional)
The web `/intelligence` page (`NewsMind AI/frontend`) consumes the same feed — mirror M5/M6 there if web should match. Out of scope unless requested.

---

## 8. Checkpoints

- **CP-A — Contract & topics:** ✅ DONE & verified. Backend: `User.topics` field + `config/topics.js` + `GET/PUT /api/user/topics` (node --check clean). Mobile: `lib/config/topics.dart` (11 topics, Movies/Music split) + `UserModel.topics`/`hasTopics` (analyze clean).
- **CP-B — Onboarding flow:** ✅ DONE. `onboarding_topics_screen.dart` (editorial grid, pick ≤3, Continue→`saveTopics`→`markOnboarded`→/home). `AuthProvider.needsOnboarding` resolved via `getTopics()` on init/login/clerk + `markOnboarded()`. Router: `/onboarding` route + first-login gate (logged-in & needsOnboarding → /onboarding; done → /home; splash exempt). flutter analyze clean.
- **CP-C — Aggregation + images (backend):** 🟡 built + validated read-only. `models/newsArticleModel.js` (shared `NewsArticles` pool) + `services/newsAggregatorService.js` (publisher RSS per topic → parse → feed-image-or-og:image → dedupe by sourceUrl → upsert). Read-only test: BBC Tech 21/21 + Guardian Movies 32/32 items WITH images, real URLs/dates. **Pending:** authorization to write to prod DB + wiring `aggregateAll()` into `schedulerService` (auto-run on deploy).
- **CP-D — Feed live:** ✅ **DEPLOYED & WORKING.** Pool verified: 410 real articles, 100% with images, all 11 topics. Mobile: `news_article_model.dart` + `NewsService.getFeed/getTopics/saveTopics` + `todays_intelligence_screen` rewritten — image-led editorial cards (`CachedNetworkImage`), source·time eyebrow, Fraunces headline, Newsreader summary, pull-to-refresh, tap→open source URL (`url_launcher`). flutter analyze clean. (Below was the build note.) `GET /api/news/feed` (topic-filtered, falls back to all topics if no onboarding; time-paginated via `before`) + mounted at `/api/news` + scheduler runs `aggregateAll()` **every 30 min** (`*/30 * * * *`) + primes ~10s after boot. node --check clean. **Pending:** M5 — point mobile `todays_intelligence_screen` at this endpoint (render real article + image). Pull-to-refresh already present (`RefreshIndicator`).
- **CP-E — Dismiss:** ✅ DONE. Backend: `DismissedArticle` model + `POST/DELETE /api/news/:id/dismiss` + feed excludes dismissed. Mobile: `NewsService.dismiss/undismiss` + `Dismissible` right-swipe on cards (optimistic remove + Undo snackbar). ⚠️ NEEDS BACKEND REDEPLOY (added after the last deploy). node --check + analyze clean.
- **CP-F — Cleanup:** ✅ DONE. Retired manual subscription + time settings: profile "Subscription Settings"→"My Topics" (→/onboarding); SubscriptionCard.onManage→upgrade flow (billing kept); removed `/subscription` route; deleted dead `subscription_screen.dart`, `create_subscription_screen.dart`, `news_feed_screen.dart`. analyze clean.

Each CP ends green (`flutter analyze` clean) and dark-verified, per the house rule.

---

## 9. Decisions & remaining questions

- ✅ **Topic list** — §3 set with **Movies & Music split out** from Entertainment.
- ✅ **AI Generate** — STAYS as its own tab/feature (generate an article by style + word limit + topic). Untouched by this epic. Only the *subscription* generation is retired.
- ✅ **Subscriptions** — NOT a tab; manual creation + time settings removed; replaced by topic onboarding.
- ✅ **Backend source** — present & editable at `NewsMind AI/backend` (see §1).
- ❓ **Article tap** — open the real source URL in an in-app webview, or a styled in-app reader built from the summary? (Default assumption: in-app webview to the source URL.)
