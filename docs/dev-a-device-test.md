# Dev A combined iPhone test (A5 to A8 + P2)

Build installed on Dev A's iPhone on 2026-09-27 (branch `a/p-polish-demo`, which contains A5 through P2). Tick each line; anything that fails goes to Claude with a screenshot.

## 0. Start clean
- [ ] Debug → **Clear all trials** → **Load demo trials**
- [ ] Money tab shows Duolingo (orange, "cancel by …, Apple needs a day"), Spotify, Claude, Google AI Pro, and a cancelled Apple One

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
- [ ] Tap **Spotify** → Decide: Cancel it · I'm frozen · Keep it · Snooze
- [ ] **Snooze → In 1 hour** → row says "Snoozed until …"
- [ ] Tap Spotify → **Cancel it** → your hand-checked steps → **Done, it's cancelled** → "Cancelled · $11.99 won't be charged"
- [ ] Tap it → **Reopen** → tap again → **I'm frozen** → placeholder steps → **I did it** → cancelled again
- [ ] Tap **Claude** → **Keep it** → moves to Decided, "Kept"

## 3. Apple path (A6)
- [ ] Tap **Duolingo** → **Cancel it** → **Open Apple Subscriptions**: does it open the App Store's Subscriptions page? ⚠️ This is the unverified link.
- [ ] The Apple steps and "Or cancel on Apple's website" show below it

## 4. Share a screenshot (A7)
- [ ] Take a screenshot of any trial or subscription screen (e.g. Settings → Subscriptions, or a trial email)
- [ ] Share it (tap the thumbnail, then Share) → **Parachute**
- [ ] The card shows "Found: … · $… · charges …"; note whether it says "with Apple Intelligence" (the model ran inside the extension)
- [ ] **Track it** → "Tracking …" → open Parachute → it's in the Money tab

## 5. Alarm with Pro (A4 recheck)
- [ ] Debug → Reminders, alarm + time travel → **Ring …'s final alarm in 1 minute** → it rings; Decide opens the new Decide screen
- [ ] Time travel **off** at the end

## Results
_Fill in: what failed, screenshots._
