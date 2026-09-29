# Devpost description (draft, 2026-09-29)

Fill the ⚠️ items only with what was verified on a real iPhone before submitting. Stats: only those in CLAUDE.md rule 11.

## Tagline
Parachute is the ADHD follow-through engine: it catches your free-trial deadlines, keeps coming back until you decide, and when you freeze, walks you through one tiny step at a time.

## Inspiration
79% of Americans have started a free trial meaning to cancel and got charged anyway. For people with ADHD (15.5M US adults, per the CDC) the problem usually isn't remembering. It's starting. A reminder you swipe away doesn't fix that. We wanted an app that stays with you through the hard part, and counts every win instead of every miss.

## What it does
- **Catch:** share a screenshot of a trial confirmation. On-device OCR and extraction find the service, price and last day to cancel. You confirm it in one tap, or add it by hand.
- **Nudge:** a widget countdown, reminders 3 days and 1 day out, and a final-day AlarmKit alarm. Stop only snoozes it: the alarm re-arms about 30 minutes later until you record a decision.
- **Decide:** Cancel · Keep · Snooze · 🧊 I'm frozen.
- **Unfreeze:** one exact step at a time ("Step 1: Open Settings. That's it."), with a soft 90-second ring, an optional voice and ambient sound, and "Break it smaller" if a step is still too big. It works for cancellations (hand-verified steps for real services, plus Apple's own path for Apple-billed trials) and for deadline tasks like an essay due at midnight.
- **Reward:** every win lands on the **ADHD Tax Refunded** scoreboard: dollars back, tasks unfrozen, and a best run (never "you lost your streak").

## How we built it
SwiftUI and SwiftData in an App Group, split into local Swift packages so the two of us could build in parallel: `MoneyKit` (capture, escalation, AlarmKit, Decide, paywall), `ParachuteKit` (unfreeze engine and player, atomizer, audio, scoreboard, widgets) and `SharedKit` (models, protocols, design system). The app target only wires them together through protocols. Apple's on-device Foundation Models (`@Generable`) atomize tasks and help read screenshots, always with a non-AI fallback. Anything the model returns that isn't printed in the screenshot is dropped, and AI-written steps never contain URLs and are labelled "Suggested steps."

**RevenueCat** powers every purchase (purchases-ios 5.91.0): the paywall renders the current offering with localized prices, one `parachute_pro` entitlement drives all gating through `customerInfoStream`, restore is built in, and the app schedules a reminder 24 hours before its own trial ends. Pro is **$29.99 lifetime** (headline), $24.99/yr or $3.99/mo. The first unfreeze step is always free.

## Challenges
- AlarmKit gives you a Stop button and one secondary button, and Stop can't be disabled, so an "undismissable" alarm is impossible. We made Stop re-arm the alarm through an App Intent instead, so only a decision ends the chain.
- Apple bills trials a day earlier than the visible date, so Apple-billed reminders count down to the day before the charge.
- Foundation Models can't run in the simulator, so we built and tested the fallbacks first. ⚠️ Add what happened on an Apple Intelligence iPhone once B0 has run.
- Contrast: the system cyan, green and orange are about 2:1 on white, so we added WCAG AA text and fill tokens and checked light, dark and largest text.

## Accomplishments
No account, no server, no analytics: everything stays on the phone. Fully open source under MIT. ⚠️ Add the test counts, the number of hand-verified services, and the real-device results once confirmed.

## What we learned
Escalation only works if there's a way to answer it. The "I'm frozen" button turned out to matter more than the alarm.

## What's next
More hand-verified cancel guides, Live Activities for the final hours, and shared "accountability" trials with a friend. ⚠️ Keep only what we're willing to stand behind.

## Built with
Swift · SwiftUI · SwiftData · AlarmKit · Foundation Models · Vision · WidgetKit · AVFoundation · RevenueCat

## Links
Video: ⚠️ · Repo: ⚠️ (public, MIT license in `LICENSE`)
