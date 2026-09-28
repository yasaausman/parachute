# MILESTONES.md: Parachute (2 developers)

| | Owns | Code lives in |
|---|---|---|
| **Dev A: You (Money / "Untax" lead)** | Capturing money deadlines, escalation + alarm, Decide screen, curated cancel-step content, RevenueCat paywall | `Packages/MoneyKit`, `ShareExtension/` |
| **Dev B: Your friend (Parachute lead)** | Unfreeze engine + player, AI atomizer, task path, audio companion, scoreboard + celebration, widgets | `Packages/ParachuteKit`, `Widgets/` |
| **Both** | Models, protocols, design system, app shell, polish, README, video | `Packages/SharedKit`, `App/`, `docs/` |

**Dates assume the Sep 30, 2026, 11:45pm PDT deadline** (convert to your time zone). If you take longer, keep the same order and stretch the days.
Every milestone has a **Done when**. Nothing is done until it runs on a real iPhone.

---

## How you work together (read once)
- **Branches:** `a/<feature>` and `b/<feature>` → merge to `main` **as soon as a milestone builds and tests pass** (not only at a Sync), and `git pull` on `main` before starting work. Keep PRs small. See CLAUDE.md Conventions.
- **Ownership:** don't edit the other person's package without asking. **`SharedKit` changes need the other's review**; they're contracts (`docs/interfaces.md`).
- **Project-file conflicts:** almost all code lives in the Swift packages, so the Xcode project file rarely changes. ⚠️ If Xcode 27 offers folder-synced groups, use them for `App/`, `Widgets/`, `ShareExtension/` so adding files doesn't edit the project file.
- **Blocked?** Code against the protocol and use the fake implementation in `SharedKit/Fakes`. Never wait on the other person.
- **Daily sync:** 15 minutes at the end of each day: demo on device → merge → agree on tomorrow's first task.
- **Claude sessions:** tell Claude "I'm Dev A" or "I'm Dev B" at the start; it reads `CLAUDE.md`. Update `PROJECT.md` at each sync.

---

> **Dev B status (2026-09-27):** 🟡 = code complete, builds in Xcode 27, all tests pass on the iOS simulator, main flows checked in the simulator. **Not yet run on a real iPhone.** Tick each one after it runs on an iPhone.

## Phase 0: Setup & spikes (Fri Sep 25, today/tonight)

### Together (≈1.5 h, pair on one screen)
- [ ] **S0.1 Repo + project.** `git init`, push to a **public** GitHub repo. Create `Parachute.xcodeproj` (App + Widgets + ShareExtension targets, one App Group, deployment target iOS 26, Swift 6 language mode) and the three local packages. Add RevenueCat `purchases-ios` **5.91.0** via SPM.
  *Done when:* both of you clone, build, and run the empty app on your own iPhones.
- [ ] **S0.2 Contracts.** Put the models + protocols from `docs/interfaces.md` into `SharedKit`, with **fake implementations** in `SharedKit/Fakes`.
  *Done when:* the app compiles with fakes wired in; you both agree the interfaces won't change without a heads-up.
- [ ] **S0.3 Decisions.** Pick: free or $99 Apple account · the **5 services** to curate · the Representative. Both check you have a student/academic email for Devpost.
  *Done when:* written in `PROJECT.md`.

### Dev A spikes
- [x] **A0 Platform spike.** On a real iPhone with the chosen account: (1) schedule an AlarmKit alarm whose **Stop runs a `stopIntent` that re-arms it** 1 minute later; (2) schedule a local notification; (3) make a **RevenueCat Test Store** purchase.
  *Done when:* all three work, or you've written down what doesn't and the workaround.

### Dev B spikes
- [ ] 🟡 **B0 Atomizer spike.** (Kit ready: `docs/b0-atomizer-spike.md` + Home → ladybug → "Run B0 atomizer spike"; needs an Apple Intelligence iPhone; the simulator refuses inference.) Foundation Models `@Generable` → `[Step{text, seconds}]`. Run it on **20 real deadline tasks** (essays, forms, applications, emails) and **10 unknown services** ("how to cancel X").
  *Done when:* ≥ 15/20 task lists and ≥ 7/10 service lists are specific enough to follow without guessing; prompt + results saved in `docs/`. **If it fails, tell Dev A and cut or shrink the task path now.**

---

## Day 1: Foundation (Sat Sep 26)

