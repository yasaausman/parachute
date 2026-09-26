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
- 🔨 In progress: nothing yet
- ⏭️ Next: **Phase 0** in `MILESTONES.md`: S0.1 repo + Xcode project (together), then A0 platform spike (Dev A) and B0 atomizer spike (Dev B)

## How to run
Not yet: the Xcode project is created in Phase 0 (S0.1). Then: open `Parachute.xcodeproj`, select your iPhone, Run. Tests: Product → Test (or `xcodebuild test` once schemes exist).

## Decisions & why (newest first)
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
- Who is the Devpost Representative? Do **both** have student/academic emails? Anyone under 18 (guardian consent)? ⚠️ Confirm on the Shipaton Discord that every team member must be a student for Next Gen.

## Milestone checklist (details + owners in MILESTONES.md)
- [ ] Phase 0: S0.1 project · S0.2 contracts + fakes · S0.3 decisions · A0 platform spike · B0 atomizer spike
- [ ] Day 1: A1 manual deadlines · A2 reminders · A3 curate 5 services · B1 Unfreeze player · B2 CancelSteps loader · 🔄 Sync 1
- [ ] Day 2: A4 alarm · A5 Decide · A6 Apple path · B3 UnfreezeEngine · B4 task path · B5 task reminders · 🔄 Sync 2 (full money flow)
- [ ] Day 3: A7 share extension · B6 scoreboard · B7 celebration/share · B8 widgets · B9 audio · 🔄 Sync 3
- [ ] Day 4: A8 paywall · A9 README (RevenueCat) · B10 gating · B11 README (FM) · P1 polish · P2 demo data · 🧊 freeze · 🔄 Sync 4
- [ ] Day 5: V1 video · V2 README · V3 code sweep · V4 Devpost submit
