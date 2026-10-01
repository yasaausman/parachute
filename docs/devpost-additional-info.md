# Devpost "Additional info" answers (2026-09-30)

These answers are for the judges and organizers. Fields marked "leave blank" are for awards we aren't entering.

## Checkboxes and dropdowns
- **1024 × 1024 uncropped app icon attached?** Yes. Attach `docs/brand/untax-icon-1024.png` (1024 × 1024, no transparency).
- **Screenshot WITHOUT device frames attached?** Yes. `docs/screenshots/01–05` are raw simulator captures with no frames.
- **First version released on a store between Aug 1 and Sep 30, 2026?** No. Next Gen doesn't require a store release.
- **RevenueCat or sponsor employee?** No.
- **Type of app:** iOS (iPhone and/or iPad).
- **App Store / Google Play / Galaxy Store URLs:** leave blank.
- **(Next Gen) repo URL:** https://github.com/yasaausman/untax
- **(Next Gen) student email:** already filled in.
- **(Next Gen) minor entrant confirmation:** tick it, unless a team member is under 18. If one is, a parent must complete the consent form first.
- **RevenueCat project ID:** already filled in (`proj4b1d7676`).
- **Promo code:** leave blank. The app isn't on the App Store, and purchases run on RevenueCat's Test Store. The video shows the paywall and a test purchase instead.
- **Grand Prize, Build in Public, Catvertising, Best Game, Ship Kotlin Everywhere, Most Viral, Galaxy, Idea to Income, Keep Them Coming Back, Growth Loop, Funnel Vision:** leave blank. These need things we didn't build (a store launch, ads, Kotlin, Noise, Replit, OneSignal, Layers or Stripe).
- **Growth Fund interest:** your call.

---

## HAMM Award: monetization model
Untax makes money from one Pro unlock, sold through RevenueCat. Every plan grants the same `parachute_pro` entitlement.

- **Free:** reminders, hand-checked cancel steps, up to 5 tracked trials, and the first "Get unstuck" step of any task, always.
- **Pro:** the final-day alarm that keeps coming back until you decide, unlimited trials, and step-by-step help for any service or task (AI steps and voice).
- **Pricing:**
  - **$29.99 lifetime** is the headline plan.
  - **$24.99/year** comes with a 1-week free trial.
  - **$3.99/month** has no trial.

**Why this model:** our users are people who lose money to forgotten subscriptions. Asking them for one more subscription would repeat the problem we're solving. So lifetime leads, and the paywall says it plainly: "We'd never charge a subscription to fix your follow-through. Lifetime is one payment: no trial to forget." The yearly plan is the only one with a trial, and Untax schedules a reminder 24 hours before that trial ends, so we don't charge anyone for forgetting.

**How the paywall works:** it appears at real value moments: tracking a 6th trial, or wanting the next unfreeze step after the free first one. It renders RevenueCat's current offering with localized prices, so pricing can change from the dashboard without an app update. It includes restore, and every result is a plain message ("Nothing was charged").

**Results:** none yet. The app isn't on the App Store, and purchases are Test Store only. A test purchase on a real iPhone unlocked Pro end to end.

## RevenueCat Peace Prize: benefit to people and society
About 15.5 million US adults have ADHD (CDC). For many of them, the costly part isn't forgetting. It's being unable to start, even when they know exactly what to do. 79% of Americans have started a free trial meaning to cancel and got charged anyway. People with ADHD pay this "ADHD tax" over and over, in money, missed deadlines and shame.

Untax is designed to help without adding to that shame:
- **No-shame design.** There are no streaks to lose, only a "best run". There is no red failure state. Copy like "Frozen? Totally normal" replaces "You still haven't done this."
- **Free where it matters.** Reminders, hand-checked cancel steps and the first step of any task are free, forever.
- **Private.** No account, no server, no analytics. Screenshots and tasks are processed on the phone.
- **Accessible.** WCAG AA contrast in light and dark mode, Dynamic Type and VoiceOver labels.
- **Open source** under MIT, so anyone can audit the code, reuse it or build on it.

## RevenueCat Design Award: distinctive design
- **The receipt.** The "ADHD Tax Refunded" scoreboard is a thermal receipt. It has mono line items, a dashed divider, a big green TOTAL and a torn bottom edge. The share card reuses it on a coral background. The app icon is the same idea: a receipt with a refund arrow around a dollar sign.
- **The next-charge ticket.** Home opens with one coral ticket. In the last 24 hours its countdown becomes a live HH:MM:SS clock, and one tap opens Decide.
- **One decision per screen.** Decide asks one bold question ("Duolingo bills you tomorrow."), shows the amount large, and offers Cancel it, Keep it, Snooze and Get unstuck.
- **The unfreeze player.** Each screen shows one step in large type, with a 90-second ring, "Break it smaller" and a calm teal palette. Finishing a task triggers confetti and haptics. All motion respects Reduce Motion.
- **A small, consistent system.** One coral accent on warm paper. Green only ever means money back, and teal only ever means Unfreeze. Headlines use SF Rounded heavy and amounts use mono. Every text color passes WCAG AA. Brand guide: `docs/brand/BRAND.md`.

## Influencer Award: Productivity (Christopher Lawley)
Untax is a productivity app for people that productivity apps fail. Most tools assume that once a task is captured, you can start it. Untax handles the step after capture:
- **Starting.** "Get unstuck" breaks any task, like an essay or a form, into one tiny step at a time, using Apple's on-device model.
- **Following through on money.** Trials are captured from a screenshot and escalate to an alarm only a decision can end.
- **It's built on current Apple frameworks:** AlarmKit, Foundation Models, App Intents, widgets and the share sheet. Everything stays on the phone.

## Additional notes for the judges
- **Recommended path:** the video, then the README's "For judges: criteria → evidence" table. It links every claim to the code, tests or dated device logs that back it: https://github.com/yasaausman/untax#for-judges-criteria--evidence
- **Testing it yourself:** the app runs from source. Alarms need a real iPhone on iOS 26 or later. The simulator runs everything else, using non-AI fallback steps.
- **Demo data:** the screenshots and video use demo data. Load it in a Debug build from Home → 🐞 → "Reset & seed demo data".
- **Test Store:** purchases use RevenueCat's Test Store and charge nothing.
- **Team:** two student developers, a money/capture lead and an unfreeze lead, building in parallel through local Swift packages.