### Dev A
- [x] **A1 Money deadlines, manual.** Add/edit/delete `MoneyDeadline` (service, amount, trial end date, billed by Apple?); list with countdowns ("Hulu · $17.99 in 3 days").
  *Done when:* items persist across launches; date-math tests pass.
  *Status (2026-09-26):* code done on `a/a1-money-deadlines`: Money tab list ("Spotify · $6.99 in 7 days"), add/edit/delete, curated quick-pick chips, Apple-billed items show "cancel by" a day early. 19 date-math/matching tests pass (incl. DST); add, edit, delete and persistence across a relaunch checked in the simulator; add, edit, sorting and the Apple "cancel by" line confirmed on Dev A's iPhone (iOS 27, dark mode).
- [x] **A2 Reminder ladder.** `EscalationScheduler` (real implementation): local notifications at −3 days and −1 day, with money-first copy ("$17.99 leaves your account tomorrow").
  *Done when:* in debug time-travel mode, both reminders fire for a test item.
  *Status (2026-09-26):* `EscalationScheduler` (real `EscalationScheduling`) on `a/a2-reminders`. Money ladder at 10:00, 3 days and 1 day before the last day to act (a day earlier for Apple-billed items); task ladder for B5 (1 day, 1 hour, at due). Saving a trial schedules, deleting resolves, the Money tab resyncs on open. Debug → *Reminders + time travel* shows what's pending and squeezes 1 day into 1 minute. 11 new tests (planner dates/copy, replace-not-duplicate, resolve, snooze, task path). **Simulator run:** Spotify $6.99 due Oct 3 → real schedule Sep 30 and Oct 2 at 10:00 → time travel → both fired at 6:29:30 and 6:31:30 PM ("Spotify · $6.99 in 3 days", "Spotify · $6.99 tomorrow / $6.99 leaves your account tomorrow"). **iPhone run (iOS 27):** Apple-billed Spotify $7.00 due Oct 3 → time travel → both fired at 6:49:53 and 6:51:53 PM in order ("in 4 days · cancel at least a day before Oct 3", "in 2 days · cancel by tomorrow to skip the Oct 3 charge"), also mirrored to the Mac. Time travel switched back off.
- [ ] **A3 Curate 5 services.** Hand-verify cancel steps on real accounts → `SharedKit/Resources/CancelSteps.json` + a log in `docs/cancel-steps-verification.md` (date, screenshots).
  *Done when:* each of the 5 was followed end to end; the JSON passes B's validity test.
  *Status (2026-09-26):* 4 of 5 in `CancelSteps.json`: Spotify, Claude, Google AI Pro (web, followed to the final button on a Mac) and Apple One (Apple-billed, cancelled for real on the iPhone). Left: service #5, the 3 web page URLs, and an iPhone Safari check of the 3 web flows. ✅ The JSON passes B's `testBundledFileIsValid` (2026-09-27).

### Dev B
- [ ] 🟡 **B1 Unfreeze player UI** (with a fake plan). One step on screen, 90-second ring, companion line, **Done / Break it smaller / Skip**, finish → callback.
  *Done when:* a 5-step fake plan plays start to finish; works with Dynamic Type at the largest size.
- [ ] 🟡 **B2 CancelSteps loader + validation.** Reads `CancelSteps.json` → `UnfreezePlan`; unit test rejects bad entries (missing steps, step > 90 s, empty text).
  *Done when:* the test passes on A's real file.

