# B0: Atomizer spike

Status: **prepared, not yet run on device.** Fill in the results tables below after the on-device run.

## 1. Purpose and pass criteria

Check whether the on-device Foundation Models atomizer (`AIAtomizer`) gives step lists good enough to ship the AI task path and AI "Suggested steps" for unknown services.

From `MILESTONES.md`:

> **B0 Atomizer spike.** Foundation Models `@Generable` → `[Step{text, seconds}]`. Run it on **20 real deadline tasks** (essays, forms, applications, emails) and **10 unknown services** ("how to cancel X").
> *Done when:* ≥ 15/20 task lists and ≥ 7/10 service lists are specific enough to follow without guessing; prompt + results saved in `docs/`. **If it fails, tell Dev A and cut or shrink the task path now.**

Pass bar: **Tasks ≥ 15/20** and **Services ≥ 7/10**.

## 2. Prompt and schema (verbatim from `Packages/ParachuteKit/Sources/ParachuteKit/Unfreeze/AIAtomizer.swift`)

If `AIAtomizer.swift` changes before the run, re-copy this section so the results match the prompt that produced them.

### Instructions (`LanguageModelSession(instructions:)`)

```swift
static let instructions = """
    You help people with ADHD start things they're frozen on. You break work into tiny, \
    physical steps a person can do right now. Every step starts with a verb and takes 90 seconds \
    or less. Never say "think about", "consider", or "plan". Never include links, URLs, or web addresses. \
    Be warm and plain. No shame, no pressure.
    """
```

### Prompt: `atomize(taskTitle:dueDate:)`

```swift
let due = dueDate.map { " It's due \($0.formatted(date: .abbreviated, time: .shortened))." } ?? ""
let prompt = """
    Break this task into 4 to 8 tiny steps: "\(taskTitle)".\(due)
    The first step must be almost silly-small, like "Open a blank doc. Type your name at the top."
    """
```

### Prompt: `atomizeCancel(serviceName:)`

```swift
let prompt = """
    Give 3 to 6 tiny steps to cancel a "\(serviceName)" subscription or free trial.
    Say "open the \(serviceName) website" or "open the \(serviceName) app" instead of giving any address.
    The last step is taking a screenshot of the confirmation.
    """
```

### Prompt: `breakSmaller(_:goal:)`

```swift
let prompt = """
    Someone working on "\(goal)" is stuck on this step: "\(step.text)".
    Split just this step into 2 to 4 even smaller steps. The first one takes about 5 seconds.
    """
```

### `@Generable` schema

```swift
@Generable
struct AtomizedSteps {
    @Guide(description: "The tiny steps, in order. The first one takes about 10 seconds.", .maximumCount(8))
    var steps: [AtomizedStep]
}

@Generable
struct AtomizedStep {
    @Guide(description: "One physical action that starts with a verb, e.g. 'Open a blank doc. Type your name.' No links or web addresses.")
    var text: String
    @Guide(description: "Seconds it takes, from 5 to 90.", .range(5...90))
    var seconds: Int
}
```

Call: `session.respond(to: prompt, generating: AtomizedSteps.self)`, then `StepSanitizer.sanitizeAI` (strips URLs and bare domains, clamps seconds to 5–90, drops empty and duplicate steps). If the model is unavailable, throws, or returns nothing after sanitizing, the app serves the non-AI `Fallbacks` template instead.

**Important for scoring:** a fallback template is not a model result. The spike screen must mark which source produced each list; a list that fell back counts as ❌ for B0.

## 3. Scoring rubric

Score each list as it appears **after** sanitizing (what the user would see). A list **passes (✅)** only if all of these hold:

1. **Concrete physical actions.** Every step is something you do with your hands or eyes (open, type, tap, write, find, send), starting with a verb.
2. **Tiny first step.** Step 1 takes about 15 seconds or less and is trivially easy (open a doc, find the email, pick up the form).
3. **No invented URLs or web addresses.** The sanitizer strips them, so also check what's left: a step that only made sense with the link ("Go to ." or "Visit the page at") fails.
4. **No "think about", "consider", "plan", "decide", "reflect", "brainstorm in your head".**
5. **Step count in range:** 4–8 for tasks, 3–6 for cancels.
6. **A stranger could follow it without guessing.** No "complete the form" or "finish the essay" as one step; no steps that assume facts the model can't know (a specific menu name that doesn't exist, a phone number, a fee).
7. **Cancels only:** ends with taking a screenshot of the confirmation; doesn't promise a refund; doesn't claim "cancel in Apple settings" for a web signup (CLAUDE.md rule 8).
8. **ADHD-first tone:** no shame, guilt, or pressure (CLAUDE.md rule 10).

Mark borderline cases ❌ with a note. Seconds values that look wrong (a 5-second "write the introduction") are a note, and a fail if more than one step is badly off.

## 4. Test set

### 20 deadline tasks

The spike screen passes each title to `atomize(taskTitle:dueDate:)` with the relative due date shown (from the moment you run it).

