# Research: "Friction" (earn your screen time)

Researched 2026-09-25 · ✅ = verified at the primary source · ⚠️ = unverified/secondary · ❌ = checked and false

**IDEA:** Screen Time API blocks addictive apps; unlock by doing camera-verified exercise (squats/pushups) or a focus task; unlocks for 15 min.
**PROBLEM:** Compulsive scrolling.
**TARGET USER:** Anyone who over-uses social apps, including students.
**CATEGORY:** Digital wellbeing / screen time.

---

## A. Existing solutions: extremely crowded

**Exercise-to-unlock (the exact pitch).** All ✅ on the US App Store, with ratings count and first release:
| App | Ratings | Since |
|---|---|---|
| Pushscroll: Exercise To Scroll | **17,593** | Jun 2025 |
| PushUp Time: App Blocker | **11,553** | Sep 2025 |
| ScrollFit: PushUp App Blocker | 3,118 | Jan 2026 |
| PushBlock | 1,571 | Dec 2025 |
| PushUpLock | 1,106 | Nov 2025 |
| Fitblock · Grindlocker · Push Up Time–Block Apps · Fitlock | 313 · 114 · 288 · 55 | 2023–2026 |
| **Squat-specific:** Tacet · SquatLock · PeachRep | 14 · 1 · 0 | 2026 |

**Screen-time leaders:** ✅ Opal (**88,510** ratings), BePresent (64,531), ScreenZen (50,326), one sec (23,603), Cape (15,424), Refocus (11,421), ClearSpace (8,877).
→ ⚠️ **Opal's CEO, Kenneth Schlenker, is a Shipaton 2026 judge** ([shipaton.com](https://www.shipaton.com/)). He'll know every app above.

**Block apps until a task is done (relevant to a merge):** ✅ **Due or Die**: *"block selected distracting apps with Screen Time until the work is finished"*, *"escalating consequences when deadlines are missed"*; $0.99/wk, $2.99/mo, $29.99/yr, or $39.99 one-time; 5 ratings ([App Store](https://apps.apple.com/us/app/due-or-die-to-do-app-blocker/id6792173694)). Also Bloko, To-Doo Boo, Habit Doom, Achieve, TaskLock (⚠️ not individually verified).

**Name:** ❌ "Friction" is taken: "Friction – Reduce Screen Time" (320 ratings), "Friction°", "Friction – Scroll Less", and even **"Friction: Stop Impulse Buying."**

**Blunt read:** ❌ *"Nothing like this exists"* is badly false. This is a proven, monetizing category (Pushscroll launched Jun 2025 and already has 17.5k ratings) with 15+ direct copies. Novelty for judging criterion 1 would be low.

## B. Demand
✅ Strong: tens of thousands of ratings across screen-time apps; exercise-to-unlock grew from zero to 17k+ ratings in about a year. Demand is proven, and so is the saturation.

## C. The gap
Hard to find in exercise-to-unlock. The only unoccupied angle is using the lock as **leverage for a different goal**, e.g. money deadlines (see merge below). Due or Die does "lock until task done" for generic to-dos, but without automatic capture or money-specific follow-through.

## D. Feasibility (Apple primary sources)
- ✅ **Requires the $99 Apple Developer Program, even for development.** Apple's capabilities table: "Family Controls (development)": ADP yes, **free Apple ID no** ([table](https://developer.apple.com/help/account/reference/supported-capabilities-ios)). App Store release also requires requesting the entitlement from Apple ([docs](https://developer.apple.com/documentation/familycontrols)); Next Gen doesn't need a store release.
- ✅ Blocking your *own* apps is supported: `FamilyControlsMember.individual`, iOS 16+.
- ✅ **The block screen can open your app:** `ShieldActionResponse.openParentalControlsApp`, but only on **iOS 26.5+**. Other responses: `.close`, `.defer`, `.none`.
- ⚠️ "6 MB extension memory limit": developers report it on [Apple's forums](https://developer.apple.com/forums/thread/735454); not stated in Apple's docs. Treat as real and keep extensions tiny.
- ⚠️ "Max 50 app tokens": not found in Apple's docs or forums in this check.
- ✅ Body-pose detection: Vision `VNDetectHumanBodyPoseRequest` (iOS 14+) / `DetectHumanBodyPoseRequest` (iOS 18+). ⚠️ Reliability depends on camera angle and full-body visibility (earlier production write-ups), which is a demo risk.
- Build effort: Screen Time API (3 extensions: monitor, shield config, shield action) + camera rep counting is the heaviest of the three ideas. The pitch's own "5-day build: 7" undersells the extension debugging.

## E. Business
✅ Benchmarks: Due or Die $2.99/mo–$39.99 lifetime; Opal/Pushscroll are freemium. RevenueCat fit is fine, but you'd be competing on price against free tiers of 17k-rating apps.

## Scorecard vs evidence
| Dimension | Pitch | Evidence |
|---|---|---|
| Video hook | 10 | ✅ Agree: very watchable |
| Technical wow | 9 | Same API mashup Pushscroll & co. already ship |
| **Novelty** | **10** | **❌ Very low:** 15+ direct competitors, the category leader has 17.5k ratings, and a judge runs the biggest screen-time app |
| RevenueCat fit | 7 | OK |
| 5-day build | 7 | ⚠️ Optimistic: needs $99 + 3 extensions + reliable rep counting |

**Verdict as a standalone app: NO-GO** (confidence: high). Wrong category to enter with originality as a judging criterion.

---

## The 3-way merge: Untax + Parachute + Friction

The pieces fit **one story** if each idea contributes only its best mechanic and everything serves money deadlines:

```
CATCH   (Untax)      trial/return found automatically → "Track it?"
NUDGE   (Untax)      widget → notifications → final-day alarm (Stop only postpones)
UNFREEZE (Parachute) "I'm frozen" → one tiny curated step at a time, 2-min timer
LOCK    (Friction)   opt-in "Hardcore mode": ignore the deadline → chosen apps are
                     blocked until you choose Cancel or Keep   ← last resort
REWARD  (Untax)      "+$17.99 ADHD Tax Refunded" 🎉
```

**What to take from Friction: the lock, not the squats.**
- ✅ Tying the lock to a *money deadline you ignored* isn't what the 15+ exercise apps do. Due or Die is the closest, but it's generic to-dos with manual entry.
- ❌ Skip camera squats: crowded, unreliable in demos, and off-message (the problem is money, not fitness). A joke "do 10 squats to snooze an hour" would be possible later but dilutes the story.

**Costs of adding the lock:**
- $99 Apple Program becomes **mandatory** (no free-ID path).
- Needs iOS 26.5+ for "open the app from the block screen."
- +1.5–2 days (3 small extensions + memory limits).
- Must be **opt-in** (and easy to switch off), or it feels hostile.

**Honest scope check for Sep 30 (~5 days):** Untax core + Parachute's "I'm frozen" (curated steps) fits. Adding the Friction lock too is **tight**. Treat the lock as a stretch goal: build it only if days 1–3 land on time. The video can still show the escalation ladder ending in the lock if it works.

**Novelty of the merged product:** the parts exist separately (capture: SubDupes; ADHD deadlines: Deadlinr; micro-steps: EmberTend; lock-until-done: Due or Die), but I found **no app combining automatic money-deadline capture + escalating follow-through + unfreeze steps + a lock.** ⚠️ Absence in searches doesn't prove absence.
