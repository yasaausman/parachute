# IDEAS.md: Parachute feature backlog

Every idea I could think of, grouped so it's easy to prune. **Nothing here is committed** — the MVP in `PLAN.md` is only the rows tagged `MVP`.

**Legend**
- **Effort:** S = a day or two · M = about a week · L = weeks, or needs money/partners
- **Tier:** `MVP` = in v1 · `v1.1` = right after launch · `Later` = someday · `Maybe` = unsure it's worth it
- To prune: change the tier, or strike it through (`~~idea~~`). Add yours in section 0.

---

## 0. Your ideas (add here)
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| Y1 | *(your "force them to do the task" ideas go here)* | | | |
| Y2 | | | | |

---

## A. Capture: never rely on memory
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| A1 | Personal forwarding address + one Gmail filter (trial/receipt/order/subscription) | M | MVP | Core of auto-capture |
| A2 | Guided setup that auto-catches Gmail's forwarding confirmation code | M | MVP | Onboarding make-or-break |
| A3 | Share sheet: screenshot, link, or text → item | M | MVP | Works for any app |
| A4 | Natural-language quick add ("Netflix trial 7 days") | S | MVP | Fallback |
| A5 | Estimate trial length when the email doesn't say it (7/14/30), marked "estimated" | S | MVP | |
| A6 | Siri / App Shortcut: "I just started a trial" | S | v1.1 | Hands-free |
| A7 | Action Button / Control Center control for instant capture | S | v1.1 | |
| A8 | Camera scan of paper receipts (return windows) | S | v1.1 | |
| A9 | Outlook, iCloud, Yahoo forwarding guides | S each | v1.1 | Gmail first |
| A10 | Weekly 10-second "anything new?" swipe review | S | v1.1 | Catches misses |
| A11 | Share order confirmations from Messages/SMS | S | v1.1 | |
| A12 | Duplicate detection (same service twice) | S | v1.1 | |
| A13 | Safari extension that spots "Start free trial" pages | M | Later | Safari only |
| A14 | Direct Gmail connection (needs Google's yearly security assessment) | L 💰 | Later | ~$540+/yr, 4–8 weeks |
| A15 | Bank/card connection as a safety net | L 💰 | Later | Per-user fees |

## B. More money leaks to track
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| B1 | Free trials | — | MVP | |
| B2 | Return windows | — | MVP | |
| B3 | Gift cards: balance, expiry, "you're at Target, you have $40" | M | v1.1 | $23B unspent nationally |
| B4 | Refunds you're owed ("refund not received after 10 days") | S | v1.1 | |
| B5 | Annual renewals (Prime, domains, antivirus), 30 days' warning | S | v1.1 | Big surprise charges |
| B6 | Bills & due dates (late fees) | M | v1.1 | |
| B7 | Promo/intro-rate endings (0% APR, phone-plan promo) | S | Later | |
| B8 | Price increases spotted in renewal emails | M | Later | |
| B9 | Price-drop / price-adjustment windows | M | Later | |
| B10 | Warranties | S | Later | |
| B11 | Rebates & mail-in forms | S | Later | |
| B12 | Parking tickets, library fines, tolls | S | Later | |
| B13 | FSA/HSA "use it or lose it" deadline | S | Later | |
| B14 | Unused memberships (the gym you never go to) | M | Later | Needs usage check-ins |
| B15 | Deposits to get back (security deposit, etc.) | S | Maybe | |

## C. Reminders ADHD brains can't ignore
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| C1 | Escalation ladder: gentle → louder → alarm | M | MVP | The core difference |
| C2 | Opt-in AlarmKit final-day alarm (breaks through Silent/Focus) | M | MVP | App Review risk; must be opt-in |
| C3 | Lock/Home Screen widget countdown ("$17.99 in 2 days") | M | MVP | Always visible |
| C4 | Talk money, not dates: "$17.99 leaves your account Friday" | S | MVP | |
| C5 | Varied wording and styles so alerts don't blur together | S | MVP | Fights notification blindness |
| C6 | Last-chance push 2 hours before the charge | S | v1.1 | |
| C7 | Final-day Live Activity counting down to the charge | S | v1.1 | Max 8h, so final day only |
| C8 | Snooze to a specific time you pick, never just "later" | S | v1.1 | |
| C9 | Location nudge: near the store with a return due | M | v1.1 | Needs location permission |
| C10 | Export to Calendar | S | v1.1 | |
| C11 | Nag intensity setting: chill / normal / relentless | S | v1.1 | |
| C12 | Apple Watch haptic nudge | M | Later | |
| C13 | Learn when you usually pick up your phone and remind you then | M | Later | |

## D. Follow-through: making it actually happen
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| D1 | One-tap "Cancel now" → the exact cancel page / Apple subscriptions | M | MVP | |
| D2 | **Hero feature:** final-day alarm where Stop only postpones (re-arms in 30 min) until you choose Cancel / Keep / Snooze-until | M | MVP | ✅ Buildable: AlarmKit allows Stop + 1 button, and `stopIntent` can re-arm. (Was "can't be dismissed," which isn't possible) |
| D3 | "Keep it" as a deliberate choice (logged, no nagging after) | S | MVP | Respects real decisions |
| D4 | "Do it now" 2-minute focus mode with a timer | S | v1.1 | ADHD task initiation |
| D5 | Curated direct cancel links + steps: **top 10 services** | S | MVP | From friend's plan; skips dark-pattern friction |
| D5b | Expand curated cancel links to the top 50 | M | v1.1 | |
| D6 | Proof of cancellation: screenshot the confirmation | S | v1.1 | Also evidence for disputes |
| D7 | Pre-commitment at signup: "Keep or cancel before it ends?" | S | v1.1 | |
| D8 | Accountability buddy gets pinged if you ignore the final alarm | M | v1.1 | Social pressure |
| D9 | AI-drafted cancellation email / support-chat message | M | v1.1 | |
| D10 | Rescue mode: already charged? guide + drafted refund request | M | v1.1 | Turns a loss into a win |
| D11 | "Handled on time" streak | S | v1.1 | |
| D12 | Body-doubling session (live timer, or a friend joins) | M | Later | |
| D13 | Virtual-card partner (e.g. Privacy.com) so trials *can't* charge | M | Later | Partnership |
| D14 | Cancel-for-me concierge | L | Later | Legal/ops heavy |

## E. Motivation & rewards
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| E1 | **"ADHD Tax Refunded"** counter front and center | S | MVP | Renamed per friend's plan: the community's own phrase |
| E2 | Celebration animation + haptic on cancel | S | MVP | Dopamine |
| E3 | Weekly "you saved $X" summary | S | v1.1 | |
| E4 | Milestone badges ($50, $100, $500 saved) | S | v1.1 | |
| E5 | Yearly "ADHD Tax Refunded" recap card, made to share | M | v1.1 | Viral moment; a static version works as the video's closing shot |
| E6 | Translate savings into things ("that's a concert ticket") | S | Later | |

## F. Social & growth
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| F1 | Shareable "I saved $X" card | S | v1.1 | Free marketing |
| F2 | Referral: both get a free month of Pro | S | v1.1 | |
| F3 | Invite an accountability buddy | M | v1.1 | Pairs with D8 |
| F4 | Household mode: couples/roommates share items | M | Later | |
| F5 | Parent mode for college students | M | Maybe | |

## G. Insights
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| G1 | Monthly: leaks caught vs missed | S | v1.1 | |
| G2 | Total recurring spend (what you chose to keep) | M | v1.1 | |
| G3 | Which services trap you most often | S | Later | |
| G4 | "You start a lot of trials" pattern warning | S | Later | |

## H. ADHD-friendly design rules
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| H1 | One screen, one decision | S | MVP | |
| H2 | Zero typing in the core flow | M | MVP | |
| H3 | Onboarding under 90 seconds | M | MVP | |
| H4 | No shame language, kind empty states | S | MVP | |
| H5 | Urgency through color and emoji, not red-alert anxiety | S | MVP | |
| H6 | Low-sensory mode (no animation/sound) | S | Later | |

## I. Privacy & trust
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| I1 | Only filtered emails forwarded; raw email deleted after parsing | S | MVP | |
| I2 | On-device extraction when the phone supports it | M | MVP | |
| I3 | No bank connection required | — | MVP | Competitive point vs Rocket Money |
| I4 | Export + delete all data | S | MVP | App Store requirement |
| I5 | Open-source code (required for Next Gen anyway) | — | MVP | Trust point |
| I6 | "What we stored about you" screen | S | v1.1 | |

## J. Monetization (RevenueCat)
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| J1 | Free: 5 items + manual/share capture · Pro: auto-capture, alarm, unlimited | S | MVP | |
| J2 | **$29.99 lifetime as the headline** + $3.99/mo + $24.99/yr | S | MVP | Friend's plan; matches Deadlinr's pay-once positioning |
| J2b | "We'd never charge a subscription to stop subscriptions" line on the paywall | S | MVP | Friend's plan |
| J2c | Demo purchases via RevenueCat Test Store (free Apple ID) or App Store sandbox ($99) | S | MVP | Test Store key must never be in release builds |
| J3 | We remind you before OUR trial ends | S | MVP | Trust + video moment |
| J4 | "Pays for itself" messaging using your saved $ | S | v1.1 | |
| J5 | Student discount | S | v1.1 | |
| J6 | Tip jar | S | Maybe | |

## K. Platforms
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| K1 | iPad | S | Later | |
| K2 | Apple Watch complication | M | Later | |
| K3 | Mac app | M | Later | |
| K4 | Desktop browser extension | M | Later | |
| K5 | Android | L | Later | Loses AlarmKit/widgets parity |
| K6 | Other languages | M | Later | |

## M. From the friend's battle plan (presentation & brand)
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| M1 | Video opens with a real notification getting swiped away | S | MVP | Shows the real problem in 5 seconds |
| M2 | ADHD community language in copy ("Wall of Awful," "out of sight, out of mind") | S | MVP | ⚠️ confirm attribution before crediting on screen |
| M3 | README "How RevenueCat is used" section | S | MVP | Maps to judging criterion 3 |
| M4 | Architecture diagram + code snippet shown in the video (3s each) | S | MVP | Criterion 4: "care in how it was built" |
| M5 | Celebration micro-interactions: haptics, confetti, smooth animations | M | MVP | Design polish |
| M6 | GitHub QR code on the video's final frame | S | MVP | Takes judges straight to the code |

## L. Wild ideas
| # | Idea | Effort | Tier | Notes |
|---|---|---|---|---|
| L1 | AI surfaces retention offers ("they'll give you 50% off to stay") | L | Later | |
| L2 | Community "how hard is it to cancel" rating per service (dark-pattern score) | M | Later | Network effect |
| L3 | One-tap report of a dark pattern to the FTC | S | Maybe | |
| L4 | Siri: "What's due this week?" | S | v1.1 | |