### 🔄 Sync 1 (end of Day 1)
*Simulator, 2026-09-27 (after merging PR #1):* Decide → 🧊 I'm frozen → B's `UnfreezeFlowView` played A's curated Spotify steps (Step 1 of 4…) → celebration "+$11.99 ADHD Tax Refunded" → scoreboard "Cancelled Spotify +$11.99". ☐ On device.
Merge. A temporary "I'm frozen" button on a money item opens **B's real UnfreezeView** with **A's real curated steps**.
*Done when:* you can "unfreeze" a real Netflix-style cancel on device.

---

## Day 2: The follow-through (Sun Sep 27)

### Dev A
- [x] **A4 Final-day alarm.** AlarmKit alarm on the deadline day: **Stop → `stopIntent` re-arms in 30 min**; secondary button **"Decide"** opens the app. It stops only when a decision is recorded.
  *Done when:* time-travel test: alarm → Stop → rings again → Decide → decision → no more alarms.
  *Status (2026-09-26):* built on `a/a4-alarm`. `DeadlineAlarms` chain in MoneyKit: rings at 9:00 on the last day to act ("Spotify charges $6.99 today" / Apple: "Cancel Apple One today · $21.95 tomorrow"); Stop re-arms in 30 min (1 min under time travel), including from a force-quit app; Decide (icon `arrow.up.forward.app.fill`, readable in the icon-only banner) opens the app on a minimal Decide screen and keeps a safety re-ring; recording a decision disarms. Resyncing mid-chain doesn't reset it. Tapping a reminder also opens Decide. 13 new tests. **iPhone run (iOS 27, 2026-09-26):** rang with the new Decide arrow icon → Stop → rang again a minute later under time travel (rings: 1) → Decide opened the Decide screen → Keep it → chain disarmed and 0 reminders left. Decide screen now uses the orange tint; the Debug screen refreshes live.
- [ ] **A5 Decide screen.** Cancel · Keep · Snooze-until · 🧊 I'm frozen. "I'm frozen" calls the injected `onFrozen(UnfreezeRequest)`; Cancel/Keep write a `CompletionRecord` via `CompletionLedger`.
  *Done when:* each of the 4 choices does the right thing, and Keep stops all nagging.
  *Status (2026-09-26):* built on `a/a5-decide`. Decide screen (big one-idea buttons): **Cancel it** → the hand-checked steps (or the generic Apple path) → "Done, it's cancelled"; **I'm frozen** → `onFrozen(UnfreezeRequest)` → app swaps to the Unfreeze sheet (placeholder list until B1) → "I did it" records the cancellation; **Keep it** → kept + ledger `moneyKept` + everything disarmed; **Snooze** → 1 hour / tonight at 8 / tomorrow at 9 / custom, never past the last moment to act. `DeadlineDecision` holds the rules (ledger `moneyCancelled` only counts dollars before the charge). Tapping a trial opens Decide; Edit moved to swipe/long-press; decided trials can be reopened. 9 new tests; all four paths clicked through in the simulator. **iPhone (2026-09-28):** Cancel it (curated steps → cancelled), Keep it, and the Snooze screen confirmed; I'm frozen with B's player checked in the simulator.
- [x] **A6 Apple subscriptions path.** For `billedByApple` items, the cancel step opens Apple's subscription management. ⚠️ Confirm the correct API/link on device.
  *Done when:* it opens the right screen on a real iPhone.
  *Status (2026-09-27):* built on `a/a6-apple-path`. `SharedKit.AppleSubscriptions`: steps from Apple Support 118428 ("In Settings, tap your name → Subscriptions → the subscription → Cancel Subscription"), Apple's web link (`account.apple.com/account/manage/section/subscriptions`, from the same article), and the button URL `https://apps.apple.com/account/subscriptions` ⚠️ (widely used, not on an Apple page). StoreKit's `showManageSubscriptions(in:)` was ruled out: Apple's docs say it shows *"the customer's currently active subscription for your app"*, i.e. Parachute's own. "Cancel it" on an Apple-billed trial now leads with **Open Apple Subscriptions**. **iPhone (iOS 27, 2026-09-28):** the button opens Apple's Subscriptions page directly, with "◀ Parachute" to come back.

### Dev B
- [ ] 🟡 **B3 UnfreezeEngine (real).** `UnfreezeProviding`: curated → Apple path → AI fallback ("Suggested steps," never invents URLs) → graceful non-AI fallback on devices without Apple Intelligence.
  *Done when:* the right source is picked for all 4 cases in unit tests.
- [ ] 🟡 **B4 Task path.** Home "I'm frozen" → "What's overwhelming you?" → `FrozenTask` (+ optional due time) → atomizer → player. "Break it smaller" re-atomizes the current step.
  *Done when:* 5 of B0's test tasks go from typed description to finished on device.
- [ ] 🟡 **B5 Task reminders.** The task path uses **A's `EscalationScheduling`** for due-time reminders and the deadline alarm.
  *Done when:* a task due in 5 minutes (time-travel) triggers a reminder.

### 🔄 Sync 2 (end of Day 2): the full money flow
*Done when:* on device, in time-travel: reminder → alarm → Stop → re-rings → Decide → 🧊 I'm frozen → curated steps → Cancelled → record saved. **This is the core of the video; if it works, you have a submission.**

---

## Day 3: AI capture + reward (Mon Sep 28)

### Dev A
- [ ] **A7 Share extension.** Screenshot/text → Vision OCR → Foundation Models extraction (service, amount, end date, billed by Apple?) → "Found: X. Track it?" → one tap. Falls back to a pre-filled manual form if AI is unavailable.
  *Done when:* 10 fixture screenshots → correct items in ≤ 2 taps (≥ 8/10 fully correct); fixtures committed.
  *Status (2026-09-27):* built on `a/a7-share-extension`. `TrialCapture` target: Vision OCR → `PatternExtractor` (non-AI, always on) + `AIExtractor` (Foundation Models `@Generable`, greedy) → a fact-check merge that throws out any AI price/date/name not printed in the text. Share sheet card: "Found: Spotify · $11.99 · charges Oct 26" → **Track it** (one tap) → saved to the App Group store with reminders; the app arms the alarm when it's next active. **Eval: 10/10 synthetic fixtures (committed, `Packages/MoneyKit/Fixtures/`), 4/5 on real screenshots** (not committed: personal data). Simulator: Photos → Share → Parachute → Track it → shows in the Money tab. 12 new tests. **iPhone (2026-09-28):** the share sheet works and Apple Intelligence runs inside the extension ("Read on this iPhone with Apple Intelligence"). **Bug found and fixed:** a Subscriptions screen with only cancelled items produced "Apple TV · $190.00 · charges Sep 27": the status-bar clock "5:44" became today's date and (probably) the status bar became "$190". Now: status bar ignored on phone screenshots, clock times and "Canceled <date>" aren't charge dates, and a screen with no price or date says "No upcoming charge on this screen". Regression tests added; Debug shows the last capture's OCR text. ☐ Re-test on the iPhone.

### Dev B
- [ ] 🟡 **B6 Scoreboard + ledger.** `CompletionLedger` implementation; "ADHD Tax Refunded" screen: $ back · tasks unfrozen · **best run** (no shame); monthly list.
  *Done when:* the numbers are right after cancel, keep (no $), task done, and snooze (nothing).
- [ ] 🟡 **B7 Celebration + share.** Confetti + haptics on every win; "Share my wins" renders an image card.
  *Done when:* smooth on device; the share sheet exports the image.
- [ ] 🟡 **B8 Widgets.** Money countdown ("Hulu · $17.99 in 3 days") + task variant ("Essay · Step 3 of 7"), reading SharedKit data from the App Group.
  *Done when:* both widgets update after changes in the app.
- [ ] 🟡 **B9 Audio companion.** AVSpeechSynthesizer reads the step aloud (toggle) + gentle procedural ambient sound (AVAudioEngine; no licensed audio).
  *Done when:* on/off works; audio stops cleanly when the player closes.

### 🔄 Sync 3
*Done when:* both paths run end to end on both phones; the scoreboard shows money + tasks; widgets are live.

---

## Day 4: Money + polish (Tue Sep 29)

### Dev A
- [ ] **A8 RevenueCat paywall.** Offerings: **$29.99 lifetime** (headline), $3.99/mo, $24.99/yr, 7-day trial; `EntitlementsProviding` (real) → `isPro`; Restore; the ironic banner; **a local reminder 24h before Parachute's own trial ends**.
  *Done when:* a Test Store purchase flips `isPro`, restore works, and gated features unlock.
  *Status (2026-09-27):* built on `a/a8-paywall`. `ProEntitlements` (real `EntitlementsProviding`): follows RevenueCat's `customerInfoStream`, `parachute_pro` → `isPro`; restore; schedules "your Parachute trial ends tomorrow" 24 h before a renewing trial ends. Custom `PaywallView` from the current offering: lifetime first ("BEST"), then yearly, monthly; "Start free trial" + the ironic banner when a package has a free trial; Restore; honest Test Store note in Debug. Gating (`ProFeatures`): free = 5 open trials + reminders + cancel steps; Pro = unlimited + final-day alarm (arms/disarms on change). Debug: Force Pro, Show paywall, preview the trial reminder. Simulator: lifetime Test Store purchase → Pro = yes. 2 new tests. ✅ Real-price products created and in the `default` offering (2026-09-28). **iPhone:** paywall shows $29.99 / "1 week free, then $24.99/yr" / $3.99; "Start 1 week free trial" + ironic banner; Test Store trial purchase → Pro = yes, and stays yes with Force Pro off. (A separate "Or try Pro free for 1 week" button was tried and removed at Dev A's request: the trial lives on the Yearly plan only.) Restore → "Restored. You're Pro."; the trial-ends-tomorrow notification arrives. ☐ Free-tier gating (6th trial → paywall) in the combined test.
