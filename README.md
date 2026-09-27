# 🪂 Parachute

**The ADHD follow-through engine.** Parachute catches the money deadlines your brain loses, nudges until you act, and when you freeze, on a cancellation or an essay, walks you through one tiny step at a time. **Pull the cord.**

> 79% of Americans have started a free trial meaning to cancel, and got charged anyway ([Dimers, 2026](https://www.dimers.com/press/news/how-far-americans-will-go-for-freebies)). For ADHD brains the problem isn't remembering. It's **starting**.

_Status: in development for the [RevenueCat Shipaton 2026](https://revenuecat-shipaton-2026.devpost.com/) Next Gen Award. This README is replaced with the full submission version (screenshots, architecture diagram, "How RevenueCat is used") on Day 4–5; see `MILESTONES.md`._

## How it works
1. **Catch:** share a screenshot of a trial confirmation; on-device AI finds the service, price, and end date.
2. **Nudge:** widget countdown → reminders → a final-day alarm that keeps coming back until you decide.
3. **Decide:** Cancel · Keep · Snooze · 🧊 **I'm frozen**
4. **Unfreeze:** one tiny, exact step at a time ("Step 1: Open Settings. That's it.") for cancellations *and* deadline tasks.
5. **Reward:** every win goes on the **ADHD Tax Refunded** scoreboard.

## Built with
SwiftUI · SwiftData · AlarmKit · Apple Foundation Models (on-device) · Vision · AVSpeechSynthesizer + AVAudioEngine · WidgetKit · RevenueCat

## Repo guide
- `PLAN.md`: product, research, verdict, architecture
- `MILESTONES.md`: who builds what, day by day
- `PROJECT.md`: current status
- `docs/interfaces.md`: contracts between the Money and Parachute modules
- `docs/readme-dev-b.md`: how the Unfreeze engine and on-device atomizer work (+ architecture diagram)
- `docs/b0-atomizer-spike.md`: the on-device AI test plan and results

## Build
1. `cp Config/Local.xcconfig.example Config/Local.xcconfig` and set your team ID + bundle prefix.
2. `brew install xcodegen && xcodegen generate`, then open `Parachute.xcodeproj` (Xcode 27) and run.
3. Tests: `xcodebuild -project Parachute.xcodeproj -scheme Parachute -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
- `research/`: background evidence

## License
MIT; see `LICENSE`.
