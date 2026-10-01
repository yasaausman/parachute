# PLAN.md: Untax (formerly Parachute)

> **The ADHD follow-through engine.** Untax catches the money deadlines your brain loses, nudges until you act, and when you freeze, on a cancellation or an essay, walks you through one tiny step at a time. **Pull the cord.**

Updated 2026-09-25 · Status: planning complete, ready to build · Team: Dev A (Money) + Dev B (Unfreeze), see `MILESTONES.md`
**Legend:** ✅ verified at the primary source (§15) · ⚠️ unverified/secondary · ❌ checked and false · 🟡 open decision (§13)
Research archive: `research/` (original Untax plan + full 44-row audit, Parachute & Friction research, friend's notes)

---

## 0. The judge and the rules

**RevenueCat Shipaton 2026, Next Gen Award** ([rules](https://revenuecat-shipaton-2026.devpost.com/rules)):
- ✅ Submit **a demo video + a public open-source repo with a license file**. *"No paid Apple or Google developer account or store release is required."*
- ✅ *"Next Gen Award Projects will be evaluated using the demonstration video and code repository."* No judge promo code needed.
- ✅ Must use the RevenueCat SDK *"to power at least one in-app or web purchase."*
- ✅ Eligibility: *"an active student… use a qualifying student or academic email address on Devpost."* Minors need guardian consent.
- ✅ Teams allowed: *"Teams of Eligible Individuals"*; one **Representative** submits and allocates any prize. The rules don't say it outright, but the Shipaton Discord confirmed (via Dev A, 2026-09-28): **every team member must be a student**.
- ✅ Deadline **Wed Sep 30, 2026, 11:45pm PDT**. Video under 2 minutes.
- ✅ Criteria (no weights): (1) clear, useful, original idea · (2) meaningful progress toward a working app · (3) thoughtful RevenueCat use · (4) thoughtful technical choices, product thinking, care in build **and presentation**.
- ✅ Judges must read the description, watch 2 minutes of video, and review screenshots; testing is optional ([Shipaton blog](https://www.shipaton.com/blog/how-we-judge-shipaton)). **The video, README, and screenshots are the product.**

---

## 1. The product: two paths, one engine

**Insight:** competitors treat ADHD as a *money* problem (trackers) or a *productivity* problem (task apps). For ADHD brains it's one problem: *you see it, you know you should do it, you can't start, and the shame grows.*

```
        💸 MONEY PATH (Dev A, the hero)             📝 TASK PATH (Dev B)
  Share trial screenshot → "Track it?"        "I'm frozen" → "What's overwhelming you?"
                 │                                       │
                 ▼                                       ▼
 ┌──────────────────── SHARED FOLLOW-THROUGH ENGINE ─────────────────────┐
 │ Escalate: widget → reminders → final-day alarm (Stop only postpones)    │
 │ Decide:   Cancel/Do it · Keep · Snooze-until · 🧊 I'm frozen             │
 │ Unfreeze: one tiny step at a time · 90s ring · companion                │
 │ Reward:   🎉 → "ADHD Tax Refunded" scoreboard                            │
 └─────────────────────────────────────────────────────────────────────────┘
```

| Mechanic | 💸 Money path | 📝 Task path |
|---|---|---|
| Capture | Share-sheet screenshot → on-device AI → "Track it?" · manual add | "I'm frozen" → describe it ("8-page essay due at midnight") |
| Escalation | Widget → reminders (−3d, −1d) → final-day alarm | Due-time reminders → "still stuck?" nudge → alarm at the deadline |
| Decide | Cancel · Keep · Snooze-until · 🧊 I'm frozen | Do it now · Break it smaller · Snooze-until |
| Steps | **Curated** cancel steps → Apple subscriptions path → AI fallback | **AI** micro-steps (Foundation Models) |
| Reward | "+$17.99 ADHD Tax Refunded" | "+1 task unfrozen" |
| Widget | "Hulu · $17.99 in 3 days" | "Essay · Step 3 of 7" |

**Positioning:** lead with **getting unstuck** (unique), not "track your trials" (crowded; see §2).
**Taglines:** *"Pull the cord."* · *"Stop paying for forgetting. Stop freezing when it matters."* · *"Every app reminds you. Untax gets you through it."* · *"Get your ADHD tax back."* (headline since the 2026-09-29 rebrand)

---

## 2. Research & Verdict (condensed; full detail in `research/`)

**PROBLEM:** The "ADHD tax": money and deadlines lost not to forgetting but to **not starting**.
**TARGET USER:** Students and young adults with ADHD or ADHD-like follow-through struggles, US first.

### Competitors (✅ all verified)
| Space | Players | What they miss |
|---|---|---|
| 🚨 **Same money pitch** | **Clawback: Beat the ADHD Tax** (released **2026-09-24**; trials/returns/late fees, photo capture, "nudge harder", "how much you've recovered", on-device) | From its listing: no alarm, no step-by-step unfreeze, no task path. Possibly another Shipaton entrant |
| 🚨 **Same alarm mechanic** | **Nudgy** (Aug 2026): *"Stop only silences it for now"* | Generic reminders; no money, no unfreeze |
| Subscription capture | SubDupes, Track-Subs ($6.99/mo), Rocket Money ($7–14/mo) | Remembering only |
| ADHD deadlines | Deadlinr (manual + barcode, pay-once), Handled: Bills & Deadlines | No auto-capture / no unfreeze |
| Micro-steps | Tiimo (**iPhone App of the Year 2025**, ~20k ratings), Goblin Tools (~3k), EmberTend, UnfreezeMe, Inchworm, Doable, FOCO ($9/mo) | Generic tasks, AI-only steps, not tied to money deadlines |
| Lock until done | Due or Die | Generic to-dos |

⚠️ No app found combining money-deadline capture + escalation + **curated** unfreeze steps + a task path + a refunded scoreboard (searches can't prove absence).

### Demand
- ✅ **15.5M** US adults with ADHD; **55.9%** diagnosed as adults ([CDC MMWR](https://www.cdc.gov/mmwr/volumes/73/wr/mm7340a1.htm)).
- ✅ **79%** *"have started a free trial intending to cancel, then forgotten and been charged"*; **$45/month** on forgotten trials ([Dimers](https://www.dimers.com/press/news/how-far-americans-will-go-for-freebies), Sep 2026). ⚠️ General population, self-reported.
- ✅ **$86** guessed vs **$219** actual subscription spend ([C+R](https://www.crresearch.com/blog/subscription-service-statistics-and-costs/)).
- ❌ Never use: "$1,900/yr", "$15–20k/yr", "thousands a year", "48%".

> ## VERDICT: **GO** (confidence: medium)
> The money-tracking half now has a direct rival (Clawback), and the persistent alarm exists in Nudgy, so **Unfreeze is the differentiator**: exact, curated steps for real cancellations, AI steps for deadline tasks, one engine, one scoreboard. Lead the video with it.

---

## 3. Unfreeze mode (Dev B)

**Entry:** alarm "Decide" → Decide screen → 🧊 **I'm frozen** · any item card · Home "I'm frozen" button (task path).

**Rules:**
- **One step on screen, nothing else.** Huge text, one "Done," a quiet "break it smaller / skip."
- Each step **≤ ~90 s**, physical, verb-first. The first step is trivially small ("Open a blank doc. Type your name.").
- Soft **90-second ring**, never punishing. Companion line (*"I'll wait right here."*); optional voice (AVSpeechSynthesizer) and ambient sound.
- **"Your first step is always free."** Never block someone mid-freeze.
- Ends with optional proof (screenshot) → 🎉 → scoreboard.

| Source | For | Trust |
|---|---|---|
| Curated `CancelSteps.json` (Dev A writes the content, Dev B's engine plays it) | Known services (5 in the sprint) | ⚠️ hand-verified, re-checked before the demo |
| Apple subscriptions path | Trials billed by Apple | ⚠️ exact link/API confirmed in spike |
| AI fallback, labeled "Suggested steps," never invents URLs | Unknown services | Generic but concrete |
| AI atomizer (Foundation Models `@Generable`: `[Step{text, seconds ≤ 90}]`) | Tasks | ⚠️ quality spike (≥ 15/20) |

---

## 4. Scoreboard: "ADHD Tax Refunded" (Dev B)
```
 ADHD TAX REFUNDED
 💰 $214.47 back   📝 12 tasks unfrozen   🔥 best run: 5 days
 This month: Cancelled Hulu +$17.99 · Wrote history essay ✅ · …
 [Share my wins]
```
Only real dollars count (cancelled before the charge). No "streak lost" messaging.

---

## 5. MVP scope

**In (sprint):** share-sheet + manual capture · **free trials only** · escalation (widget, reminders, AlarmKit alarm with Stop re-arming) · Decide screen · Unfreeze (5 curated services + Apple path + AI fallback) · task path with AI atomizer · audio companion · scoreboard + celebration + share image · RevenueCat paywall (Test Store) + our-own-trial reminder · no server, no accounts, no API keys.

**Later:** email forwarding pipeline (Cloudflare Email Routing + Worker + D1) · returns, gift cards, bills · curated services 5 → 20 → 50 · key-holding server AI proxy · push "Found" notifications · Friction-style app lock (parked, §14) · Outlook/iCloud · Watch · Android.

---

## 6. Paywall (Dev A)
```
 UNTAX PRO: $29.99 lifetime  (also $3.99/mo · $24.99/yr)   [Start 7-day free trial] [Restore]
 Free forever: 5 money deadlines · reminders · curated cancel steps · first step always free
 Pro: unlimited · final-day alarm · AI unfreeze for any service & any task · voice/audio companion
 🔔 "We'll remind you 24 hrs before THIS trial ends too. Because that would be pretty ironic. 😉"
 "We'd never charge a subscription to fix your follow-through."
```
🟡 Free unfreeze limit: breadth-gated (recommended) vs 3 sessions/week. "First step always free" either way.

---

## 7. Tech stack (✅ pinned 2026-09-24/25)
| Piece | Choice |
|---|---|
| Tooling | Xcode 27 / iOS 27 SDK / Swift 6.4 (Xcode needs macOS Tahoe 26.6+) · **deployment target iOS 26** |
| UI / data | SwiftUI · SwiftData in an App Group (✅ works on a free Apple ID) |
| Alarm | AlarmKit (`AlarmConfiguration` with `stopIntent` + `secondaryIntent`) |
| AI | Foundation Models (`@Generable`) + Vision OCR, on-device only |
| Audio | AVSpeechSynthesizer (voice) + AVAudioEngine (procedural ambient; no licensing) |
| Payments | RevenueCat `purchases-ios` **5.91.0** (Test Store in dev) |
| Later | Cloudflare `wrangler` 4.139.0 · `postal-mime` 3.0.0 · `@anthropic-ai/sdk` 0.128.0 · `zod` 4.6.5 |
| 💰 | Optional $99 Apple Program (push, real sandbox IAP, Time Sensitive). QuickTime is free for recording |

---

## 8. Architecture
```
 Parachute.xcodeproj ── thin App target (composition root) · Widgets (B) · ShareExtension (A)
        │ injects protocol implementations
        ▼
 Packages/
  ├── SharedKit     (A+B) models · protocols · design system · CancelSteps.json resource
  ├── MoneyKit      (A)   capture/extraction · EscalationScheduler · AlarmKit · Decide · Entitlements(RevenueCat) · Paywall
  └── ParachuteKit  (B)   UnfreezeEngine · atomizer · UnfreezePlayer UI · task path · audio · Scoreboard/Ledger
 Rules: MoneyKit and ParachuteKit never import each other; both depend only on SharedKit.
        The App target wires them together (Decide "I'm frozen" → ParachuteKit's UnfreezeView).
```
Contracts: `docs/interfaces.md`. This split means two people rarely edit the same files, and it gives judges a clean-architecture story (criterion 4).

---

## 9. Project structure
```
untax/                             (repo; code names keep Parachute)
├── CLAUDE.md  PLAN.md  MILESTONES.md  PROJECT.md  IDEAS.md  README.md  LICENSE  .gitignore
├── Parachute.xcodeproj            (created in Phase 0)
├── App/                           composition root, tab bar (Home · Money · Tasks · Scoreboard)
├── Widgets/                       (B) countdown + current-step widgets
├── ShareExtension/                (A) screenshot → "Track it?"
├── Packages/SharedKit · MoneyKit · ParachuteKit (each with Tests/)
├── docs/                          interfaces.md · demo-script.md · cancel-steps-verification.md
└── research/                      background evidence (read-only)
```

---

## 10. Video: see `docs/demo-script.md`
Structure: hook → two taxes → thesis → money flow with the freeze → task flow → scoreboard → paywall → tech → close ("Pull the cord."). Only ✅ numbers on screen; the real app only.

## 11. Repo quality bar (both)
README: icon + 3 screenshots · pitch · Mermaid architecture · badges · **"How RevenueCat is used"** · build steps · privacy · MIT. Code: Swift 6.4 strict concurrency · package boundaries respected · tests (date math, escalation, alarm re-arm, CancelSteps validity, atomizer schema) · no secrets · no Test Store key in Release.

## 12. Team, eligibility, submission
- **Dev A (you):** Money path (the Untax half). **Dev B (friend):** Unfreeze (unfreeze + tasks, `ParachuteKit`). Details: `MILESTONES.md`.
- 🟡 **Representative:** one of you submits on Devpost and allocates any prize.
- ⚠️ Both confirm: a student/academic email on Devpost; guardian consent if under 18.

## 13. Open decisions 🟡
1. **Sep 30 sprint or a longer build?** (`MILESTONES.md` is dated for Sep 30; same order either way.)
2. **Apple account:** free (Test Store, local notifications only) or $99.
3. **Free unfreeze limit:** breadth-gated (recommended) or 3/week.
4. **Which 5 services** to curate (ones you can test with real accounts).
5. **Audio:** voice check-ins, procedural ambient, or both.
6. **Representative** + eligibility confirmations.
7. **Logo / app icon:** decide later, before V2 (README screenshots). Until then notifications show a blank icon.
8. **Deferred test, end of sprint (P1 / Sync 4): alarm with iOS 27's "Alarms and Timers" volume at zero** (Settings → Sounds & Haptics, turn off *Match Ringtone Volume*). Expect a silent but full-screen alert, since apps can't override it. If so, add an onboarding tip to check that volume.

## 14. Parked
- **Friction-style lock** (block chosen apps until you decide): ✅ needs the $99 Program even for development; opening the app from the block screen needs iOS 26.5+. See `research/friction-research.md`.
- **Email forwarding pipeline:** designed and verified (`research/untax-original-plan.md`); after the sprint.

## 15. Claim audit (key rows; the full 44-row audit is in `research/untax-original-plan.md` §11)
| Claim | Status |
|---|---|
| Next Gen: video + public repo w/ license; no store/paid account; no promo code | ✅ rules |
| Teams allowed; Representative submits; all-student requirement for teams | ✅ / ✅ every member must be a student (Shipaton Discord, via Dev A, 2026-09-28) |
| RevenueCat SDK must power ≥ 1 purchase; deadline Sep 30 11:45pm PDT | ✅ rules |
| AlarmKit: iOS 26+, Silent/Focus breakthrough, Stop + 1 button, stopIntent | ✅ Apple docs + WWDC25 |
| Foundation Models: iOS 26+, on-device, needs Apple Intelligence | ✅ Apple docs |
| Free Apple ID: App Groups yes; Push/SiwA/IAP/Time Sensitive no | ✅ Apple capabilities table |
| RevenueCat Test Store: no setup, ≥ 5.43.0, never in release | ✅ RevenueCat docs |
| Test Store product prices can't be edited after saving | ✅ RevenueCat docs (A8, 2026-09-27) |
| Test Store supports free trials / intro offers | ✅ dashboard offers a free-trial period + eligibility on subscription products; purchase on device (2026-09-28) |
| Clawback (Sep 24) & Nudgy (Aug) exist as described | ✅ App Store listings |
| 79% / $45/mo (Dimers); 15.5M ADHD (CDC); $86 vs $219 (C+R) | ✅ |
| Local notifications need no special capability | ✅ A0 on device (2026-09-26) |
| Test Store works without the IAP capability | ✅ A0 on device (2026-09-26) |
| Curated cancel steps accurate | ⚠️ hand-verify |
| AI atomizer quality | ⚠️ spike (≥ 15/20) |
| Our combination is unique | ⚠️ searches only |
