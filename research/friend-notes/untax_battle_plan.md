# 🏆 UNTAX BATTLE PLAN — How to Win Next Gen

> Synthesized from: Shipaton 2025 winner analysis, ADHD community research (Reddit, ADDitude, forums), hackathon demo video strategy, judge-specific preferences, and competitive scouting.

---

## TL;DR — The 5 Things That Win This

Based on every 2025 winner and every judge preference we found:

1. **An emotionally devastating 2-minute video** (it's 90% of your score — judges can't download your app)
2. **A pristine open-source repo** that looks like it was built by someone who cares about craft
3. **The follow-through mechanic as your killer feature** — no competitor has this
4. **The meta-paywall moment** ("we remind you before OUR trial ends") — judges will remember this
5. **ADHD community language** that signals you deeply understand the user, not just the tech

---

## 1. What Won in 2025 — And What It Means for You

### Grand Prize: Payout (Connor Burd) — $100k
- Vibe-coded the entire app in **10–14 days** with Cursor + Claude Code
- Won on **traction**: 17,000 users, $30k revenue, 1,750 paying subscribers *during the hackathon*
- Hard paywall right after onboarding — "if they won't pay at peak excitement, your value prop isn't strong enough"
- **Lesson for you:** Grand Prize is about traction/revenue. **You're in Next Gen, which is about the best student-built app.** You don't need 17k users. You need a jaw-dropping video + immaculate code.

### #BuildInPublic: Gurwi (Camilo Peñalver Gomez) — $15k
- Won through **raw, vulnerable storytelling** about building from Colombia
- 200k+ view launch video before the app even shipped
- **Lesson:** Emotional narrative > feature list. Your ADHD story has this potential.

### Peace Prize: Heartbeat Hero (Aiden Forrest) — $15k
- **A student** (Apple Swift Student Challenge winner)
- Used ARKit + IMU sensors for real-time CPR depth measurement
- Won on **technical audacity + humanitarian impact**
- **Lesson:** This is your direct comp for Next Gen. Heartbeat Hero = student + technically impressive + real-world impact. Untax needs the same formula.

### Design Award: Dayloop
- Won on **micro-interactions, haptics, 60fps animations**
- **Lesson:** Charlie Chapman (judge) loves this. Your widget countdowns and celebration animations need to be *butter*.

### Key Pattern Across All Winners:
> **Single-player utility that solves a high-value problem immediately.** No social features, no network effects needed. Payout finds money. Heartbeat Hero saves lives. Untax saves money.

---

## 2. Your Direct Competitor: Duefolio

A Shipaton 2026 entrant building a "privacy-first subscription tracker" — already featured on MacStories and Lifehacker.

| Dimension | Duefolio | Untax |
|---|---|---|
| Capture | ❌ 100% manual entry | ✅ Auto email forwarding + share sheet OCR |
| Reminders | ❌ Standard push (swipeable) | ✅ Escalation ladder → AlarmKit alarm |
| Follow-through | ❌ None — shows a timeline, leaves you stranded | ✅ One-tap cancel deep links |
| Emotional reward | ❌ Passive | ✅ Money-saved counter + celebration |
| Paywall story | ❌ Standard | ✅ "We remind you before OUR trial ends" |

**Your positioning (say this in the video):**
> "Every app shows you the deadline. Untax makes sure you actually beat it."

---

## 3. The ADHD Goldmine — Language & Hooks for the Video

### Community concepts to weave into the video:

| Concept | What It Is | How to Use It |
|---|---|---|
| **"The Wall of Awful"** | Brendan Mahan's framework — task initiation blocked by accumulated shame from past failures | *"When you see the reminder, you don't see a 2-minute task. You see every deadline you've ever missed."* |
| **"Notification Glaze"** | Reflexively swiping away an alert without the brain processing it | *Show* this in the video — a notification arriving, getting swiped, and the charge hitting |
| **"Trunk of Shame"** | Returns sitting in the car trunk until the window expires | Visual hook opportunity if you film a real trunk |
| **"Out of Sight, Out of Existence"** | If it's not screaming in your face at the right moment, it doesn't exist | This is WHY AlarmKit matters — show the full-screen alarm |
| **"The Ostrich Effect"** | Avoiding bank apps because you know money is leaking | Sets up the money-saved counter as the antidote |

