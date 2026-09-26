# cancel-steps-verification.md

Every service in `CancelSteps.json` must be **followed by hand on a real account** before it ships, and **re-checked the day before the demo** (cancel flows change). Never add a URL you didn't open yourself. (CLAUDE.md rule 9)

| Service | Billed by | Verified on | By | Device / iOS | Steps followed end to end? | Screenshots | Notes / changes since last check |
|---|---|---|---|---|---|---|---|
| Spotify (Premium Student) | web (spotify.com) | 2026-09-26 | A | Browser on Mac ⚠️ re-check in iPhone Safari | ☑ up to the final **Yes, cancel** (not tapped, account kept) | Kept private (show account email/card) | Account page → *Cancel subscription* (also reachable via *Manage your subscription* → *Cancel subscription*) → "How you listen will change" → *Continue to cancel* → "Cancel Premium Student?" → *Yes, cancel*. Premium stays until the next bill date. ⚠️ Account-page URL not recorded yet, so step 1 has no link |
| Claude (Pro, $20/mo) | web (claude.ai) | 2026-09-26 | A | Claude on Mac ⚠️ re-check in iPhone Safari | ☑ up to the final **Cancel plan** in the popup (not tapped, plan kept) | Kept private | Settings → *Billing* → scroll to *Cancellation* → *Cancel* → popup "Cancel plan" (lists what you lose, says Pro lasts to the end of the period) → *Cancel plan*. ⚠️ A survey may follow the final tap; can't know without cancelling. Step 1 names claude.ai (the product's own domain) but has no link until the settings URL is confirmed |
| Google AI Pro (5 TB, Google One, $19.99/mo) | web (Google Account) | 2026-09-26 | A | Browser on Mac ⚠️ re-check in iPhone Safari | ☑ up to the final **Cancel subscription** in the "Cancel subscription?" dialog (not tapped, plan kept) | Kept private | Google Account → *Payments & subscriptions* → *Subscriptions*: Google One card → popup → *Cancel subscription* → dialog "Cancel subscription?" (lists lost benefits, ends at billing period end) → *Cancel subscription*. No offer screen. ⚠️ Confirm the card (not *Manage subscriptions*) opens the popup; account URL not recorded yet |
| Apple One (Individual, 1-month free trial then $21.95/mo) | **Apple** | 2026-09-26 | A | iPhone 17 Pro Max, iOS 27.0 (Settings) | ☑ trial started for $0 and cancelled for real | Kept private | Settings → name → *Subscriptions* → *Apple One* → scroll → *Cancel All Services* → "Do you want to keep any services?" (retention: keep Music/TV/Arcade/iCloud+ individually) → *Cancel All Services* → "Confirm Cancellation" (*"your service will end immediately, including the remainder of your free trial. You cannot reactivate this trial."*) → *Cancel Subscription* → result: red *"You've canceled your subscription."* / *"Your subscription ended on September 26."* (ended the same day, $0 charged). Offer changed from "Try It Free" to "Try It Now" afterwards (trial used up). No "Cancel Free Trial" button for a bundle |
| _(service 5)_ | | | A | | ☐ | | |

**Pick services you (or friends) actually have accounts with.** Include at least one **billed by Apple** (a trial started in an iPhone app) so the Apple-subscriptions path can be demoed honestly.

### Re-check before the demo (Day 5 morning)
- [ ] Service 1 · [ ] Service 2 · [ ] Service 3 · [ ] Service 4 · [ ] Service 5

### What the Apple One run taught us (2026-09-26)
- **Apple's own deadline is a day early.** The subscribe sheet says: *"Cancel anytime in Settings > Apple Account at least a day before each renewal date."* For `billedByApple` items the effective deadline is **dueDate minus 24 h**, so A2's reminders and A4's final alarm must be anchored to that, not to the charge date.
- **Apple flows differ per subscription.** A bundle shows "Cancel All Services" and a keep-some-services step; a single app trial is expected to show "Cancel Free Trial" ⚠️ (not yet seen). The generic Apple path (B3) should open the Subscriptions screen and let curated entries like `apple-one` supply exact steps when known.
- **Cancelling an Apple free trial can end access immediately** (Apple One: yes). Copy must not promise "you keep it until the trial ends" for Apple-billed trials.