- [x] **A9 README: "How RevenueCat is used"** + money-path architecture notes.
  *Status (2026-09-27):* on `a/a9-readme`: RevenueCat table (setup, offerings, `parachute_pro`, purchase/restore, gating, our-own-trial reminder), money-path Mermaid diagram + design notes, build/run, privacy. Screenshots and the full two-path diagram come with V2/B11.

### Dev B
- [ ] 🟡 **B10 Gating in Parachute.** "First step always free"; AI unfreeze + voice are Pro, via **A's `EntitlementsProviding`**. (Or 3/week if you chose that.)
  *Done when:* the free user sees Step 1, then an upsell; a Pro user gets everything.
- [x] **B11 README: Foundation Models / Unfreeze section** + the Mermaid architecture diagram.

### Both (afternoon)
- [ ] 🟡 **P1 Polish your own screens.** (Dev B: done in the simulator 2026-09-28; contrast, largest text, dark mode.) Dark Mode · Dynamic Type · VoiceOver labels · SF Symbols · smooth transitions.
  *Dev A status (2026-09-27, `a/p-polish-demo`):* Money list, Decide, and paywall checked in dark mode at the largest accessibility text size; Decide buttons stack icon over text at accessibility sizes; decorative icons hidden from VoiceOver; choice buttons read as one labelled button with a hint; trial rows get a hint plus an "Edit" VoiceOver action. ☐ Dev B's screens · ☐ app icon (logo later).
