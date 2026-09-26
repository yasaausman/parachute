# CLAUDE.md: Parachute

Read this first in every session. Then read `PROJECT.md` (living state) and `MILESTONES.md` (who does what).

## What this is
**Parachute**: an iOS app, the ADHD follow-through engine. It catches money deadlines (free trials) and escalates until you act. When you freeze, on a cancellation or a deadline task, it walks you through one tiny step at a time and puts every win on an "ADHD Tax Refunded" scoreboard.
Built for **RevenueCat Shipaton 2026, Next Gen Award** (students). Full plan: `PLAN.md`.

## Team & ownership
- **Dev A (Money / "Untax" lead):** `Packages/MoneyKit`: capture (manual + share extension), extraction, escalation, AlarmKit alarm, Decide screen, curated `CancelSteps.json` content, RevenueCat paywall + entitlements.
- **Dev B (Parachute lead):** `Packages/ParachuteKit` + `Widgets` target: Unfreeze engine and player, AI atomizer, task path, audio companion, scoreboard + celebration, widgets.
- **Both:** `Packages/SharedKit` (models, protocols, design system). Changes to SharedKit need the other person's review.
- Ask which dev you're working with at the start of a session if it isn't obvious, and stay inside that dev's area unless asked.

## Hard rules (verified; don't re-derive, don't contradict)
1. **Primary sources for load-bearing facts.** API limits, platform capabilities, rules, prices: check the official source (Apple docs, RevenueCat docs, the Shipaton rules) and quote it. Apple docs are readable as JSON: `https://developer.apple.com/tutorials/data/documentation/<path>.json`. Mark anything unverified as ⚠️.
2. **AlarmKit (iOS 26+):** an alert has a **Stop button + ONE secondary button**, and Stop is always available. You CANNOT build a 3-button alarm or an undismissable one. Our design: `stopIntent` **re-arms** the alarm (≈30 min later) until a decision is recorded; the secondary button **"Decide"** opens the app's Decide screen (Cancel · Keep · Snooze-until · I'm frozen). Alarms break through Silent mode and Focus.
3. **Foundation Models (iOS 26+)** runs on-device and needs an Apple Intelligence-capable device. Always have a non-AI fallback (manual entry / curated steps).
4. **No API keys in the app, ever.** The repo is public and open source. No Anthropic/Claude key in the client. Server AI is out of the sprint.
5. **RevenueCat Test Store key is dev-only.** Never in a Release build (the SDK crashes release builds with it on purpose). purchases-ios pinned at **5.91.0** (Test Store needs ≥ 5.43.0).
6. **Free Apple ID limits** (Apple capabilities table): App Groups ✅; Push Notifications ❌, Sign in with Apple ❌, In-App Purchase ❌, Time Sensitive Notifications ❌. No accounts, no push, no server in the sprint.
7. **Live Activities** last ≤ 8h (+ ≤ 4h on the Lock Screen), so use **widgets** for multi-day countdowns.
8. **"Cancel via Apple's subscription settings" only works for trials billed by Apple.** Web signups need that service's own curated steps.
9. **Curated cancel steps must be hand-verified** on real accounts and logged in `docs/cancel-steps-verification.md`. Never invent a URL. AI-generated steps are labeled "Suggested steps."
10. **ADHD-first copy:** no shame, no guilt. Streaks show a "best run," never "you lost your streak." The first unfreeze step is always free.
11. **Stats allowed on screen/in the video:** 79% of Americans started a trial meaning to cancel and got charged; $45/month on forgotten trials (Dimers, Sep 2026); 15.5M US adults with ADHD (CDC). **Never** "$1,900/yr", "$15–20k/yr", "thousands a year", or "48%".

## Stack
Swift 6.4 (strict concurrency) · SwiftUI · SwiftData in an App Group · Xcode 27 / iOS 27 SDK · **deployment target iOS 26** · AlarmKit · Foundation Models (`@Generable`) · Vision OCR · AVSpeechSynthesizer + AVAudioEngine · RevenueCat purchases-ios 5.91.0.

## Conventions
- Local Swift packages keep ownership clean: the app target is a thin composition root that injects protocol implementations (`EscalationScheduling`, `UnfreezeProviding`, `EntitlementsProviding`, `CompletionLedger`). Contracts: `docs/interfaces.md`.
- Tests for: date math, escalation schedule, alarm re-arm, `CancelSteps.json` validity, atomizer output schema.
- Small branches (`a/<feature>`, `b/<feature>`), daily merges at the sync points in `MILESTONES.md`.
- After each chunk of work: update `PROJECT.md` (status + decisions) and tick boxes in `MILESTONES.md`.

## Submission (Next Gen)
Demo video under 2 min + public repo with a license file (MIT, in `LICENSE`). No store release, no paid dev account, no judge promo code required. The RevenueCat SDK must power ≥ 1 purchase. **Deadline: Wed Sep 30, 2026, 11:45pm PDT.** Script: `docs/demo-script.md`.
