# PROJECT.md: Parachute

## What this is
Parachute is an iOS app, the ADHD follow-through engine. **Money path** (Dev A): catch free trials → escalate with reminders and a final-day alarm that keeps coming back until you decide → one tap to cancel. **Parachute path** (Dev B): when you freeze, on a cancellation or a deadline task, it walks you through one tiny step at a time. Every win lands on an "ADHD Tax Refunded" scoreboard. Built for the RevenueCat Shipaton 2026 Next Gen Award (video + open-source repo).

## Stack (pinned 2026-09-25)
- Xcode 27 / iOS 27 SDK / Swift 6.4; deployment target iOS 26
- SwiftUI + SwiftData (App Group)
- AlarmKit (stopIntent re-arm), Foundation Models (@Generable), Vision OCR, AVSpeechSynthesizer, AVAudioEngine
- RevenueCat purchases-ios 5.91.0 (Test Store in dev)
- Local packages: SharedKit (A+B) · MoneyKit (A) · ParachuteKit (B)

## Status
- ✅ Done: idea validation, competitor research, claim audit, merged plan, two-person milestones, contracts (`docs/interfaces.md`), video script
- 🔨 In progress (branch `a/phase0-setup`, Dev A):
  - **S0.1** scaffolded: `project.yml` (XcodeGen, generated project gitignored) with App + Widgets + ShareExtension, one App Group, iOS 26, Swift 6 mode; SharedKit / MoneyKit / ParachuteKit packages; RevenueCat 5.91.0 (in MoneyKit). Builds for simulator; built, signed (free team), installed over Wi-Fi and running on Dev A's iPhone (iOS 27.0).
  - **S0.2** drafted: every model + protocol from `docs/interfaces.md` compiles in SharedKit, fakes in `SharedKit/Fakes`, wired in `App/AppDependencies.swift`. ☐ Needs Dev B's review.
  - ✅ **A0 passed 11/11 on a free Apple ID** (2026-09-26): AlarmKit Stop re-arms (even after force-quit), Decide opens the app and ends the chain, rings on Silent; local notifications work; RevenueCat Test Store purchase grants `parachute_pro`. Details + A4 notes: `docs/a0-platform-spike.md`.
  - **A3** 4 of 5 services curated (Spotify, Claude, Google AI Pro, Apple One); see `docs/cancel-steps-verification.md`.
  - ✅ **A1** on `a/a1-money-deadlines` (stacked on `a/phase0-setup`): Money tab with countdowns, add/edit/delete; persistence verified in the simulator, running on Dev A's iPhone.
  - **A2** on `a/a2-reminders`: real `EscalationScheduler` with the reminder ladder + debug time travel. Real `EscalationScheduler` now replaces `FakeEscalationScheduler` in `AppDependencies`.
