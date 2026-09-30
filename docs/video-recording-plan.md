# Video recording plan (V1), 2026-09-29

Device: **Dev A's iPhone 17 Pro Max (iOS 27.0, has Apple Intelligence)** is preferred, so the AI steps and screenshot reading on camera are real; the iPhone 14 Pro (iOS 27.0.1) only shows the non-AI fallbacks. Debug build. Record with QuickTime (File → New Movie Recording → pick the iPhone) or the phone's Screen Recording. Keep the demo under 2:00; script is `docs/demo-script.md`.

## Before recording
- [ ] **Paywall plans load** on the phone (open it once). If it says "Plans didn't load", check the RevenueCat `default` offering still has its 3 Test Store products (the simulator showed "no Test Store products" on 2026-09-30).
- [ ] Debug → **Pro for testing → Real** after testing, and reseed demo data from Home → ladybug so the totals are the seed values.
- [ ] Delete any old "Parachute" app icon from earlier installs on the phone; the app is now **Untax** with the coral receipt icon.
- [ ] Phone: Do Not Disturb **off**, brightness up, battery > 50%, clear the Home Screen of clutter, silent switch off (alarm and voice audio).
- [ ] Settings → Notifications → Untax: allow, Time Sensitive not needed. AlarmKit: allow when prompted.
- [ ] Debug tab → **clear**, then **seed demo data** (shows $214.89 · 12 tasks · 5-day best run). Say "demo data" nowhere on screen, but don't claim it's real earnings in the voiceover.
- [ ] Add the Untax widget to the Home Screen (money countdown) and check it shows a trial.
- [ ] Add 2 trials for the money flow: one **Apple-billed** (only if showing Apple's Subscriptions page) and Claude Pro or Spotify (has hand-verified steps).
- [ ] Screenshot of a trial confirmation saved in Photos for the share-sheet shot.
- [ ] Pro toggle: turn Pro **on** in Debug for the flow, **off** for the paywall shot. Use Debug → **Pro for testing → Pretend free** for the paywall shot (works on a phone that already bought Pro); a purchase on the paywall flips it back to Real, so Pro unlocks on camera.
- [ ] Force-quit the app before the alarm shot so the cold-launch Decide path is what's on camera.

## Shots (record each 3×, keep the best)
| # | Segment | What to do on the phone | Notes |
|---|---|---|---|
| 1 | Two taxes (0:05) | Lock screen: a "trial ends tomorrow" notification, swipe it away | Use a real Untax reminder |
| 2 | Money flow (0:22) | Photos → Share → Untax → "Track it?" → save; Home Screen widget; Debug "ring in 1 minute" alarm on the lock screen → **Stop** → (cut) → **Decide** → Get unstuck → steps → confetti → Refunded | Alarm breaks through Silent, which is worth a caption |
| 2b | Home (0:20) | Home tab: coral "Next charge" ticket counting down, refunded total counting up, "Get unstuck" card | Open Home fresh so the count-up plays |
| 3 | Task flow (0:42) | Home → Get unstuck → type "History essay due at midnight" → steps → Done, Done | See the AI caveat below |
| 4 | Scoreboard (1:00) | Refunded tab (receipt) → Share my wins (coral receipt card) | The confetti after the last Done lasts ~4 s; let it play |
| 5 | Paywall (1:10) | Pro off → add a 6th trial → paywall ($29.99 lifetime, banner) | Test Store purchase works; you can tap Buy on camera |
| 6 | Tech (1:25) | Screen-record on the Mac: architecture diagram, `@Generable` atomizer code, README | |

## Things to not claim (this phone can't back them up)
- **Apple Intelligence:** the iPhone 14 Pro doesn't have it, so the task steps on camera are the **non-AI fallback templates**, and screenshot reading uses pattern matching. The script's "Apple's on-device Foundation Models … runs locally" line must either be dropped or be shown from a device that supports it. Don't show fallback steps while saying they're AI-written.
- **Purchase:** a Test Store purchase works on the phone (2026-09-29), so it can be shown on camera. Say "test purchase"; the Test Store charges nothing.
- **Numbers:** only the 79% / $45 per month / 15.5M stats from CLAUDE.md rule 11.
- The refunded total in the video is seed data. Don't call it "my savings".

## After recording
- [ ] Captions on every spoken line; device frame; under 2:00.
- [ ] Export 1080p+ and upload as an unlisted YouTube video; put the link in the Devpost draft.