- [x] **P2 Demo data.** A seed button in debug with realistic items (only Apple-billed trials go to Apple's page, per CLAUDE.md rule 8).
  *Status (2026-09-27):* Debug → Demo data: Spotify (3 days), Duolingo via Apple (tomorrow), Claude, Google AI Pro, a cancelled Apple One; "Clear all trials" removes trials, reminders, and alarm chains. Checked in the simulator. **Fix (2026-09-28):** loading now replaces all trials and shows a confirmation; on the iPhone, repeated taps with no feedback had piled up 100 trials.
- [ ] **🧊 FEATURE FREEZE at end of Day 4.** Only bug fixes after this.

### 🔄 Sync 4
*Done when:* the full demo (`docs/demo-script.md`) runs **3× in a row on each phone without a crash**; raw screen recordings captured.

---

## Day 5: Ship (Wed Sep 30)

- [ ] **V1 Video** (A records the money segments, B records the unfreeze/task segments; one person edits). Under 2 minutes, captions, device frames. QuickTime is free.
- [ ] **V2 README final:** icon + 3 screenshots (1179×2556) · pitch · architecture · badges · RevenueCat section · build steps · privacy · MIT.
- [ ] **V3 Code sweep:** no secrets; **Test Store key only in Debug**; no dead code; tests green.
  *Dev A side done early (2026-09-27):* no keys or team ID in tracked files (only the `test_XXXX` placeholder); Release build's `RevenueCatAPIKey` is empty and the key isn't in the binary; A0 spike code removed (its App Intents were still registered in Release); all tests green (67). ☐ Re-run at the end with Dev B's code.
- [ ] **V4 Devpost:** description (what it does in the first line), video link, repo link, license visible. **The Representative submits by ~6pm PDT**, leaving hours of buffer before 11:45pm PDT.
  *Done when:* the submission is confirmed and someone who's never seen the app understands it from the video's first 15 seconds.

---

## If you fall behind: cut in this order
1. Audio companion (B9)
2. AI fallback for unknown services (part of B3), keeping curated + Apple
3. Task widget variant (part of B8)
4. Share extension (A7): manual add still demos everything
5. Task path (B4/B5): only if B0 failed

**Never cut:** alarm with Stop re-arming (A4) → Decide (A5) → Unfreeze player with curated steps (B1–B3) → scoreboard (B6) → paywall (A8). That chain *is* the video.

---

## Dependency map
```
S0.1 ─► S0.2 (contracts + fakes) ─┬─► A1 ─► A2 ─► A4 ─► A5 ─┐
                                   │    A3 (content) ──────────┤
                                   └─► B1 ─► B2 ─► B3 ─────────┼─► Sync 2 ─► A7 / B6–B9 ─► A8 / B10 ─► freeze ─► ship
                                        B0 ─► B4 ─► B5 (needs A2) ┘
```

## After the sprint (if you keep going)
Email forwarding pipeline (A) · returns + gift cards (A) · curated services 5 → 20 (A) · voice input "I'm stuck on…" (B) · the lock mode (A+B, needs $99) · App Store release.