### Video hook options (pick one):

1. **"The biggest lie in the universe is an ADHD person saying: 'I'll just cancel it before it charges me.'"**
2. **"The average person with ADHD loses $1,900 a year to something called the ADHD Tax. Here's where yours is going."**
3. **"Regular people set a reminder and do it. I set a reminder, look at it, think 'give me two seconds,' swipe it away, and it ceases to exist."**

> [!TIP]
> Hook #3 is the strongest — it's viscerally relatable, it immediately signals you understand the user's brain, and it sets up the entire product thesis (reminders aren't enough → follow-through is the product).

---

## 4. Feature Upgrades Based on Research

### Changes to your current plan:

#### A. Rename "Money Saved" → "ADHD Tax Refunded"
The community already uses this exact phrase. Making it the primary metric reframes every cancellation from "chore completed" to "money reclaimed." This is the dopamine loop.

#### B. Add the "Subscription-Ception" Trust Move
1-star reviews across Bobby, SubDupes, and Rocket Money **all** rage about paying a subscription to track subscriptions. Your pricing should lean HARD into lifetime purchase:
- Free: 5 items + manual capture + basic reminders
- **Pro: $29.99 lifetime** (primary) / $3.99/mo / $24.99/yr
- In the video: *"We'd never charge you a subscription to stop subscriptions. But we do have a Pro tier — and yes, we'll remind you before our own trial ends."*

#### C. The Alarm Can't Be Dismissed Without a Decision
Your IDEAS.md item D2 ("the final alarm can't be dismissed without choosing Cancel / Keep / Snooze-until") — **this is the single most differentiating feature**. Every competitor's notification can be swiped away. This one forces a conscious decision. Make this the hero moment in the video.

#### D. One-Tap Cancel Deep Links
Don't just say "cancel now." Provide the **exact URL**:
- Apple subscriptions: `itms-apps://apps.apple.com/account/subscriptions`
- For web services: curate direct cancel URLs for top 50 services (Netflix, Hulu, Adobe, etc.)
- This destroys the "dark pattern friction" that causes task abandonment

#### E. The "ADHD Tax Refunded" Yearly Recap Card
From IDEAS.md E5 — a shareable card: *"In 2026, Untax saved me $847 in ADHD tax."* This is your viral growth mechanic AND a great video ending shot.

---

## 5. The 2-Minute Video Script (Second by Second)

Based on the winning video framework + judge preferences + ADHD research:

