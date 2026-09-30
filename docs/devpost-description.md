# Devpost description (final draft, 2026-09-30)

Paste each section into the matching Devpost field. Everything below the line is submission text; keep this note out of it.
Before submitting: add the video link, and delete the "What's next" line you won't stand behind. Stats: only CLAUDE.md rule 11.
Written to be read fast by human judges and parsed cleanly by any AI screening: what it does in the first sentence, one heading per judging criterion, concrete checkable facts, no filler. (Shipaton's published judging process is human; see shipaton.com/blog/how-we-judge-shipaton.)

---

## Tagline (one line)
Untax catches your free trials before they charge you, and when ADHD freezes you, walks you out one tiny step at a time.

## Inspiration
79% of Americans have started a free trial meaning to cancel and got charged anyway. For the 15.5 million US adults with ADHD (CDC), the problem usually isn't remembering. It's starting. A reminder you can swipe away doesn't fix that. We call the money lost this way the "ADHD tax", and we built Untax to refund it.

## What it does
Untax is an iOS app with one job: get you from "I should cancel that" to done.

1. **Catch.** Share a screenshot of any trial confirmation to Untax. It reads the service, price and charge date on-device and asks "Track it?" One tap saves it. You can also add a trial by hand.
2. **Nudge.** A Home Screen widget counts down, reminders arrive 3 days and 1 day out, and on the last day an AlarmKit alarm rings, even on Silent. Stop doesn't end it: the alarm comes back 30 minutes later until you decide.
3. **Decide.** One screen, four answers: Cancel it · Keep it · Snooze · **Get unstuck**.
4. **Get unstuck.** For the moment ADHD freezes you, Untax shows one exact step at a time ("Open Settings. That's it."), with a 90-second timer, optional voice, and "Break it smaller" when a step is still too big. It works for cancellations (hand-verified steps per service, Apple's own path for App Store trials) and for any task, like an essay due at midnight.
5. **Refund.** Every win lands on the **ADHD Tax Refunded** receipt: dollars kept, tasks unfrozen, and your best run. There is no streak to lose and no shame copy anywhere in the app.

## How it meets the judging criteria

**1. A clear, useful, original idea.** Trial trackers remind you; task apps list your tasks. Neither helps with the part ADHD makes hard: starting. Untax joins the two. The same "Get unstuck" engine handles a cancellation and a homework deadline, and an alarm that only a decision can end.

**2. Meaningful progress toward a working app.** Untax runs end to end on a real iPhone, not as a prototype:
- The final-day alarm rang through Silent mode and re-armed after Stop, even after the app was force-quit.
- A real subscription screenshot was read and tracked through the share sheet.
- A RevenueCat Test Store purchase unlocked Pro.
- 112 automated tests (72 Swift Testing + 40 XCTest) cover date math, the escalation schedule, alarm re-arming, cancel-step data and AI output validation. All pass.
- Cancel steps for 4 services (Spotify, Claude, Google AI Pro, Apple One) were checked by hand on real accounts and logged in the repo.

**3. Thoughtful use of RevenueCat.** RevenueCat (purchases-ios 5.91.0) powers every purchase and decides what Pro unlocks:
- The paywall renders the **current offering** with localized prices, so plans and prices change from the dashboard, not an app update.
- One entitlement drives all gating, through `customerInfoStream`, so Pro unlocks the moment a purchase, restore or renewal lands.
- Free keeps reminders, hand-checked cancel steps, 5 trials and the first unfreeze step. Pro adds the final-day alarm, unlimited trials and step-by-step help for anything.
- The headline plan is **$29.99 lifetime** ("no trial to forget"), with $24.99/year and $3.99/month.
- An app about forgotten trials shouldn't be one: if you start Untax's own trial, it reminds you 24 hours before it ends, using the entitlement's expiration date.

**4. Thoughtful technical and product choices.**
- **Private by design.** No account, no server, no analytics. Screenshot reading and task steps use Apple's on-device Vision and Foundation Models.
- **AI that can't invent facts.** The model may only pick prices and dates actually printed in the screenshot; anything else is dropped. AI-written steps never contain links and are labelled "Suggested steps". Every AI path has a non-AI fallback, so the app works on phones without Apple Intelligence.
- **Built for ADHD.** One decision per screen, WCAG AA contrast in light and dark mode, Dynamic Type and VoiceOver labels.

## How we built it
Swift 6 and SwiftUI with SwiftData in an App Group, shared by the app, widgets and share extension. Two developers built in parallel through three local Swift packages: `MoneyKit` (capture, escalation, AlarmKit alarm, Decide, paywall), `ParachuteKit` (unfreeze engine, on-device AI step writer, audio, scoreboard, widgets) and `SharedKit` (models, protocols, design system). The app target only wires them together through protocols.

## Challenges
- **AlarmKit won't allow an alarm you can't dismiss.** It gives one Stop button plus one custom button, and Stop always works. So Stop runs an App Intent that schedules the next ring 30 minutes later, and only a recorded decision ends the chain.
- **Apple bills trials a day early.** Apple asks for cancellation at least a day before renewal, so App Store trials count down to the day before the charge.
- **The on-device model doesn't run in the simulator.** We built and tested every non-AI fallback first, then validated AI output against a strict schema.

## Accomplishments we're proud of
A working alarm chain that respects Apple's rules and still can't be ignored; screenshot capture that never makes up a price; and an app a person with ADHD can use without being made to feel bad. Open source under MIT.

## What we learned
Escalation only works if there's an easy way to answer it. The "Get unstuck" button mattered more than the alarm.

## What's next
More hand-verified cancel guides, Live Activities for a trial's final hours, and shared "accountability" trials with a friend.

## Built with
swift · swiftui · swiftdata · alarmkit · foundation-models · vision · widgetkit · avfoundation · revenuecat · xcodegen

## Try it
Public repo with build steps: https://github.com/yasaausman/parachute (MIT license). Alarms need a real iPhone on iOS 26+; the simulator runs everything else with non-AI fallback steps.

## Video
⚠️ Add the YouTube link after upload.

---

## Image gallery (upload in this order, add the caption)
1. `docs/brand/untax-icon-1024.png`: "Untax: get your ADHD tax back."
2. `docs/screenshots/01-home.png`: "Home: the next charge counts down, and your refunded total counts up."
3. `docs/screenshots/02-track-trial.png`: "Share a trial screenshot. Untax reads it on-device."
4. `docs/screenshots/03-decide.png`: "One decision: Cancel, Keep, Snooze, or Get unstuck."
5. `docs/screenshots/04-unstuck.png`: "Frozen? One tiny step at a time."
6. `docs/screenshots/05-refunded.png`: "Every win lands on the ADHD Tax Refunded receipt."

Screenshots use demo data.