- ⏭️ Next (Dev A): finish A2 on the iPhone → finish A3 (service #5, URLs, iPhone Safari check). Open PRs to `main` so Dev B can build on SharedKit.

## How to run
1. `cp Config/Local.xcconfig.example Config/Local.xcconfig` and set your `DEVELOPMENT_TEAM` + a `BUNDLE_ID_PREFIX` unique to you (free Apple IDs can't share bundle IDs).
2. Optional (Test Store purchases): `cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig` and paste the RevenueCat Test Store key. Debug only.
3. `brew install xcodegen` (once), then `xcodegen generate`. Open `Parachute.xcodeproj`, pick your iPhone, Run. First run on a free account: Settings → General → VPN & Device Management → trust the certificate.
4. Tests: Product → Test, or `xcodebuild -project Parachute.xcodeproj -scheme Parachute -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`.
5. Changing targets, Info.plist keys, or entitlements: edit `project.yml`, then `xcodegen generate`. Adding files in `App/`, `Widgets/`, `ShareExtension/` also needs a regenerate; files inside a package don't.

## Decisions & why (newest first)
- 2026-09-26: **Reminders fire at 10:00 local**, 3 days and 1 day before the last day to act; past slots are skipped (a trial added the day before its charge relies on the A4 alarm). Debug "time travel" compresses 1 day into 1 minute. ⚠️ iOS reportedly keeps only the 64 soonest local notifications per app (not in Apple's docs page we checked); at 2 per trial that's fine for the sprint.
- 2026-09-26: **Apple-billed deadline = charge date minus 24 h.** Apple's subscribe sheet: *"Cancel anytime in Settings > Apple Account at least a day before each renewal date."* A2 reminders and the A4 alarm anchor to that for `billedByApple` items. Also: cancelling an Apple free trial can end access immediately, so no "keep it until the end" copy for Apple trials.
- 2026-09-26: **Curated services (4 of 5):** Spotify, Claude, Google AI Pro (Google One), Apple One (the Apple-billed one). Web ones followed to the final button on a Mac without tapping it; still need their page URLs + an iPhone Safari check. Log: `docs/cancel-steps-verification.md`.
- 2026-09-26: **RevenueCat project "Parachute"** (Dev A's personal account): Test Store products `lifetime`, `yearly`, `monthly` (auto-created) → entitlement **`parachute_pro`** ("Parachute Pro") → offering **`default`** (current, 3 packages). `EntitlementsProviding.isPro` checks `parachute_pro`. Prices set to the paywall plan in A8.
- 2026-09-25: **XcodeGen (`project.yml`) owns the project file**; the generated `Parachute.xcodeproj` is gitignored (same setup as Speakeasy/KindlyCall), so there are never project-file merge conflicts. Everyone runs `xcodegen generate` after cloning or pulling a `project.yml` change.
- 2026-09-25: **Per-dev signing via `Config/Local.xcconfig`** (gitignored): team ID + bundle prefix. The App Group is `group.<prefix>.parachute` and reaches code via the `ParachuteAppGroup` Info.plist key (`SharedKit.AppGroup`).
- 2026-09-25: **RevenueCat lives in MoneyKit's `Package.swift`** (`purchases-ios-spm`, exact 5.91.0), not the app target. The key comes from gitignored `Config/Secrets.xcconfig` into Debug's Info.plist only; Release sets it empty and `RevenueCatBootstrap` configures only `#if DEBUG`.
- 2026-09-25: **App Intents can live in packages.** Alarm intents are in MoneyKit and exported with `MoneyKitIntentsPackage`; verified in the app's `Metadata.appintents`.
- 2026-09-25: **AlarmKit Stop button:** `Alert(title:stopButton:…)` is deprecated in iOS 26.1 (Stop is system-provided), so we call the new initializer behind `#available(iOS 26.1, *)` and keep the deployment target at 26.0.
- 2026-09-25: **Dev A is the Devpost Representative** and submits with a student email (✅ Next Gen requires *"a qualifying student or academic email address on Devpost"*). Repo: https://github.com/yasaausman/parachute (public, MIT detected); commits use the GitHub no-reply address.
- 2026-09-25: **Name = Parachute** (App Store has other apps named "Parachute" (plasma, backup, etc.); fine for a no-store-release submission; if publishing later, use a full title like "Parachute: Beat the ADHD Tax").
- 2026-09-25: **Two devs.** A = Money ("Untax") path + paywall; B = Parachute (unfreeze, tasks, scoreboard, widgets). Split by local Swift packages so they rarely touch the same files.
- 2026-09-25: **Lead with Unfreeze.** Clawback (released Sep 24) has a near-identical money pitch; Nudgy has the Stop-only-postpones alarm. The unique part is curated unfreeze steps + the task path.
- 2026-09-25: **No server, no accounts, no API keys in the sprint.** The public repo would leak keys; a free Apple ID can't do Push or Sign in with Apple anyway.
- 2026-09-25: **Alarm = Stop + "Decide."** AlarmKit allows only Stop + 1 button; `stopIntent` re-arms until a decision.
- 2026-09-25: **Free trials only in the sprint**; returns, gift cards, bills, and the email pipeline come later.
- 2026-09-25: **$29.99 lifetime headline**; "first step always free."
- 2026-09-25: Friction's app lock parked (needs the $99 Program + iOS 26.5). Syllabus parser dropped (crowded).

## Open questions / blockers
- Sep 30 sprint or longer? (`MILESTONES.md` assumes Sep 30.)
- Free Apple ID or $99 Program?
- Which 5 services to curate? (Need real accounts; include one Apple-billed trial.)
- Free unfreeze limit: breadth-gated (recommended) or 3/week?
- Does Dev B also have a student/academic email for joining the Devpost team? Anyone under 18 (guardian consent)? ⚠️ Confirm on the Shipaton Discord that every team member must be a student for Next Gen.

## Milestone checklist (details + owners in MILESTONES.md)
- [ ] Phase 0: S0.1 project ✅ (Dev A side) · S0.2 contracts + fakes (needs B's review) · S0.3 decisions (partly) · A0 platform spike ✅ · B0 atomizer spike (Dev B)
- [ ] Day 1: A1 manual deadlines ✅ · A2 reminders (built, device check) · A3 curate 5 services (4/5) · B1 Unfreeze player · B2 CancelSteps loader · 🔄 Sync 1
- [ ] Day 2: A4 alarm · A5 Decide · A6 Apple path · B3 UnfreezeEngine · B4 task path · B5 task reminders · 🔄 Sync 2 (full money flow)
- [ ] Day 3: A7 share extension · B6 scoreboard · B7 celebration/share · B8 widgets · B9 audio · 🔄 Sync 3
- [ ] Day 4: A8 paywall · A9 README (RevenueCat) · B10 gating · B11 README (FM) · P1 polish · P2 demo data · 🧊 freeze · 🔄 Sync 4
- [ ] Day 5: V1 video · V2 README · V3 code sweep · V4 Devpost submit