```
[0:00 – 0:05] HOOK
  Visual: Black screen → text appears word by word
  Audio: "Regular people set a reminder and do it."

[0:05 – 0:12] THE PROBLEM
  Visual: iPhone notification slides down ("Hulu trial ends tomorrow") →
          thumb swipes it away → notification vanishes
  Audio: "I set a reminder, look at it, swipe it away, and it
          ceases to exist. Two weeks later — $17.99."

[0:12 – 0:20] THE STAKES
  Visual: Quick montage of charges hitting: $17.99, $14.99, $89.00
          → running total counter: "$847/year"
  Audio: "They call it the ADHD Tax. The average person with ADHD
          loses almost $2,000 a year to things they meant to cancel."

[0:20 – 0:25] THE THESIS
  Visual: Untax logo/icon appears clean on screen
  Audio: "Every app reminds you. Untax makes sure you actually do it."

[0:25 – 0:45] THE MAGIC MOMENT (capture → confirm)
  Visual: iPhone in device frame, 60fps screen recording
    1. Forward an email → push notification arrives: "Found: Hulu
       free trial. Ends Oct 3. $17.99/mo after. Track it?" → tap ✅
    2. Share sheet: screenshot of an order confirmation →
       AI extracts "Nike return window: 30 days" → one tap to track
  Audio: "Forward your email. Share a screenshot. Untax finds the
          deadline, the price, and the cancel link — automatically."

[0:45 – 1:05] THE FOLLOW-THROUGH (the differentiator)
  Visual: Show the escalation sequence compressed in time:
    1. Widget on home screen: "Hulu · $17.99 in 3 days" (subtle)
    2. Push notification: "Hulu charges tomorrow. Cancel now?" (urgent)
    3. Full-screen AlarmKit alarm: THREE BUTTONS ONLY —
       "Cancel Now" / "Keep It" / "Snooze Until Tonight"
       (you CANNOT dismiss without choosing)
    4. Tap "Cancel Now" → deep link opens Apple subscription page →
       cancel confirmed → 🎉 confetti + haptics
  Audio: "Gentle at first. Louder when it matters. On the last day,
          Untax won't let you swipe it away. You have to choose:
          cancel, keep, or snooze. No more 'I'll do it later.'"

[1:05 – 1:15] THE REWARD
  Visual: Money-saved counter animates up: "+$17.99" →
          total: "$214.47 ADHD Tax Refunded" →
          celebration animation + haptic burst
  Audio: "Every save counts. Every dollar goes on the board.
          This isn't a guilt trip — it's a scoreboard."

[1:15 – 1:30] THE PAYWALL (RevenueCat moment — judges are watching)
  Visual: Paywall screen (beautiful, custom SwiftUI):
    - "5 items free forever"
    - Pro: $29.99 lifetime (highlighted) / $3.99/mo / $24.99/yr
    → a small banner below the paywall: "We'll remind you 24 hours
      before this trial ends, too. 😉"
  Audio: "We'd never charge a subscription to stop subscriptions.
          Pro is a one-time purchase. And yes — we remind you
          before our own trial ends, too."
  [Beat — let the irony land]

[1:30 – 1:45] TECH & CRAFT (for Antoine van der Lee & code judges)
  Visual: Clean architecture diagram (3 seconds) →
          one beautiful Swift code snippet showing the
          RevenueCat entitlement check with async/await (3 seconds) →
          quick flash of GitHub repo README with architecture badges
  Audio: "Built with SwiftUI, SwiftData, AlarmKit, and Apple's
          on-device Foundation Models. Cloudflare Workers handle
          email ingestion. Fully open source."

[1:45 – 2:00] THE CLOSE
  Visual: "ADHD Tax Refunded" recap card (shareable) →
          fade to app icon + "Untax — Stop paying for forgetting."
          + GitHub QR code
  Audio: "The ADHD Tax isn't a character flaw. It's a system designed
          to exploit your working memory. Untax fights back."
```

---

## 6. Judge-by-Judge Appeal Strategy

| Judge | What They Care About | How Untax Delivers |
|---|---|---|
| **David Barnard** (RevenueCat Growth) | Paywall story, onboarding-to-value pipeline, business viability | The meta-paywall ("we remind you before our trial ends") + honest lifetime pricing + clear value prop |
| **Charlie Chapman** (Dark Noise creator) | Delightful details, haptics, micro-animations, platform citizenship | Celebration haptics, widget countdown, AlarmKit full-screen, SF Symbols, Dynamic Type, Dark Mode |
| **Antoine van der Lee** (SwiftLee) | Clean architecture, modern Swift, pristine GitHub README | Swift 6.4 concurrency, MVVM, modular project structure, architecture diagram in README |
| **Philipp Lackner** (Android educator) | Separation of concerns, pragmatic engineering | Clean layers (even iOS-only, the architecture should be exemplary) |
| **Connor Burd** (2025 Grand Prize winner) | Speed, distribution, real-world impact, vibe-coding | AI-assisted build, clear ROI to user, immediate tangible value |
| **Adam Lyttle** (Indie dev) | Solo builder craft, shipping quality | Student building a polished, thoughtful app solo |
| **Scott Cameron** (Pok Pok, product growth) | Product thinking, user psychology | Deep ADHD research, follow-through as product insight |