| # | Task title (exact input) | Due |
|---|---|---|
| T1 | Write a 1,500-word history essay on the causes of World War I | +3 days |
| T2 | Finish my FAFSA renewal | +5 days |
| T3 | Email my professor to ask for an extension on the lab report | +1 day |
| T4 | Write the lab report for chemistry (titration experiment) | +2 days |
| T5 | Apply for the summer internship at a marketing agency | +4 days |
| T6 | Write my college application personal statement (650 words) | +7 days |
| T7 | Renew my driver's license | +10 days |
| T8 | File my state and federal taxes | +6 days |
| T9 | Email my landlord about the broken heater | +1 day |
| T10 | Update my resume for a part-time job application | +2 days |
| T11 | Fill out the housing application for next semester | +3 days |
| T12 | Write a cover letter for a barista job | +2 days |
| T13 | Submit my scholarship application with two short essays | +5 days |
| T14 | Study for Friday's calculus midterm | +3 days |
| T15 | Make slides for my group project presentation | +2 days |
| T16 | Renew my passport | +14 days |
| T17 | Reply to my advisor's email about picking classes | +1 day |
| T18 | Submit my reimbursement form with receipts at work | +2 days |
| T19 | Write a 5-page reading response for English class | +4 days |
| T20 | Schedule a doctor's appointment and fill out the new-patient form | +3 days |

### 10 unknown services

None of these are in `CancelSteps.json` (curated today: Spotify, Claude, Google AI Pro (Google One), Apple One). The spike screen passes each name to `atomizeCancel(serviceName:)`.

| # | Service (exact input) | Note |
|---|---|---|
| S1 | Hulu | |
| S2 | Peacock | |
| S3 | Adobe Creative Cloud | Cancellation may show an early-termination fee on annual plans ⚠️ unverified; fail the list if it states a fee amount. |
| S4 | Audible | |
| S5 | Duolingo | Often billed through the App Store; check the steps still make sense for a web or in-app signup. |
| S6 | The New York Times | |
| S7 | Planet Fitness | **Known hard case:** gym memberships may require in-person or mailed cancellation ⚠️ unverified. A list that confidently says "tap Cancel in the app" is a fail; a list that says to contact or visit your home club can pass. |
| S8 | HelloFresh | |
| S9 | Paramount+ | |
| S10 | LinkedIn Premium | |

## 5. Results

Run date: ____ · Device: ____ · iOS: ____ · Apple Intelligence on: ____ · Language: ____

Paste the spike screen's Markdown output under "Raw output" and score each row here.

### Tasks

| # | Input | Steps | Pass | Note |
|---|---|---|---|---|
| T1 | History essay (WWI) | | | |
| T2 | FAFSA renewal | | | |
| T3 | Email professor for extension | | | |
| T4 | Chemistry lab report | | | |
| T5 | Summer internship application | | | |
| T6 | College personal statement | | | |
| T7 | Renew driver's license | | | |
| T8 | File taxes | | | |
| T9 | Email landlord about heater | | | |
| T10 | Update resume | | | |
| T11 | Housing application | | | |
| T12 | Barista cover letter | | | |
| T13 | Scholarship application | | | |
| T14 | Study for calculus midterm | | | |
| T15 | Group project slides | | | |
| T16 | Renew passport | | | |
| T17 | Reply to advisor | | | |
| T18 | Reimbursement form | | | |
| T19 | English reading response | | | |
| T20 | Doctor's appointment + form | | | |

### Services

| # | Input | Steps | Pass | Note |
|---|---|---|---|---|
| S1 | Hulu | | | |
| S2 | Peacock | | | |
| S3 | Adobe Creative Cloud | | | |
| S4 | Audible | | | |
| S5 | Duolingo | | | |
| S6 | The New York Times | | | |
| S7 | Planet Fitness | | | |
| S8 | HelloFresh | | | |
| S9 | Paramount+ | | | |
| S10 | LinkedIn Premium | | | |

### Summary

**Tasks: _/20 · Services: _/10 · Verdict: _**

(Verdict: PASS if tasks ≥ 15 and services ≥ 7; otherwise FAIL, and say which half failed.)

### Raw output

<!-- Paste the Markdown copied from the B0 spike screen here. -->

## 6. If it fails

Per `MILESTONES.md`: **tell Dev A the same day, and cut or shrink the task path now.**

- **Tasks fail (< 15/20):** shrink the task path to the non-AI `Fallbacks.task` template (already in `AIAtomizer.swift`), or drop the task path from the video (it's cut-priority 5 in `MILESTONES.md`, "only if B0 failed"). The money flow and curated cancel steps don't depend on B0.
- **Services fail (< 7/10):** serve `Fallbacks.cancel` for unknown services instead of AI steps, and lean on curated `CancelSteps.json` plus the Apple subscription settings path.
- **Partial:** try one prompt revision first (tighten wording, add an example step), re-run only the failed half, and log both runs here with the prompt diff.

Record the decision in `PROJECT.md`.

## 7. How to run on device (about 20 minutes)

**Needs:** an Apple Intelligence-capable iPhone (iPhone 15 Pro or later ⚠️ verify the current device list on Apple's Apple Intelligence page), Apple Intelligence turned on in Settings, and device and Siri language set to English. The model must have finished downloading; if `SystemLanguageModel.default.isAvailable` is false, every list will be a fallback and the run doesn't count.

1. Build and run the **Debug** configuration on the iPhone from Xcode (the spike screen is compiled only in DEBUG).
2. In the app: **Home tab → toolbar ladybug (DEBUG only) → "Run B0 atomizer spike."**
3. The screen runs all 30 inputs (T1–T20 through `atomize`, S1–S10 through `atomizeCancel`) and shows each list with its step count and whether it came from the model or a fallback.
4. Tap copy to put the whole run on the clipboard as Markdown. AirDrop or paste it into "Raw output" above.
5. Score each row with the rubric in section 3, fill in the summary line, and commit this file with the results.
6. Update `PROJECT.md` and tick B0 in `MILESTONES.md` if it passed; otherwise follow section 6.
