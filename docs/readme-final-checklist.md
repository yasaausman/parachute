# README final checklist (V2/V3), 2026-09-29

## Fix in `README.md`
- [x] Replace the "_Status: in development…_" line with the real one-line status.
- [x] The file has **two build sections** ("Build and run" and "Build"). Delete the short "Build" one.
- [x] Add the app icon at the top (Untax icon, `docs/brand/untax-icon-1024.png`, 2026-09-29).
- [x] Added 5 screenshots (`docs/screenshots/`, 1206×2622) and removed the "Screenshots … land with the final submission" line (2026-09-30).
- [x] Add badges: Swift, iOS 26+, MIT, RevenueCat.
- [x] Add a "Parachute (unfreeze) architecture" pointer to `docs/readme-dev-b.md`, or paste its diagram.
- [ ] Add a video link (after upload). ✅ "Try it" note added.
  - was: Add a video link and a "Try it" note: AlarmKit needs a real iPhone; the simulator has no Apple Intelligence.
- [x] Confirm every number is from CLAUDE.md rule 11 (checked 2026-09-30). Never "$1,900/yr", "$15–20k/yr", "thousands a year" or "48%".

## Screenshots ✅ done 2026-09-30: `docs/screenshots/01–05` (1206×2622). Paywall still to capture on the phone.
- [x] 1. **Home / money list**: 2–3 trials with day counts, one urgent, plus widget if possible.
- [x] 2. **Decide** screen with a trial, showing Cancel · Keep · Snooze · Get unstuck.
- [x] 3. **Unfreeze player**: one step, ring, Done / Break it smaller / Skip.
- [x] 4. (bonus) **ADHD Tax Refunded** ($214.89 · 12 tasks · 5-day best run) and the paywall.
- Capture with `xcrun simctl io booted screenshot` and check the pixel size.

## Code sweep (V3)
- [ ] `git grep -nE 'appl_|sk_|goog_|test_[A-Za-z0-9]{20}'` finds no keys; `Config/Secrets.xcconfig` is gitignored.
- [ ] RevenueCat Test Store key is read only in Debug (`RevenueCatBootstrap.swift`); build Release once to confirm it doesn't crash.
- [ ] No dead code or leftover debug UI in the shipped path (ladybug/seed is Debug-only or clearly labelled).
- [ ] `git grep -n 'TODO\|FIXME'` reviewed.
- [ ] All tests green (`xcodebuild … test`), including `CancelSteps.json` validity.
- [ ] `LICENSE` is visible on the repo's front page; the repo is public.

## Before recording / submitting
- [ ] Tick the real-iPhone boxes in `MILESTONES.md` honestly; leave unticked what wasn't run.
- [ ] Fill the ⚠️ items in `docs/devpost-description.md`.
- [ ] Both members have a student/academic email on Devpost. Representative submits by ~6pm PDT.