---

## 7. GitHub Repo — What Makes It Win

The code is 50% of the Next Gen judging. Based on Antoine van der Lee's preferences and past winners:

### README.md must include:
- [ ] App icon + 3 device-frame screenshots at the top
- [ ] One-sentence pitch + one-paragraph description
- [ ] Architecture diagram (Mermaid or image)
- [ ] Tech stack badges (Swift 6.4, iOS 26+, RevenueCat, Cloudflare)
- [ ] "How RevenueCat Is Used" section (judges will ctrl+F for this)
- [ ] Build instructions (clone → open Xcode → run)
- [ ] Privacy & data handling section
- [ ] License (MIT)

### Code quality signals:
- [ ] Swift 6.4 strict concurrency (`@MainActor`, `Sendable`, `async/await`)
- [ ] Clean MVVM or similar separation
- [ ] SwiftData models in a shared framework (app + widget + share extension)
- [ ] Unit tests for date math and extraction logic
- [ ] No API keys committed (use `.xcconfig` or environment variables)
- [ ] Worker code with test fixtures and `npm test`

---

## 8. New Ideas From Research (Not in Your Current Plan)

| Idea | Source | Priority | Why It Matters |
|---|---|---|---|
| **"Subscription-ception" callout** in video | Bobby/SubDupes 1-star reviews | 🔴 Critical | Judges + ADHD users hate ironic subscription pricing |
| **"ADHD Tax Refunded" as brand language** | Reddit/ADHD community | 🔴 Critical | Community already uses this phrase — instant recognition |
| **Curated cancel URLs for top 50 services** | Competitor gap analysis | 🟡 High | No competitor does this — it's the "action gap" closer |
| **Video opens with real notification swipe-away** | ADHD "notification glaze" research | 🔴 Critical | Instantly shows you understand the real problem |
| **Shareable yearly recap card** | IDEAS.md E5 + viral potential | 🟡 High | "In 2026, Untax saved me $847" — organic growth |
| **"Dark pattern score" per service** | Reddit community request | 🟢 Later | Network effect moat, but not for v1 |
| **Body-doubling timer** for the cancel task | ADHD task initiation research | 🟢 Later | Cool but scope-creep for 6 days |

---

## 9. Strategic Positioning — Before vs. After

### Before (from PLAN.md):
> "An iPhone app that catches the money-deadlines ADHD brains lose track of"

### After (research-informed):
> "The ADHD Tax costs the average person $1,900/year. Every app reminds you. Untax is the only app that **won't let you forget** — escalating reminders that force a decision, one-tap cancel links that skip dark patterns, and a scoreboard that turns every save into a win."

### One-line pitch for Devpost:
> **"Stop paying for forgetting."**

---

## 10. Critical Path — What to Build First

Given 6 days and Next Gen rules (video + code, no store release needed):

| Priority | What | Why |
|---|---|---|
| 🔴 Day 1–2 | Core app shell: manual add + item list + escalation ladder + widget | This is what the video shows — it must be real and polished |
| 🔴 Day 2–3 | AlarmKit integration + the "can't dismiss without deciding" alarm | THE differentiator — the hero moment of the video |
| 🔴 Day 3–4 | Share sheet capture (screenshot → AI extraction) | The magic moment in the video |
| 🟡 Day 4–5 | RevenueCat paywall + "we remind you before our trial ends" | Judges are looking for this specifically |
| 🟡 Day 5 | Email pipeline (even a demo-able version) | Shows technical depth |
| 🔴 Day 5–6 | Video production + GitHub README polish | This IS the submission |

> [!IMPORTANT]
> **The video is not documentation of the app. The video IS the product.** Build the features that make the video powerful. Everything else is optional.
