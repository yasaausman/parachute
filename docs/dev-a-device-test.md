# Dev A combined iPhone test (A5 to A8 + P2)

Build installed on Dev A's iPhone on 2026-09-27 (branch `a/p-polish-demo`, which contains A5 through P2). Tick each line; anything that fails goes to Claude with a screenshot.

## 0. Start clean
- [x] Debug → **Clear all trials** → **Load demo trials**
- [x] Money tab shows Duolingo (orange, "cancel by …, Apple needs a day"), Spotify, Claude, Google AI Pro, and a cancelled Apple One

## 1. Paywall and Pro (A8)
- [x] Debug → Paywall: **Pro** says yes or no (earlier Test Store purchases may still count)
- [x] **Show paywall**: Lifetime (BEST) $29.99, Yearly "1 week free, then $24.99/yr", Monthly $3.99 (2026-09-28)
- [x] Yearly → "Start 1 week free trial" → Test Store sheet → valid purchase → Pro = yes with Force Pro **off**
- [x] Buy (trial via the shortcut) → *Test valid purchase* → sheet closes, Pro = yes
- [x] Paywall → **Restore purchases** → "Restored. You're Pro."
- [ ] Money tab footer "The final-day alarm … is Pro" disappears once Pro
- [ ] (Optional) Force Pro off with no purchase: add a 6th open trial → the paywall appears instead of the form
- [x] **Preview "trial ends tomorrow" reminder** → notification in about a minute ("Parachute Pro: your trial ends tomorrow", 2026-09-28)

## 2. Decide (A5)
- [x] Tap **Spotify** → Decide: Cancel it · I'm frozen · Keep it · Snooze
- [x] **Snooze** screen: In 1 hour / Tomorrow at 9 (tonight at 8 correctly hidden after 8 PM), custom time capped at "decide by Sep 30, 11:59 PM". Row text after snoozing seen in the simulator only.
- [x] Tap Spotify → **Cancel it** → your hand-checked steps → **Done, it's cancelled** → "Cancelled · $11.99 won't be charged"
- [ ] Tap it → **Reopen** → tap again → **I'm frozen** → placeholder steps → **I did it** → cancelled again
- [x] Tap **Claude** → **Keep it** → moves to Decided, "Kept"

## 3. Apple path (A6)
- [x] Tap **Duolingo** → **Cancel it** → **Open Apple Subscriptions** → Apple's Subscriptions page, with "◀ Parachute" back (2026-09-28)
- [x] The Apple steps and "Or cancel on Apple's website" show below it

## 4. Share a screenshot (A7)
- [x] Negative case: Settings → Subscriptions (all cancelled) → "No upcoming charge on this screen", nothing invented (after the 2026-09-28 fix)
- [x] Take a screenshot of any trial or subscription screen (Google's subscription page in Safari) (e.g. Settings → Subscriptions, or a trial email)
- [x] Share it (tap the thumbnail, then Share) → **Parachute**
- [x] The card says "Read on this iPhone with Apple Intelligence": the model runs inside the extension
- [x] The card shows "Found: Google One · $19.99 · charges Dec 7"
- [x] **Track it** → "Tracking …" → open Parachute → it's in the Money tab

## 5. Alarm with Pro (A4 recheck)
- [ ] Debug → Reminders, alarm + time travel → **Ring …'s final alarm in 1 minute** → it rings; Decide opens the new Decide screen
- [ ] Time travel **off** at the end

## Results
_Fill in: what failed, screenshots._
