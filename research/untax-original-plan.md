# PLAN.md — Untax (working name)

> An iPhone app that catches the money-deadlines ADHD brains lose track of (free trials, returns) **and makes sure you actually act on them** before they cost you.

Last updated: 2026-09-25 · Status: research done + **every load-bearing claim audited** (see §11) · friend's battle plan merged · scope NOT frozen

**Legend:** ✅ verified against the primary source (quoted in §11) · ⚠️ unverified or secondary-only · ❌ checked and wrong/removed

---

## 0. The judge, the rules, and the one core flow

**Category:** RevenueCat Shipaton 2026 — **Next Gen Award** (students). From the [official rules](https://revenuecat-shipaton-2026.devpost.com/rules):
- ✅ *"Instead of a published app-store listing, submit a demo video and a link to your public, open-source code repository, including an open-source license file."*
- ✅ *"No paid Apple or Google developer account or store release is required."*
- ✅ Still required: *"a working software application that uses the RevenueCat SDK to power at least one in-app or web purchase, or that serves ads through RevenueCat Ads."*
- ✅ Student/academic email on Devpost; ages 13+ (guardian consent if under the age of majority).
- ✅ Deadline: **Wednesday, September 30, 2026 at 11:45pm PDT.** Video should be under 2 minutes.

**Official Next Gen judging criteria (✅, no weights published):**
1. Is the idea clear, useful, interesting, or original — does it solve a real problem?
2. Does the project show meaningful progress toward a working app?
3. Does it thoughtfully use RevenueCat for a monetization flow?
4. Does it show thoughtful technical choices, product thinking, and care in how it was built **and presented**?

**How judging works (✅ [Shipaton blog](https://www.shipaton.com/blog/how-we-judge-shipaton)):** judges must read the entire description, watch at least 2 minutes of video, and review all screenshots; downloading the app is optional. Category assignments are confidential. **→ The video, description, screenshots, and README are the product as judges experience it.** State what the app does in the first seconds.

**The one core flow (everything else is optional):**
```
Trial email arrives → Untax finds it → "Hulu trial ends Oct 3, then $17.99. Track it?" ✅
→ widget countdown → louder reminders → final-day alarm that keeps coming back until you decide
→ one tap to the exact cancel page → "+$17.99 ADHD Tax Refunded" 🎉
```

---

## 1. Positioning & voice *(merged from friend's plan)*

- **Tagline options:** *"Stop paying for forgetting."* · *"Every app shows you the deadline. Untax makes sure you actually beat it."* · *"Every app reminds you. Untax makes sure you actually cancel."*
- **Hero metric name:** **"ADHD Tax Refunded"** (instead of "money saved") — uses the community's own phrase ([ADDitude on the "ADHD tax"](https://www.additudemag.com/adhd-tax-late-fees-fines-shame/)).
- **Pricing story:** *"We'd never charge you a subscription to stop subscriptions."* → lifetime purchase as the headline; *and we remind you before OUR trial ends too.*
- **Community language for copy and video** (use naturally, don't lecture):

  | Phrase | Meaning | Where it fits | Status |
  |---|---|---|---|
  | "Wall of Awful" | Shame from past misses blocks starting a task | Why a 2-minute cancel feels impossible | ⚠️ attributed to Brendan Mahan — confirm before crediting on screen |
  | Notification "glaze"/blindness | Swiping an alert away without processing it | Video opener: the swipe-away | ⚠️ community/blog term |
  | "Trunk of Shame" | Returns sitting in the car until the window closes | Returns feature, visual hook | ⚠️ community slang |
  | "Out of sight, out of mind" | If it isn't in your face, it doesn't exist | Why widgets + alarm | ✅ Deadlinr uses the same framing |

---

## 2. Research & Verdict

**IDEA:** Automatic capture + reminders that escalate until you act, for money deadlines, designed for ADHD.
**PROBLEM:** The "ADHD tax": money lost to forgotten trials, returns, late fees.
**TARGET USER:** Adults (especially students/young adults) with ADHD or ADHD-like forgetfulness, US first.
**CATEGORY:** Personal finance × productivity × neurodiversity.

### A. Existing solutions
| Type | Players | What they do | Where they stop |
|---|---|---|---|
| Manual trial trackers | ✅ Free Trial Killer, Trial Alert, TrialHero (all on the US App Store) · ⚠️ Trackery, Bobby, TrackAllSubs (not re-checked) | You type it in, you get a notification | You must remember to add it; one ignorable alert |
| Email auto-capture | ✅ [SubDupes](https://subdupes.com/blog/best-subscription-tracker-app): *"add one rule in Gmail or Outlook that forwards them automatically"*, reads only billing platforms · ✅ [Track-Subs](https://www.track-subs.com/): Gmail/Outlook/IMAP, "60+ known providers", $6.99/mo | Detect subscriptions from receipts | Neither page mentions detecting **free trials**; notification-only |
| Bank-based | ✅ [Rocket Money](https://www.rocketmoney.com/learn/personal-finance/how-much-does-rocket-money-cost): Premium "$7 to $14 per month", Premium+ $15, *"we can cancel many unwanted subscriptions for you"* | Finds recurring charges, cancels for you | After the first charge; needs bank login |
| Prevention | ✅ [Privacy.com](https://www.privacy.com/pricing) free plan: 12 cards/month, single-use & merchant-locked cards | Card that can't be charged again | Needs setup at every signup |
| ADHD-positioned | ✅ [Deadlinr](https://www.getdeadline.app/expiry-tracker-for-adhd): ADHD "Out of Head" system; tracks trial cancellations, refills, renewals; **manual entry + barcode only**; pay-once lifetime, 14-day trial | ADHD-branded deadline tracker | **No automatic capture, no follow-through** → closest competitor; study it |
| Returns | ✅ KeepOrReturn (US App Store) + ⚠️ Receipted, RefundHaul, etc. | Return-window reminders | Single-purpose |

**Blunt read:** capture exists (SubDupes, Track-Subs), and an ADHD-branded app exists (Deadlinr), **but no one combines automatic capture with follow-through.** Deadlinr is manual-only; the auto-capture tools are generic and stop at a notification.

### B. Demand
- ✅ **15.5M US adults** have a current ADHD diagnosis (6.0%); **55.9%** were diagnosed as adults. [CDC MMWR, Oct 10, 2024](https://www.cdc.gov/mmwr/volumes/73/wr/mm7340a1.htm)
- ✅ **79%** of Americans *"have started a free trial intending to cancel, then forgotten and been charged"*; forgotten trials cost **$45/month on average (≈ $540/yr)**; average worst single charge **$87**. [Dimers survey](https://www.dimers.com/press/news/how-far-americans-will-go-for-freebies), 2,000 US adults, Sep 1, 2026. ⚠️ General population, self-reported, run by a betting/sweepstakes site.
- ✅ People estimate **$86/mo** on subscriptions but actually spend **$219**. [C+R Research](https://www.crresearch.com/blog/subscription-service-statistics-and-costs/), 1,000 consumers, Apr–May 2022.
- ✅ The community has its own name for it: the **"ADHD tax"** ([ADDitude](https://www.additudemag.com/adhd-tax-late-fees-fines-shame/)).
- ❌ **Do not use:** "$15–20k/yr ADHD tax", "$1,900/yr" (friend's plan), "48% charged": none traced to a primary source.
- ⚠️ Why plain reminders fail ("notification blindness"): practitioner blogs only ([Focusmo](https://focusmo.app/blog/apple-reminders-for-adhd)), not peer-reviewed.
- ✅ Why now: the FTC opened a new [rulemaking on negative-option (subscription) practices](https://www.ftc.gov/news-events/news/press-releases/2026/03/ftc-seeks-public-comment-response-advance-notice-proposed-rulemaking-regarding-negative-option) ([Federal Register, Mar 13, 2026](https://www.govinfo.gov/content/pkg/FR-2026-03-13/pdf/2026-04952.pdf)). ⚠️ That the 2024 rule was vacated by the Eighth Circuit in July 2025 comes from [law-firm alerts](https://www.consumerfinancemonitor.com/2025/07/23/eighth-circuit-voids-ftc-click-to-cancel-rule/), not an FTC page.
- ⚠️ Reddit couldn't be read directly (it blocks fetching); community evidence came through ADDitude, blogs, and forum complaints.

### C. The gap
Competitors treat this as a **memory** problem. For ADHD it's a **follow-through** problem: people see the reminder and still don't act. The gap is: **capture automatically → escalate until it's done → make doing it trivially easy → reward it.**

### D. Feasibility
- **Difficulty: Medium.** Integration + UX, nothing research-grade.
- **Riskiest unknowns → Milestone 0 spikes:**
  1. **Email-forward onboarding.** ✅ Google documents forwarding setup only *"On your computer, open Gmail"*; a **verification link** is sent to the forwarding address; to forward only some messages *"set up a filter"* ([Gmail Help](https://support.google.com/mail/answer/10957)). ⚠️ Whether it works from a phone's browser is untested → spike.
  2. **Extraction accuracy** on messy real emails (trial end dates are often implied).
  3. **Free Apple ID limits** for the demo (see below).
- **Verified tech facts:**
  - ✅ Gmail API read access is out for v1: `gmail.readonly` and `gmail.metadata` are **Restricted** ([Google](https://developers.google.com/workspace/gmail/api/auth/scopes)); apps that reach restricted data through a server must *"complete a security assessment at least every 12 months"* ([Google](https://developers.google.com/identity/protocols/oauth2/production-readiness/restricted-scope-verification)). ⚠️ Cost (~$540–$1,000+, 4–8 weeks) is third-party only; Google's page lists no fee.
  - ✅ Cloudflare Email Routing: inbound email **"Unlimited"** on the Workers Free plan ([pricing](https://developers.cloudflare.com/email-service/platform/pricing/)), 25 MiB max message, 200 routing rules ([limits](https://developers.cloudflare.com/email-service/platform/limits/)).
  - ✅ **New risk:** Workers Free = **100,000 requests/day and 10 ms CPU per invocation** ([limits](https://developers.cloudflare.com/workers/platform/limits/)); *"complex handlers may exceed these limits and fail to process a message."* Large emails may need the paid Workers plan (⚠️ price not re-verified). Waiting on the AI API doesn't use CPU time, but parsing MIME does.
  - ✅ **AlarmKit** (iOS 26+): per Apple's WWDC25 session, *"the alert breaks through the silent mode and the current focus."* The alert has an **end (stop) button + one customizable secondary button** only. `AlarmConfiguration` accepts a **`stopIntent`** and a **`secondaryIntent`** ([Apple docs](https://developer.apple.com/documentation/alarmkit)). → **"Stop only postpones" is buildable:** the stop intent re-arms the alarm until a decision is recorded.
  - ✅ Live Activities: active up to **8 hours**, then up to **4 more** on the Lock Screen ([Apple](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)) → widgets for multi-day countdowns; Live Activity on the final day only.
  - ✅ Foundation Models (iOS 26+): on-device, does *"entity extraction, text and image understanding,"* guided generation via `@Generable`; *"people need a device that supports Apple Intelligence"* ([Apple](https://developer.apple.com/documentation/foundationmodels)) → server fallback needed.
  - ✅ **Free Apple ID vs $99 Program** ([Apple capabilities table](https://developer.apple.com/help/account/reference/supported-capabilities-ios)):

    | Capability | Free Apple ID | $99 Program | Why we care |
    |---|---|---|---|
    | App Groups | ✅ yes | ✅ | Widgets + share extension share data → **work on free** |
    | Push Notifications | ❌ | ✅ | "Found: Hulu trial" push, the video's magic moment |
    | Sign in with Apple | ❌ | ✅ | Account login |
    | In-App Purchase | ❌ | ✅ | Real sandbox purchases |
    | Time Sensitive Notifications | ❌ | ✅ | Louder escalation steps |

    ⚠️ "Free-account builds stop launching after 7 days" is third-party only. ⚠️ Whether AlarmKit works on a free Apple ID wasn't found either way → spike.
  - ✅ **RevenueCat Test Store:** *"built-in testing environment that works immediately without platform setup"*; test purchases update CustomerInfo and entitlements; needs purchases-ios **≥ 5.43.0**; *"Never submit an app… configured with a Test Store API key"* (release builds crash on purpose) ([RevenueCat docs](https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store)). ⚠️ Not stated whether it works without the In-App Purchase capability → spike.
- **AI cost per forwarded email** (✅ prices from [Anthropic's pricing page](https://platform.claude.com/docs/en/about-claude/pricing); ⚠️ token counts are my assumptions: ~3k words of email text in, ~400 words of JSON out; ✅ models from 4.7 on use a tokenizer producing *"approximately 30% more tokens"*):

  | Model | Price in / out per 1M tokens | ≈ per email | ≈ per user/month (20 emails) |
  |---|---|---|---|
  | `claude-opus-5` (Claude API skill default) | ✅ $5 / $25 | ~$0.03–0.05 | ~$0.60–1.00 |
  | `claude-opus-5-5` | ✅ $4 / $20 | ~$0.025–0.04 | ~$0.50–0.80 |
  | `claude-haiku-4-5` | ✅ $1 / $5 | ~$0.005 | ~$0.10 |

  A rules-based pre-filter (only billing-looking emails reach the model) cuts all of these. The model choice is yours (§10).
- **Legal/privacy:** store only extracted fields and drop the raw email after parsing; privacy policy; in-app data deletion; "not financial advice."

### E. Business & verdict
- **Price benchmarks (✅):** Rocket Money $7–14/mo · Track-Subs $6.99/mo or $59.99/yr · Deadlinr pay-once lifetime · Privacy.com free.
- **Proposed model:** Free = manual + share capture, 5 active items, basic reminders. **Pro** = email auto-capture, escalation + final-day alarm, unlimited items, ADHD Tax Refunded stats. **Headline: $29.99 lifetime**, plus $3.99/mo and $24.99/yr. We remind you before our own trial ends.
- **Top 3 risks:** (1) Deadlinr or SubDupes add follow-through; (2) onboarding friction kills auto-capture; (3) "yet another reminder app" fatigue unless ADHD Tax Refunded is visible and real.

> ## VERDICT: **GO, with follow-through as the product** (confidence: medium)
> Automatic capture + escalation that won't let you forget + one-tap cancel + a visible "ADHD Tax Refunded" score. Strong for Next Gen: a CDC-backed problem, a 79%-relatable pain, an emotional 2-minute story, and open-source code with real substance (email pipeline, AI extraction, AlarmKit).

---

## 3. MVP scope (draft — freeze after your ideas)

**In v1:**
1. **Capture:** personal forwarding address + guided Gmail filter setup · share sheet (screenshot/link/text) · manual quick-add fallback
2. **AI extraction** → "Found: X. Track it?" confirm inbox (one tap)
3. **Item types:** free trials and return windows
4. **Escalation ladder:** widget countdown → 7d/3d/1d notifications → opt-in **final-day AlarmKit alarm where Stop only postpones** (re-arms in 30 min) until you choose **Cancel / Keep / Snooze-until** ← *the hero feature*
5. **Follow-through:** one-tap **curated cancel links for the top 10 services** + Apple's subscription page → "Mark done" → **ADHD Tax Refunded** counter + celebration haptics
6. **RevenueCat paywall:** lifetime-first pricing + a reminder before our own trial ends
7. Privacy policy, data export + delete

**Deferred:** bank connection · gift cards · bills · Outlook/iCloud guides · Android · social/accountability · Safari extension · Watch · cancel links beyond the top 10 · everything in `IDEAS.md` not tagged MVP.

---

## 4. Tech stack (pinned, checked live 2026-09-24/25)

| Piece | Choice | Version | Status | Why |
|---|---|---|---|---|
| iOS app | Swift + SwiftUI | Xcode 27 / iOS 27 SDK / Swift 6.4; Xcode needs macOS Tahoe 26.6+ | ✅ [release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes) | AlarmKit, widgets, share extension, on-device AI are native-only |
| Min iOS | iOS 26 | — | ✅ | AlarmKit + Foundation Models are iOS 26.0+ |
| Local data | SwiftData (in an App Group) | SDK | ✅ App Groups work on free Apple ID | Shared by app, widget, share extension |
| On-device AI | Foundation Models + Vision OCR | SDK | ✅ | Free, private; server fallback |
| Payments | RevenueCat `purchases-ios` | **5.91.0** (2026-09-23) | ✅ GitHub | Required; Test Store needs ≥ 5.43.0 |
| Backend | Cloudflare Workers + Email Routing + D1 | `wrangler` **4.139.0** | ✅ npm | Free inbound email |
| MIME parsing | `postal-mime` | **3.0.0** | ✅ npm | Parse forwarded email in the Worker |
| AI extraction | `@anthropic-ai/sdk`, structured outputs | **0.128.0** | ✅ npm | Schema-valid JSON |
| Validation | `zod` | **4.6.5** | ✅ npm | Check model output before saving |
| Push | APNs from the Worker | — | ✅ needs $99 Program | "Found" notification |
| 💰 | Apple Developer $99/yr (**recommended, not required**: push, Sign in with Apple, real IAP, Time Sensitive) · domain ~$10–15/yr (⚠️) · Anthropic API usage · possibly the paid Workers plan | | | |

**Without the $99 account (free Apple ID) the demo still works if:** purchases go through RevenueCat Test Store (⚠️ spike), the app checks the server on open instead of receiving a push, and sign-in uses an anonymous device key.

---

## 5. Architecture sketch

```
 Gmail ──(filter: trial|receipt|order|subscription)──► you+abc123@untax.app
                                                            │
                                               Cloudflare Email Routing (free, unlimited inbound)
                                                            ▼
                                  Email Worker: postal-mime → rules pre-filter
                                     → Claude (structured JSON) → zod check
                                     → D1 (extracted fields only; raw email dropped)
                                                            │ APNs push ($99) or app pulls on open (free)
                                                            ▼
 ┌──────────────────────────── iPhone (SwiftUI) ────────────────────────────┐
 │ Found inbox ("Track it?") → Items (SwiftData in App Group)                │
 │ Escalation: widget → notifications → AlarmKit final-day alarm             │
 │   (stopIntent re-arms until Cancel / Keep / Snooze-until is chosen)       │
 │ Share extension → Vision OCR + Foundation Models (fallback: Worker API)   │
 │ Cancel flow (curated links) → ADHD Tax Refunded 🎉 · RevenueCat paywall   │
 └───────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Project structure

```
untax/
├── ios/Untax.xcodeproj
│   ├── Untax/            App, Onboarding, Inbox, Items, Escalation, CancelFlow, Paywall, Settings
│   ├── UntaxShared/      Models, date logic, cancel-link catalog (app + extensions)
│   ├── UntaxWidgets/     Countdown widgets, final-day Live Activity
│   ├── UntaxShare/       Share extension
│   └── UntaxTests/       Date math, extraction parsing, escalation schedule
├── worker/
│   ├── src/index.ts  src/extract.ts  src/apns.ts  schema.sql  wrangler.toml
│   └── test/fixtures/    anonymized .eml + expected JSON (npm test)
├── docs/                 architecture.md, privacy-policy.md, demo-script.md
├── README.md  PLAN.md  PROJECT.md  IDEAS.md  LICENSE (MIT)
```

---

## 7. Milestones (full build)

- [ ] **M0a: Spike: extraction accuracy.** 25 real anonymized emails. *Done when:* ≥ 22/25 correct (merchant, type, end date, price); fixtures committed; `npm test` reproduces the score.
- [ ] **M0b: Spike: onboarding + platform limits.** Gmail forwarding from a phone only; AlarmKit + RevenueCat Test Store on the account type you choose. *Done when:* a test email reaches D1 in < 60s, setup is timed (target < 90s), and the alarm and a Test Store purchase both work on-device.
- [ ] **M1: iOS skeleton.** SwiftData in an App Group, manual add, item list. *Done when:* data persists and is visible to a widget; date-math tests pass.
- [ ] **M2: Escalation ladder.** Widget countdown, 7/3/1d notifications, final-day alarm where Stop re-arms. Debug "time travel" mode. *Done when:* every stage fires in time-travel mode; screen recording in `docs/`.
- [ ] **M3: Share-sheet capture.** *Done when:* 10 fixture screenshots → correct items in ≤ 2 taps; fallback path tested.
- [ ] **M4: Email pipeline.** *Done when:* forwarding a fixture email produces a confirmable item on a real phone (push or pull); replay script passes.
- [ ] **M5: Follow-through.** Curated top-10 cancel links, Mark done, ADHD Tax Refunded + celebration, **your forcing ideas**. *Done when:* one Apple subscription and one web trial cancelled end to end; the counter updates.
- [ ] **M6: RevenueCat paywall.** Lifetime-first, our-own-trial reminder. *Done when:* a purchase (Test Store or sandbox) unlocks Pro and restore works.
- [ ] **M7: Harden & polish.** Accessibility, dark mode, privacy policy, deletion, 1179×2556 screenshots, 1024×1024 icon. *Done when:* a fresh clone builds from the README alone; the demo flow runs 3× without crashing.
- [ ] **M8: Submit.** Repo + MIT license + README (§9) + video (§8) + Devpost text. *Done when:* submission confirmed; someone new understands the app from the video's first 15 seconds.

### If targeting Sep 30 (≈ 5 days): video-first sprint *(adapted from friend's plan)*
| Day | Build | Why |
|---|---|---|
| 1 | Skeleton + manual add + widget countdown + escalation notifications | What the video shows must be real |
| 2 | Final-day alarm with Stop re-arming + Cancel/Keep/Snooze screen | **The hero moment** |
| 3 | Share-sheet capture (screenshot → AI → one tap) | The "magic" moment |
| 4 | RevenueCat paywall (Test Store or sandbox) + curated cancel links + ADHD Tax Refunded | Judging criterion 3 |
| 4–5 | Email pipeline (demo-able version) | Technical depth, if time allows |
| 5 | Video + README + screenshots + Devpost text | This *is* the submission |

---

## 8. Video plan (< 2 min) *(friend's script, with stats and alarm behavior corrected)*

```
0:00–0:05  HOOK     Text on black: "Regular people set a reminder and do it."
0:05–0:12  PROBLEM  Notification "Hulu trial ends tomorrow" → thumb swipes it away → gone.
                    VO: "I set a reminder, swipe it away, and it ceases to exist. Then: $17.99."
0:12–0:20  STAKES   Charges stack up on screen. VO: "79% of Americans have started a free trial
                    meaning to cancel, and got charged anyway. For ADHD brains it has a name:
                    the ADHD tax."                                  ✅ Dimers 2026
0:20–0:25  THESIS   Logo. "Every app reminds you. Untax makes sure you actually do it."
0:25–0:45  CAPTURE  Forward email → "Found: Hulu trial. Ends Oct 3. $17.99/mo after. Track it?" ✅
                    Share a screenshot → "Nike return: 30 days" → one tap.
0:45–1:05  FOLLOW-THROUGH  Widget "Hulu · $17.99 in 3 days" → notification → full-screen alarm.
                    Tap Stop → "It comes back in 30 minutes. It only stops when you decide."
                    → Cancel / Keep / Snooze-until → Cancel → Apple subscriptions page → done.
1:05–1:15  REWARD   "+$17.99" → "$214.47 ADHD Tax Refunded" → confetti + haptics.
                    VO: "Not a guilt trip. A scoreboard."
1:15–1:30  PAYWALL  "$29.99 lifetime" highlighted. VO: "We'd never charge a subscription to stop
                    subscriptions. And yes, we remind you before our own trial ends." [beat]
1:30–1:45  CRAFT    Architecture diagram (3s) → RevenueCat entitlement code (3s) → repo README.
                    VO: "SwiftUI, SwiftData, AlarmKit, on-device Foundation Models, Cloudflare
                    Workers. Fully open source."
1:45–2:00  CLOSE    Yearly recap card → icon + tagline + GitHub QR.
                    VO: "Forgetting isn't a character flaw. Untax fights back."
```
Rules for the video: only ✅ numbers on screen; show the real app (no mockups presented as working); say what it does in the first 25 seconds.

---

## 9. Repo quality bar *(friend's checklist; maps to criteria 2–4)*

**README must have:** icon + 3 screenshots at the top · one-sentence pitch + short description · architecture diagram (Mermaid) · stack badges · **"How RevenueCat is used"** section (criterion 3) · build steps (clone → open → run) · privacy & data handling · MIT license file (required by the rules).

**Code signals:** Swift 6.4 strict concurrency (`@MainActor`, `Sendable`, async/await) · clear feature/layer separation · SwiftData models in a shared module · unit tests for date math, escalation schedule, extraction parsing · **no secrets committed** (xcconfig + Worker secrets) · **no Test Store key in release builds** · Worker fixtures with `npm test`.

---

## 10. Open decisions (yours)

1. **Sep 30 deadline or not?** It decides between the 5-day sprint and the full build.
2. **Apple account:** free Apple ID (Test Store, no push) vs $99 (push, real sandbox IAP, Sign in with Apple).
3. **AI model:** `claude-opus-5` (default) · `claude-opus-5-5` (cheaper Opus) · `claude-haiku-4-5` (cheapest). Decide after the M0a accuracy test.
4. **Name:** "Untax" is a placeholder.
5. **Pricing:** confirm $29.99 lifetime as the headline.
6. **Your forcing ideas** → M5.

---

## 11. Claim audit (2026-09-25)

| # | Claim | Status | Primary source → evidence |
|---|---|---|---|
| 1 | Next Gen: video + public repo w/ license instead of store listing | ✅ | [Rules](https://revenuecat-shipaton-2026.devpost.com/rules), quoted in §0 |
| 2 | No paid dev account or store release required | ✅ | Rules |
| 3 | RevenueCat must power ≥1 in-app/web purchase (applies to Next Gen) | ✅ | Rules |
| 4 | Deadline Wed Sep 30, 2026, 11:45pm PDT | ✅ | Rules |
| 5 | Four Next Gen criteria, no weights | ✅ | Rules |
| 6 | Judges must watch 2 min + read description + screenshots; testing optional | ✅ | [Shipaton blog](https://www.shipaton.com/blog/how-we-judge-shipaton) |
| 7 | Judges include Chapman, Barnard, van der Lee, Lackner, Burd, Lyttle, Cameron (30 total) | ✅ | [shipaton.com](https://www.shipaton.com/) (friend was right on all 7) |
| 8 | 2025 winners: Payout 17k+ users / $30,017 / 1,750 subs; Gurwi; Dayloop; Heartbeat Hero | ✅ | [RevenueCat blog](https://www.revenuecat.com/blog/company/shipaton-2025-winners) |
| 9 | 15.5M US adults (6.0%), 55.9% diagnosed as adults | ✅ | [CDC MMWR](https://www.cdc.gov/mmwr/volumes/73/wr/mm7340a1.htm) |
| 10 | 79% forgot a trial and were charged; $45/mo; $87 worst charge | ✅ | [Dimers](https://www.dimers.com/press/news/how-far-americans-will-go-for-freebies) |
| 11 | $86 estimated vs $219 actual subscription spend | ✅ | [C+R Research](https://www.crresearch.com/blog/subscription-service-statistics-and-costs/) |
| 12 | "48% charged after forgetting a trial" | ❌ removed | Source article gives no attribution |
| 13 | "$15–20k/yr" and "$1,900/yr" ADHD tax | ❌ don't use | No primary source |
| 14 | Notification blindness in ADHD | ⚠️ | Practitioner blogs only |
| 15 | FTC negative-option ANPRM, Mar 2026 | ✅ | [FTC](https://www.ftc.gov/news-events/news/press-releases/2026/03/ftc-seeks-public-comment-response-advance-notice-proposed-rulemaking-regarding-negative-option), [Federal Register](https://www.govinfo.gov/content/pkg/FR-2026-03-13/pdf/2026-04952.pdf) |
| 16 | 2024 rule vacated by Eighth Circuit, July 2025 | ⚠️ | Law-firm alerts only |
| 17 | Free Trial Killer, Trial Alert, TrialHero, KeepOrReturn, Deadlinr exist | ✅ | Apple App Store lookup API |
| 18 | SubDupes forwarding-rule capture, billing senders only | ✅ | [SubDupes](https://subdupes.com/blog/best-subscription-tracker-app) |
| 19 | Track-Subs Gmail/Outlook/IMAP, 60+ providers, $6.99/mo | ✅ | [Track-Subs](https://www.track-subs.com/) |
| 20 | Rocket Money $7–14/mo, $15 Premium+, cancels for you | ✅ | [Rocket Money](https://www.rocketmoney.com/learn/personal-finance/how-much-does-rocket-money-cost) |
| 21 | Privacy.com free: 12 cards/mo, single-use/merchant-locked | ✅ | [Privacy.com](https://www.privacy.com/pricing) |
| 22 | Deadlinr: ADHD, manual + barcode only, pay-once | ✅ | [Deadlinr](https://www.getdeadline.app/expiry-tracker-for-adhd) |
| 23 | "Duefolio" competitor (friend's plan) | ⚠️ | Not found anywhere; ask for a link |
| 24 | gmail.readonly / gmail.metadata are Restricted | ✅ | [Google scopes](https://developers.google.com/workspace/gmail/api/auth/scopes) |
| 25 | Restricted + server access → assessment every 12 months | ✅ | [Google](https://developers.google.com/identity/protocols/oauth2/production-readiness/restricted-scope-verification) |
| 26 | Assessment costs ~$540–$1,000+, 4–8 weeks | ⚠️ | Third-party blogs only |
| 27 | Gmail forwarding documented on computer only; verification link; filters | ✅ | [Gmail Help](https://support.google.com/mail/answer/10957) |
| 28 | Cloudflare inbound email unlimited on free; 25 MiB; 200 rules | ✅ | [CF pricing](https://developers.cloudflare.com/email-service/platform/pricing/), [limits](https://developers.cloudflare.com/email-service/platform/limits/) |
| 29 | Workers Free 100k req/day, 10 ms CPU | ✅ | [CF Workers limits](https://developers.cloudflare.com/workers/platform/limits/) |
| 30 | AlarmKit iOS 26+, breaks through silent mode + Focus | ✅ | [Apple docs](https://developer.apple.com/documentation/alarmkit), [WWDC25 session](https://developer.apple.com/videos/play/wwdc2025/230/) |
| 31 | Alarm alert = stop + one secondary button; stopIntent/secondaryIntent | ✅ | Apple docs (`AlarmPresentation.Alert`, `AlarmConfiguration`) |
| 32 | Live Activity 8h + up to 4h on Lock Screen | ✅ | [Apple](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities) |
| 33 | Foundation Models iOS 26+, on-device, image understanding, needs Apple Intelligence device | ✅ | [Apple](https://developer.apple.com/documentation/foundationmodels) |
| 34 | Xcode 27 = Swift 6.4 + iOS 27 SDK, macOS Tahoe 26.6+ | ✅ | [Apple release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes) |
| 35 | Xcode 27 released Sep 14, 2026 | ⚠️ | Third-party blog only (not load-bearing) |
| 36 | Free Apple ID: App Groups yes; Push, Sign in with Apple, IAP, Time Sensitive no | ✅ | [Apple capabilities table](https://developer.apple.com/help/account/reference/supported-capabilities-ios), read from page HTML |
| 37 | Free-account builds expire after 7 days | ⚠️ | Third-party only |
| 38 | RevenueCat Test Store: no platform setup, ≥ 5.43.0, never ship the key | ✅ | [RevenueCat docs](https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store) |
| 39 | Test Store works without the IAP capability | ⚠️ | Not stated → spike M0b |
| 40 | purchases-ios 5.91.0 (2026-09-23) | ✅ | GitHub releases API |
| 41 | wrangler 4.139.0, postal-mime 3.0.0, @anthropic-ai/sdk 0.128.0, zod 4.6.5 | ✅ | npm registry |
| 42 | Claude prices: Opus 5 $5/$25, Opus 5.5 $4/$20, Haiku 4.5 $1/$5; ~30% more tokens on 4.7+ | ✅ | [Anthropic pricing](https://platform.claude.com/docs/en/about-claude/pricing) |
| 43 | Per-email token counts | ⚠️ | My assumptions; M0a measures the real numbers |
| 44 | Mint/Truebill "graveyard" | ❌ removed | Not verified, not load-bearing |
