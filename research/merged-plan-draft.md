# PLAN — Untax × Parachute (name TBD)

> **The ADHD follow-through engine.** It catches the money deadlines your brain loses, nudges until you act, and when you freeze, on a cancellation *or* an essay, it walks you through one tiny step at a time.

Updated 2026-09-25 · Merges `PLAN.md` (Untax), `PARACHUTE-RESEARCH.md`, and the friend's `parachute_plan.md` (their good parts adopted; conflicts corrected in §14)
**Legend:** ✅ verified at the primary source (§15) · ⚠️ unverified/secondary · ❌ checked and false · 🟡 = your decision (§13)

---

## 0. The judge, the rules, the one core flow

**Category:** RevenueCat Shipaton 2026, **Next Gen Award** ([rules](https://revenuecat-shipaton-2026.devpost.com/rules)):
- ✅ Submit **a demo video + a public open-source repo with a license file**; *"No paid Apple or Google developer account or store release is required."*
- ✅ *"Next Gen Award Projects will be evaluated using the demonstration video and code repository."* → **No judge promo code needed.**
- ✅ Must use the RevenueCat SDK *"to power at least one in-app or web purchase."*
- ✅ Eligibility: an active student using *"a qualifying student or academic email address on Devpost"*; under-18s need guardian consent.
- ✅ Deadline **Wed Sep 30, 2026, 11:45pm PDT**; video under 2 minutes.
- ✅ Criteria: (1) clear, useful, original idea · (2) meaningful progress toward a working app · (3) thoughtful RevenueCat use · (4) thoughtful technical choices, product thinking, care in build **and presentation**.

**The unified insight** *(from friend's plan)*: competitors treat ADHD as either a **money problem** (subscription trackers) or a **productivity problem** (task apps). For ADHD brains it's one problem: *you see it, you know you should do it, you can't start, and the shame grows the longer you wait.* **One engine handles both.**

**The core flow:**
```
          💸 MONEY PATH (hero)                      📝 TASK PATH 🟡
  Share a trial screenshot → "Track it?"      "I'm frozen" → "What's overwhelming you?"
                 │                                         │
                 ▼                                         ▼
 ┌─────────────────── SHARED FOLLOW-THROUGH ENGINE ────────────────────┐
 │ Escalate: widget → reminders → final-day alarm (Stop only postpones) │
 │ Decide:   Cancel/Do it · Keep · Snooze-until · 🧊 I'm frozen          │
 │ Unfreeze: one tiny step at a time · 90s ring · companion             │
 │ Reward:   🎉 → ADHD Tax Refunded scoreboard                           │
 └──────────────────────────────────────────────────────────────────────┘
```

**Pitch lines:** *"Stop paying for forgetting. Stop freezing when it matters."* · *"Every app reminds you. This one gets you through it."* · If named Pullcord: **"Pull the cord."**

---

## 1. Two paths, one engine

| Mechanic | 💸 Money path | 📝 Task path 🟡 |
|---|---|---|
| Capture | Share sheet screenshot → on-device AI → "Track it?" · manual add | "I'm frozen" → describe it ("8-page essay due at midnight") |
| Escalation | Widget → reminders → final-day AlarmKit alarm | Due-time reminders → "Still stuck?" nudge → alarm at the deadline |
| Decide | Cancel · Keep · Snooze-until · 🧊 I'm frozen | Do it now · Break it smaller · Snooze-until |
| Steps | **Curated** cancel steps (exact) → AI fallback | **AI** micro-steps (Foundation Models) |
| Reward | "+$17.99 ADHD Tax Refunded" | "+1 task unfrozen" |
| Widget | "Hulu · $17.99 in 3 days" | "Essay · Step 3 of 7" |

**Recommendation on the task path 🟡:** include it, narrowly: **tasks with a deadline** only (essays, forms, applications), launched from "I'm frozen." Why: it makes the story fit a *student* category (the 11 PM essay beat), and it makes on-device AI essential to the app, not decoration (criterion 4). Why be careful: generic task breakdown is crowded (✅ Tiimo, App of the Year 2025; ✅ Goblin Tools; ✅ 8+ "unstuck" apps), and the steps can't be curated. **The money path stays the hero and the differentiator.** The task path is what makes the app relatable to students.

---

## 2. Research & Verdict

**IDEA:** One follow-through engine for ADHD: capture → escalate → decide → unfreeze → reward, for money deadlines (hero) and deadline tasks.
**PROBLEM:** The "ADHD tax": money and deadlines lost not to forgetting but to **not starting**.
**TARGET USER:** Students/young adults with ADHD or ADHD-like follow-through struggles, US first.

### A. Competitors (✅ all verified; details in `PLAN.md` §2 and `PARACHUTE-RESEARCH.md`)
| Space | Players | What they miss |
|---|---|---|
| Subscription capture | SubDupes, Track-Subs ($6.99/mo), Rocket Money ($7–14/mo) | Remembering only; no unfreeze |
| ADHD deadlines | **Deadlinr** (manual + barcode, pay-once) | No auto-capture, no follow-through |
| Trial trackers | Free Trial Killer, Trial Alert, TrialHero | One ignorable alert |
| Micro-steps / unfreeze | Tiimo (~20k ratings), Goblin Tools (~3k), EmberTend, UnfreezeMe, First Step, FOCO ($9/mo) | Generic tasks; not tied to money deadlines; AI-only steps |
| Lock until done | Due or Die | Generic to-dos, manual |
| **🚨 Same pitch as Untax** | ✅ **Clawback: Beat the ADHD Tax** (App Store id 6794979038, **released 2026-09-24**, 0 ratings): trials, returns, late fees; photo capture reads amount + due date; *"nudge harder as a deadline closes in"*; *"see how much you've recovered"*; no shame/no streaks; on-device, no account | ⚠️ From its listing: no alarm, no step-by-step unfreeze, no task path. **Possibly another Shipaton entrant.** |
| **🚨 Same alarm mechanic** | ✅ **Nudgy: Reminders Until Done** (released 2026-08-07, 3 ratings): *"pressing Stop isn't done… Stop only silences it for now"*; rings through Silent; confirm in-app to finish | Generic reminders; not money, no unfreeze steps |

**What this changes:** the *money-tracking* half and the *"Stop only postpones"* alarm each exist on their own now. **What's still unique** (from listings, ⚠️ not hands-on): **"🧊 I'm frozen" → curated, exact steps for the specific cancellation**, the task path, and the full chain (capture → alarm → decide → unfreeze → scoreboard). → **Lead the video and README with Unfreeze, not with "track your trials."**

⚠️ No app found combining money-deadline capture + escalation + **curated** unfreeze steps + a refunded-dollars scoreboard (searches can't prove absence).

### B. Demand
- ✅ **15.5M** US adults with ADHD; **55.9%** diagnosed as adults ([CDC](https://www.cdc.gov/mmwr/volumes/73/wr/mm7340a1.htm)).
- ✅ **79%** *"have started a free trial intending to cancel, then forgotten and been charged"*; **$45/mo** on forgotten trials ([Dimers](https://www.dimers.com/press/news/how-far-americans-will-go-for-freebies), 2,000 US adults, Sep 2026). ⚠️ General population, self-reported.
- ✅ **$86** guessed vs **$219** actual subscription spend ([C+R](https://www.crresearch.com/blog/subscription-service-statistics-and-costs/)).
- ✅ Apple named an ADHD AI planner App of the Year 2025 ([Apple](https://www.apple.com/newsroom/2025/12/apple-unveils-the-winners-of-the-2025-app-store-awards/)).
- ❌ Never use: "thousands a year" (friend's script), "$15–20k", "$1,900", "48%".

### C. The gap
Others solve **remembering** *or* **starting**. Nobody chains them to **real deadlines** with **exact steps where they can be known** and a **scoreboard of what you got back**.

### D. Feasibility (✅ unless marked)
- **AlarmKit** (iOS 26+): breaks through Silent and Focus; **alert = Stop + one secondary button**; `stopIntent` re-arms → "Stop only postpones." ❌ A 3-button alarm that "can't be dismissed" (friend's mockup) is **not possible**.
- **Foundation Models** (iOS 26+): on-device `@Generable` structured output; needs an Apple Intelligence device.
- **Voice/audio:** `AVSpeechSynthesizer` (iOS 7+) for check-ins. ⚠️ Ambient sound must be licensed, or generate it in code (e.g. procedural brown noise with AVAudioEngine) → no licensing issue.
- **Free Apple ID:** App Groups ✅ (widgets + share extension work); **no** Push / Sign in with Apple / In-App Purchase / Time Sensitive → use RevenueCat **Test Store** (✅ no setup; ⚠️ untested without the IAP capability) and local notifications (⚠️ confirm they need no special capability; spike M0b).
- **No server in the sprint** *(friend's cut, adopted)*: email pipeline, Cloudflare, D1, and APNs move to "later."
- ⚠️ **Security catch in the friend's stack:** "Claude via Anthropic SDK" as the fallback **with no server** would put an API key inside an **open-source** app → leaked key. **Sprint rule: no API key in the app.** On devices without Apple Intelligence, fall back to manual entry and curated steps. A tiny key-holding proxy can come later.

### E. Business
- ✅ Benchmarks: Rocket Money $7–14/mo · Track-Subs $6.99/mo · FOCO $9/mo or $59/yr · Deadlinr pay-once · Goblin Tools $1.99.
- **Paywall** (see §6).
- **Top risks:** (1) AI task steps come out generic (task path); (2) curated cancel steps go stale; (3) two paths = scope creep in 5 days.

> ## VERDICT: **GO** (confidence: medium)
> One engine, two paths, with money as the hero. Curated cancel steps remove the generic-AI risk where it matters most. The essay path gives a student category its most relatable beat.

---

## 3. Unfreeze mode (design)

**Entry:** alarm "Decide" button → Decide screen → 🧊 **I'm frozen** · any item card · Home "I'm frozen" button (task path).

**Screen rules (ADHD-first):**
- **One step on screen, nothing else.** Huge text, one "Done," a quiet "break it smaller / skip."
- Each step **≤ ~90 seconds**, **physical and concrete**, starts with a verb.
- Soft **90-second ring**; never punishing.
- Companion line (*"I'll wait right here."*), optional voice read-out (`AVSpeechSynthesizer`), optional ambient sound.
- **"Your first step is always free."** Even over any free limit, Step 1 shows before any paywall. Never block someone mid-freeze.
- End: proof (optional screenshot) → 🎉 → scoreboard.

**Where steps come from:**
| Path | Source | Trust |
|---|---|---|
| 💸 Known service | Curated `CancelSteps.json` (steps + direct link) | ⚠️ **hand-verify each service; re-check before the demo** |
| 💸 App Store trial | Apple's subscription settings path | ⚠️ exact link/API confirmed in spike |
| 💸 Unknown service | AI fallback, labeled "Suggested steps," **never invents URLs** | Generic-but-concrete |
| 📝 Task | AI atomizer (Foundation Models `@Generable`: `[Step{text, seconds ≤ 90}]`), prompt rules: physical, verb-first, first step trivially small ("Open a blank doc. Type your name.") | ⚠️ quality spike M0c |

---

## 4. The scoreboard: "ADHD Tax Refunded" *(friend's design, adopted)*
```
 ADHD TAX REFUNDED
 💰 $214.47 back   📝 12 tasks unfrozen   🔥 5 days in a row
 This month: Cancelled Hulu +$17.99 · Wrote history essay ✅ · …
 [Share my wins]
```
- ⚠️ **Streak design rule:** streaks can backfire for ADHD (a broken streak = shame). Show a **"best run"** and a gentle "welcome back." Never "you lost your streak."
- Only **real** dollars count (cancelled before the charge, return completed). Estimates are labeled.

---

## 5. MVP scope

**Sprint (Sep 26–30):**
1. Capture: **share sheet** (Vision OCR + Foundation Models) + manual add · *email forwarding cut from the sprint*
2. 💸 **Free trials only** in the sprint (returns later) 🟡
3. Escalation: widget → local reminders (−3d, −1d) → final-day AlarmKit alarm (Stop re-arms)
4. Decide screen + **Unfreeze mode** (curated steps for **5 services** + Apple path; AI fallback if time allows)
5. 📝 Task path: "I'm frozen" → AI micro-steps (if chosen 🟡)
6. Scoreboard + celebration haptics/animation + Share my wins (image)
7. RevenueCat paywall (Test Store) + our-own-trial reminder
8. No server, no accounts, no API keys in the app

**Later (full build):** email forwarding pipeline (Cloudflare) · returns, gift cards, bills · curated services 5 → 20 → 50 · server AI proxy · push "Found" notifications · Friction's lock (parked) · Outlook/iCloud · Watch · Android · accountability buddy · location reminders · calendar export.

---

## 6. Paywall (RevenueCat)

*(Friend's copy adopted; limits are a 🟡 decision)*
```
 PRO: $29.99 lifetime   (also $3.99/mo · $24.99/yr)   [Start 7-day free trial] [Restore]
 Free forever: 5 money deadlines · reminders · curated cancel steps · first step always free
 Pro: unlimited · final-day alarm · AI unfreeze for any service & any task · voice/audio companion
 🔔 "We'll remind you 24 hrs before THIS trial ends too. Because that would be pretty ironic. 😉"
 "We'd never charge a subscription to fix your follow-through."
```
🟡 Free unfreeze limit: **A)** breadth-gated (curated steps free; AI + voice in Pro; recommended) **or B)** the friend's "3 unfreeze sessions/week," with "first step always free" as a safeguard either way.

---

## 7. Tech stack (✅ pinned 2026-09-24/25)

| Piece | Choice |
|---|---|
| iOS | SwiftUI + SwiftData (App Group) · Xcode 27 / iOS 27 SDK / Swift 6.4 (needs macOS Tahoe 26.6+) · **min iOS 26** |
| Alarm | AlarmKit (`stopIntent`, `secondaryIntent`) |
| AI | Foundation Models (`@Generable`) + Vision OCR; **no server AI in the sprint** |
| Audio | `AVSpeechSynthesizer` + AVAudioEngine (procedural ambient) |
| Payments | RevenueCat `purchases-ios` **5.91.0**, Test Store key (dev only; never in a release build) |
| Later | Cloudflare Workers + Email Routing + D1 (`wrangler` 4.139.0, `postal-mime` 3.0.0), `@anthropic-ai/sdk` 0.128.0 + `zod` 4.6.5 behind a key-holding proxy |
| ~~Auth~~ | ~~Sign in with Apple~~: removed (not on a free Apple ID; not needed without a server) |
| 💰 | Optional $99 Apple Program · ⚠️ Screen Studio (friend's pick for recording) is paid; QuickTime screen recording is free |

**Models (Swift):** `MoneyDeadline`, `FrozenTask`, `MicroStep`, `CompletionRecord` *(friend's)*. One shared `FollowThroughEngine` protocol drives escalation, decisions, and steps for both → a clean architecture story for criterion 4.

---

## 8. Architecture
```
 ┌──────────────────────────── iPhone (on-device only) ────────────────────────────┐
 │ Capture: Share ext (Vision OCR → Foundation Models) · manual · "I'm frozen"      │
 │ SwiftData in App Group: MoneyDeadline · FrozenTask · MicroStep · CompletionRecord │
 │ FollowThroughEngine ─► Escalation: widget → local reminders → AlarmKit alarm     │
 │                      ─► Decide screen ─► Unfreeze engine                          │
 │                          CancelSteps.json ▸ Apple subs path ▸ FM atomizer         │
 │                      ─► Reward: scoreboard 🎉 · Share my wins                     │
 │ Paywall: RevenueCat (Test Store in dev)                                           │
 └───────────────────────────────────────────────────────────────────────────────────┘
   later: Cloudflare email pipeline + key-holding AI proxy
```

---

## 9. Project structure
```
app/
├── ios/App.xcodeproj
│   ├── App/            Home, Money, Tasks, Scoreboard (tab bar) · Decide · Unfreeze · Paywall · Settings
│   ├── Shared/         Models · FollowThroughEngine · UnfreezeEngine · CancelSteps.json · date logic
│   ├── Widgets/        Countdown / current-step widget
│   ├── ShareExtension/
│   └── Tests/          date math · escalation schedule · alarm re-arm · CancelSteps validity · atomizer schema
├── docs/               architecture.md · privacy-policy.md · demo-script.md · cancel-steps-verification.md
├── README.md  PLAN-untax-x-parachute.md  PROJECT.md  IDEAS.md  LICENSE (MIT)
```

---

## 10. Milestones

### Spikes (today, Sep 25): each one decides scope
- [ ] **M0b: Platform check.** On a real iPhone with your chosen Apple account: AlarmKit alarm + Stop re-arming · local notifications · RevenueCat Test Store purchase. *Done when:* all three work, or scope is adjusted.
- [ ] **M0c: Step quality.** Hand-verify cancel steps for 5 services on real accounts; run the atomizer on 20 sample tasks (essays, forms, emails). *Done when:* curated steps are followed end to end (logged with screenshots in `docs/cancel-steps-verification.md`); ≥ 15/20 AI step lists are specific enough to follow, or the task path is cut 🟡.

### 5-day sprint *(friend's day plan merged with ours; alarm corrected)*
**Day 1 (Sep 26): Foundation**
- [ ] Xcode project: app + widget extension + share extension, App Group
- [ ] SwiftData models; tab bar (Home / Money / Tasks / Scoreboard)
- [ ] Manual "Add deadline" (name, date, amount, service); item list with countdowns
- [ ] Finish `CancelSteps.json` for 5 verified services
- *Done when:* items persist and the widget shows the next countdown; date tests pass.

**Day 2 (Sep 27): Follow-through**
- [ ] Local reminder ladder (−3d, −1d)
- [ ] AlarmKit final-day alarm: **Stop → `stopIntent` re-arms in 30 min**; secondary **"Decide"** opens the app
- [ ] Decide screen (Cancel · Keep · Snooze-until · 🧊 I'm frozen)
- [ ] Unfreeze mode for curated services (one step, 90s ring, companion line)
- *Done when:* in time-travel mode an item goes reminder → alarm → Stop → re-fires → Decide → Unfreeze → Cancelled.

**Day 3 (Sep 28): AI + reward**
- [ ] Share extension: screenshot → Vision OCR → Foundation Models → "Found: X. Track it?"
- [ ] 📝 Task path: "I'm frozen" → atomizer → steps (if kept 🟡)
- [ ] Scoreboard + celebration haptics/animation + Share my wins
- [ ] Audio: voice check-ins + ambient sound
- *Done when:* 10 fixture screenshots → correct items in ≤ 2 taps; 5 sample tasks → usable steps.

**Day 4 (Sep 29): Paywall + polish** *(friend's polish list)*
- [ ] RevenueCat paywall, entitlement gating, restore, our-own-trial reminder
- [ ] Dark Mode · Dynamic Type · VoiceOver labels · SF Symbols · smooth state animations
- [ ] Seed realistic demo data; screen-record every flow
- *Done when:* a Test Store purchase unlocks Pro; the full demo runs 3× without a crash.

**Day 5 (Sep 30): Ship** *(deadline 11:45pm PDT)*
- [ ] Record the video (device frames, voiceover, **captions**)
- [ ] README: icon, screenshots, Mermaid architecture, **"How RevenueCat is used,"** build steps, privacy, MIT license
- [ ] Code sweep: no keys (**no Test Store key in release config**), no dead code
- [ ] Devpost description · submit with hours to spare
- *Done when:* submitted; a newcomer understands the app from the first 15 seconds.

**Cut order if behind:** audio → task path → AI fallback for unknown services → share-sheet capture (manual add still demos everything). **Never cut:** alarm → Decide → Unfreeze → scoreboard → paywall.

---

## 11. Video (< 2 min) *(friend's structure; stats and alarm corrected)*
```
0:00–0:05  HOOK        "Regular people set a reminder and do it." … "My brain doesn't work like that."
0:05–0:15  TWO TAXES   Split screen: LEFT "Hulu trial ends tomorrow" swiped away → $17.99 charged.
                       RIGHT blank doc at 11 PM, cursor blinking → "Essay due in 45 min."
                       VO: "79% of Americans have started a free trial meaning to cancel, and got
                       charged anyway. For ADHD brains, it's not just money. It's assignments. Sleep.
                       Self-respect. They call it the ADHD tax."        ✅ Dimers (no "thousands")
0:15–0:22  THESIS      Icon + name. "Every app reminds you. This one gets you through it."
0:22–0:42  MONEY       Share screenshot → "Found: trial · ends Oct 3 · $17.99/mo · Track it?" →
                       widget countdown → full-screen alarm → Stop → "It comes back in 30 minutes.
                       It only stops when you decide." → Decide → 🧊 I'm frozen → "Step 1: Open
                       Settings. That's it." → Cancelled → 🎉 "+$17.99 ADHD Tax Refunded"
0:42–1:00  TASK 🟡     "I'm frozen" → "History essay due at midnight" → "Step 1: Open a blank doc.
                       Type your name." → ambient companion fades in → ✅ ✅ → "+1 task unfrozen"
1:00–1:10  SCOREBOARD  $214 back · 12 tasks · 5-day run. "Not a guilt trip. Proof your brain works;
                       it just needed a parachute."
1:10–1:25  PAYWALL     "$29.99 lifetime." Ironic banner. "We'd never charge a subscription to fix
                       your follow-through." [beat]
1:25–1:40  TECH        Architecture (3s) · `@Generable` atomizer code (3s) · README. "SwiftUI, AlarmKit,
                       on-device Foundation Models: all AI runs locally, offline, private. Open source."
1:40–2:00  CLOSE       Recap card → icon. "Stop paying for forgetting. Stop freezing when it matters."
                       (+ "Pull the cord." if named Pullcord) · GitHub link/QR
```
⚠️ **Demo consistency:** "Apple subscriptions page" only works for trials **billed by Apple**. Either demo a trial started in an App Store app, or show that service's own curated cancel page. Don't show a web-signup Hulu trial cancelled through Apple settings.
Rules: only ✅ numbers on screen · the real app only · say what it does within 20 seconds.

---

## 12. Repo quality bar
README: icon + 3 screenshots · one-line pitch · Mermaid architecture · badges · **"How RevenueCat is used"** · build steps · privacy · MIT.
Code: Swift 6.4 strict concurrency · `FollowThroughEngine` shared by both paths · tests (date math, escalation, alarm re-arm, CancelSteps validity, atomizer schema) · no secrets · no Test Store key in release.

---

## 13. Open decisions 🟡
1. **Task path in or out?** (Recommended: in, deadline tasks only, cut first if behind.)
2. **Name:** App Store-clear (2026-09-25, name search only, not trademark): **Pullcord**, **Pull the Cord**, **Thawt**, **Now Not Later**, **Tiny Push**, Safety Net, Oopsie Daisy, Forgetti, Refund Raccoon, Trial and Error, Nopetopus. ❌ Taken: Parachute, Unfrozen, Unfreeze, Unstuck, Thaw, Lifeline, Bailout, Clawback (the competitor above), Nudgy, Recoup, Payback, Jumpstart, Liftoff. ⚠️ Ripcord (near "RipcordGo"). Prefer names about *getting unstuck*, since that's what sets us apart from Clawback.
3. **Free unfreeze limit:** A) breadth-gated (recommended) or B) 3 sessions/week; "first step always free" either way.
4. **Returns in the sprint?** (Friend: trials only. Recommended: trials only; returns right after.)
5. **Apple account:** free (Test Store) or $99.
6. **Which 5 services to curate:** ones you can actually test with real accounts.
7. **Audio:** voice check-ins, procedural ambient, or both.
8. **Eligibility:** are you under 18 (guardian consent)? Do you have a student/academic email for Devpost?

---

## 14. What we took from the friend's `parachute_plan.md`, and what we corrected
**Adopted:** the unified insight + "two paths, one engine" · the shared-mechanics table · scoreboard with tasks + streak + Share my wins · paywall copy ("pretty ironic 😉", "fix your follow-through") · cutting the email pipeline and server from the sprint · trials-only sprint · SwiftData model names + tab bar · Day 4 polish checklist (Dark Mode, Dynamic Type, SF Symbols, seeded demo data) · video "two taxes" split screen + essay beat · "Pull the cord" tagline · eligibility questions.
**Corrected:**
| Friend's plan | Why | Now |
|---|---|---|
| 3-button alarm, "cannot dismiss without choosing" | ❌ AlarmKit = Stop + 1 button; Stop always works | Stop re-arms via `stopIntent`; "Decide" opens the 4-choice screen |
| Claude API fallback with no server | ⚠️ API key would ship in an open-source app | No key in the app; manual/curated fallback; proxy later |
| Sign in with Apple | ✅ Not available on a free Apple ID; unneeded without a server | Removed |
| "It adds up to thousands a year" | ❌ No source | ✅ 79% / $45 per month (Dimers) |
| "Prepare judge promo code" | ✅ Next Gen judged on video + repo only | Dropped |
| Top 20 curated cancel URLs in 5 days | Each needs hand-verification | 5 in the sprint, 20 later |
| Hulu email → Apple subscriptions page | Only Apple-billed trials cancel there | Demo consistency rule (§11) |
| "3 un-freezes/week" free limit | Blocking help mid-freeze hurts the story | Decision + "first step always free" |
| Streak counter | Broken streaks cause shame for ADHD users | Gentle "best run" |
| Screen Studio | Paid app | QuickTime is a free alternative |
| Name "Parachute" | ❌ Taken on the App Store | Pullcord / Pull the Cord are clear |

---

## 15. Claim audit
Everything from `PLAN.md` §11 still holds. Full quotes: `PLAN.md`, `PARACHUTE-RESEARCH.md`, `FRICTION-RESEARCH.md`. New or changed rows:

| Claim | Status | Source |
|---|---|---|
| Next Gen exempt from the promo-code requirement; judged on video + repo | ✅ | Shipaton rules |
| Next Gen needs a student/academic email on Devpost | ✅ | Shipaton rules |
| AlarmKit cannot show 3 buttons or block Stop | ✅ (the claim is ❌) | Apple AlarmKit docs |
| Sign in with Apple unavailable on a free Apple ID | ✅ | Apple capabilities table |
| "Thousands a year" ADHD tax | ❌ | No source |
| Pullcord, Pull the Cord: no App Store apps start with these | ✅ | App Store search API (not trademark) |
| Unfrozen taken; Ripcord near "RipcordGo"; Parachute taken | ✅ | App Store search API |
| "Clawback: Beat the ADHD Tax" released 2026-09-24 with a near-identical money pitch | ✅ | App Store listing (id 6794979038) |
| "Nudgy" ships "Stop only silences it for now" | ✅ | App Store listing |
| Our Unfreeze + task path not in Clawback/Nudgy | ⚠️ | Their listings only; not tested hands-on |
| Local notifications need no special capability | ⚠️ | Confirm in M0b |
| Test Store works without the IAP capability | ⚠️ | Confirm in M0b |
| AI atomizer quality for the task path | ⚠️ | M0c (≥ 15/20) |
| Curated cancel steps accurate | ⚠️ | Hand-verify (M0c) and re-check before the demo |
