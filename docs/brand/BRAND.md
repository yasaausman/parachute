# Untax brand guidelines

**Untax** (formerly Parachute) catches money deadlines (free trials) and walks you out of freeze mode, one tiny step at a time. Every win lands on the **ADHD Tax Refunded** receipt.

- **Tagline:** Get your ADHD tax back.
- **Short pitch:** Untax catches your free trials before they charge you, and gets you unstuck when you freeze.
- **Name usage:** always lowercase `untax` in the wordmark; "Untax" in sentences. Never "UnTax", "UNTAX", or "Un-tax".
- **Modes inside the app:** *Untax* (money deadlines) and *Unfreeze* (the step-by-step player). "Parachute" is retired from all user-facing copy. Code module names (`ParachuteKit`, etc.) stay as they are.

## Logo

| File | Use |
|---|---|
| `untax-icon.svg` / `untax-icon-1024.png` | App icon (coral field, receipt, refund arrow). Source for `AppIcon.png`. |
| `untax-mark.svg` | The refund-arrow-around-$ mark alone, for small inline use on paper backgrounds. |
| `untax-wordmark.svg` | Horizontal lockup: icon + `untax` + tagline. Video title card, README header, Devpost. |

**The idea:** a receipt with a dollar sign coming back around. Money that forgetfulness took, returned. The green line on the receipt is the refund.

**Rules**
- Clear space around the icon: at least 1/4 of its width.
- Minimum size: mark 20pt, wordmark 120pt wide.
- Don't recolor the mark to anything but Ink or Paper. Don't add gradients, shadows, or outlines. Don't rotate the arrow.
- On dark backgrounds, use the icon (it carries its own coral field) or a Paper-colored mark.

## Color

One accent (Coral) on warm neutrals. Green only ever means money you got back. Teal only ever means Unfreeze mode.

| Token | Light | Dark | Role |
|---|---|---|---|
| `paper` | `#FAF7F2` | `#141210` | Background |
| `surface` | `#FFFFFF` | `#1F1C19` | Receipt / raised surfaces |
| `ink` | `#1A1714` | `#F2EEE8` | Primary text (16.7:1) |
| `inkMuted` | `#6B645C` | `#A39B91` | Secondary text (5.5:1 / 6.2:1) |
| `coral` | `#E8472B` | `#E8472B` | Brand field, icon, large display only (Ink on coral 4.6:1) |
| `coralText` | `#C2381F` | `#FF7A5C` | Accent text and icons (5.1:1 / 6.6:1) |
| `coralFill` | `#C2381F` | `#C2381F` | Behind white text: primary buttons (5.4:1) |
| `refund` | `#1E7A35` | `#30D158` | Refunded amounts, "saved" states (5.1:1 / 8.4:1) |
| `unfreeze` | `#006E8C` | `#32D2F5` | Unfreeze mode text/icons (5.4:1 / 9.4:1) |
| `urgent` | `#C4281C` | `#FF453A` | ≤ 1 day left. Use sparingly. |

Never put white body text on `coral` (#E8472B): 3.9:1 fails. Use `coralFill` for buttons.

## Type

All system fonts, no bundling.

| Role | SwiftUI | Use |
|---|---|---|
| Display | `.system(.largeTitle, design: .rounded, weight: .heavy)` | Screen titles, the big refunded total |
| Headline | `.system(.title3, design: .rounded, weight: .bold)` | Card titles, step text in the player |
| Body | `.body` (SF Pro) | Everything else |
| Numbers | `.system(.title, design: .monospaced, weight: .semibold)` + `.monospacedDigit()` | Dollar amounts, countdowns, receipt lines |

Keep Dynamic Type working: use text styles, not fixed sizes.

## Shape and space

- 8pt grid. Screen padding 20, stack spacing 12/16/24.
- Radius: 14 on buttons and cards. Receipt surfaces get a torn (zigzag) bottom edge instead of a bottom radius.
- One elevation: a 1pt `ink` 8% hairline border. No drop shadows except the celebration share card.
- Touch targets ≥ 44pt. Primary button height 54.

## Signature: the receipt

The ADHD Tax Refunded scoreboard is a receipt: mono line items (`Netflix trial … $15.49`), a dashed divider, a big mono **TOTAL REFUNDED** in `refund` green, and a torn bottom edge. Each new win gets a rotated "REFUNDED" stamp. Use the receipt look only for the scoreboard and share card, so it stays special.

## Voice

Warm, plain, a little funny, never shaming. We're the friend who texts "hey, that trial ends tomorrow", not a bank.

| Do | Don't |
|---|---|
| "Netflix bills you tomorrow. Want out?" | "WARNING: You will be charged!" |
| "Frozen? Totally normal. Here's one tiny step." | "You still haven't done this." |
| "Best run: 4 days" | "You lost your streak." |
| "$15.49 back in your pocket." | "You wasted $15.49." |

**Allowed stats only:** 79% of Americans started a trial meaning to cancel and got charged; $45/month on forgotten trials (Dimers, Sep 2026); 15.5M US adults with ADHD (CDC). Never "$1,900/yr", "$15–20k/yr", "thousands a year", or "48%".
