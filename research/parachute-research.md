# Research: "Parachute" (ADHD task-paralysis lifeline)

Researched 2026-09-25 · ✅ = verified at the primary source · ⚠️ = unverified/secondary · ❌ = checked and false

**IDEA:** One tap "I'm Frozen" → AI breaks the task into ~90-second micro-steps → audio body-doubling companion → syllabus parser.
**PROBLEM:** ADHD task-initiation paralysis ("I know what to do but can't start").
**TARGET USER:** Students with ADHD.
**CATEGORY:** ADHD productivity / executive function.

---

## A. Existing solutions — very crowded

**Category leaders**
| App | Evidence | What it does |
|---|---|---|
| **Tiimo** | ✅ Apple's **iPhone App of the Year 2025**: *"thoughtfully implemented AI that turns aspirations into actionable next steps"* ([Apple Newsroom](https://www.apple.com/newsroom/2025/12/apple-unveils-the-winners-of-the-2025-app-store-awards/)); ✅ 20,084 ratings, 4.6★ (App Store) | AI breaks tasks into steps with time estimates, visual planner, built for neurodivergent users |
| **Goblin Tools** | ✅ 3,014 ratings, 4.8★, $1.99 one-time, since May 2023 (App Store); ⚠️ viral in ADHD communities in 2023 | "Magic ToDo" breaks any task into steps, recursively. The website is free |
| **dubbii** | ✅ 729 ratings, since Nov 2023 (App Store); ⚠️ "300,000 people" (their claim) | AI body doubling |
| **Focus Friend** (Hank Green) | ✅ 7,658 ratings, since Jul 2025 (App Store) | Focus companion |
| Inflow, Mindflow AI, neurolist | ✅ 5,620 / 2,716 / 901 ratings (App Store) | ADHD coaching / AI planning |

**Direct clones of the exact "I'm stuck → one tiny step" loop, all launched in the last ~12 months** (✅ all on the US App Store):
EmberTend (Feb 2026: *"asks how you're stuck"*) · UnfreezeMe: ADHD Task Starter (Mar 2026) · First Step: End Task Paralysis (Apr 2026) · Tiny Steps: ADHD Task Helper (Feb 2026) · Helpun (Nov 2025) · Scramblie (Oct 2025) · ParaCortex (Mar 2026) · FOCO (Jul 2026: *"Turns any task into one tiny step you can actually begin, then stays with you while you do it"*, $9/mo or $59/yr, [tryfoco.com](https://www.tryfoco.com/)). Most have 0–1 ratings: a lot of people are building this, and nobody has broken out yet.

**Syllabus parsers:** ✅ Sylly (50 ratings, Mar 2026) · ⚠️ Coursicle, DormWay, UpAhead, Syllabus AI.

**Blunt read:** ❌ The pitch's claim *"Nothing does 'un-freeze me right now'"* is false. At least 8 apps launched this exact loop in the past year, and Apple's App of the Year does AI next steps.

## B. Demand
- ✅ Real and large: 15.5M US adults with ADHD ([CDC](https://www.cdc.gov/mmwr/volumes/73/wr/mm7340a1.htm)); Apple naming Tiimo App of the Year shows the category matters.
- ✅ The flood of new "task paralysis" apps shows demand, and also saturation.
- ⚠️ Body-doubling evidence is thin: one [12-participant VR study](https://arxiv.org/abs/2509.12153) found faster task completion with a human *or* AI body double vs alone, but *"opinions diverged between conditions."* "AI nearly as effective as a human" is **not** in the abstract.

## C. The gap
Hard to find. Generic "break my task into steps" is a commodity: Goblin Tools' website is free, and Tiimo has Apple's backing. A newcomer would have to win on voice, design, or a niche (e.g. students + syllabus). That niche also has its own competitors.

## D. Feasibility
- ✅ Foundation Models (iOS 26+) handles on-device text generation, guided generation, and image understanding ([Apple](https://developer.apple.com/documentation/foundationmodels)), so the atomizer is buildable. **Risk (the pitch names it too):** a ~3B on-device model gives generic steps, and generic steps are exactly where competitors already are.
- ⚠️ **Tech mix-up in the pitch:** *"SpeechAnalyzer for body-doubling."* ✅ SpeechAnalyzer is **speech-to-text** (listening), iOS 26+ ([Apple](https://developer.apple.com/documentation/speech/speechanalyzer)). A companion that *talks* needs text-to-speech (`AVSpeechSynthesizer`). Fixable, but the pitch's tech section wasn't checked.
- ✅ AlarmKit for deadlines works (see PLAN.md §2D).
- Build effort: the core loop (3 screens + AI prompt + timer) fits in ~5 days. The syllabus parser adds a whole second product.
- ❌ Name: "Parachute" is taken on the App Store (several apps, e.g. "Parachute" with 519 ratings).

## E. Business
- ✅ Benchmarks: FOCO $9/mo or $59/yr · Goblin Tools $1.99 one-time (web free) · Tiimo subscription.
- The pitch's "3 free un-freezes/week → Pro" works with RevenueCat, but willingness to pay is under pressure from free Goblin Tools.

## The pitch's own scorecard vs the evidence
| Dimension | Pitch score | Evidence says |
|---|---|---|
| Video hook | 10 | ✅ Agree: the freeze → relief moment is powerful |
| Technical wow | 8 | Same Apple frameworks as Untax, minus the email pipeline; one API mislabeled |
| **Novelty** | **9** | **❌ Low:** 8+ direct clones this year plus the App of the Year |
| RevenueCat fit | 8 | OK, but price pressure from free tools |
| 5-day build | 8 | ✅ Plausible for the core loop only |

---

## Options for your decision

**Option 1: Switch to Parachute.** Stronger emotional video, but it walks into the most crowded corner of ADHD apps. Judges include indie devs and Opal's CEO, people who know this space. It would score weaker on judging criterion 1 ("original"). Verdict if chosen alone: **PIVOT-risky** (confidence: medium-high).

**Option 2: Keep Untax as is.** Its gap is verified (PLAN.md §2): nobody combines automatic capture with follow-through for money deadlines.

**Option 3 (recommended): Put Parachute's best mechanic inside Untax.** When the final alarm fires and you freeze, tap **"I'm frozen"** → Untax shows **one tiny step at a time for *that specific cancellation*** ("Step 1: Open Settings. That's it."), with a 2-minute focus timer.
- **Removes Parachute's biggest risk:** cancel steps for the top 10 services are **curated and known**, not generic AI guesses. The AI only helps with unknown services.
- It **is** the follow-through you've been asking for ("force them to do the task"), and it already exists in IDEAS.md as D4 (2-minute focus mode) and D12 (body doubling).
- **Video gets both beats:** freeze → exhale → cancel → "+$17.99 ADHD Tax Refunded."
- Cost: about +1 day. Drop the syllabus parser (a separate crowded product).
