# A0 platform spike (Dev A)

**Goal:** prove the three platform bets on a real iPhone with a **free Apple ID** before building on them.
**Where:** Debug builds → **Debug** tab → *Platform spike* (`Packages/MoneyKit/Sources/MoneyKit/Spike/`). Throwaway code; delete it once A4/A8 land.

## Setup
1. `cp Config/Local.xcconfig.example Config/Local.xcconfig`, fill in your team ID + a bundle prefix that's unique to you.
2. RevenueCat (for part 3). Dashboard, [Test Store docs](https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store):
   - Create a project → **Apps and providers** → *Test configuration* → create a **Test Store**, and copy its API key.
   - A new project comes with Test Store products already made: `lifetime`, `yearly`, `monthly`, each attached to one entitlement, plus (check) a current offering. We use those instead of creating our own. Prices get set to the paywall plan ($29.99 lifetime, $24.99/yr, $3.99/mo) in A8.
   - `cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig` and paste the key. (Gitignored, Debug only: the SDK crashes release builds that use a Test Store key on purpose.)
3. Build + run on the iPhone. First run on a free account: Settings → General → VPN & Device Management → trust your developer certificate.

## Checks
| # | Check | Result | Notes |
|---|---|---|---|
| 1a | AlarmKit permission prompt appears (uses `NSAlarmKitUsageDescription`) | ✅ 2026-09-26 | Authorization → `authorized` |
| 1b | Alarm rings at the scheduled time with the phone **locked** and on **Silent** | ✅ 2026-09-26 | Scheduled 11:04:07 for 11:05:07, rang on time with Silent on |
| 1c | Alert shows **Stop** + **Decide** | ✅ 2026-09-26 | Locked: big orange **Decide** button (our tint) above a system **slide to stop**. Title and "Parachute" shown |
| 1d | **Stop** → `SpikeStopIntent` runs → rings again ~60 s later (log shows "Re-armed #n") | ✅ 2026-09-26 | Scheduled 11:09:20 → slide to stop 11:09:30 → Re-armed #1 → rang 11:10:30 → stop → Re-armed #2 → rang 11:11:34 → Decide 11:11:41 → cancelled. Stop is a **slide to stop** slider on the lock screen in iOS 27 |
| 1e | Stop works when the app has been **force-quit** first | ✅ 2026-09-26 | App force-quit, phone locked. Scheduled 11:19:06 for 11:20:06 → slide to stop 11:20:23 → `SpikeStopIntent` woke the app → Re-armed #1 for 11:21:23. An earlier run also showed Decide cold-launching the app |
| 1f | **Decide** opens the app on the spike screen; no more alarms | ✅ 2026-09-26 | Decide → app opened, `SpikeDecideIntent` ran, 1 alarm cancelled, no re-ring |
| 1g | Works with **no widget extension Live Activity** for the alarm (we only use a fixed-date alert, no countdown) | ✅ 2026-09-26 | Our widget extension has no alarm Live Activity; every alert above still presented |
| 2 | Local notification fires in 10 s; no capability needed on a free Apple ID | ✅ 2026-09-26 | Scheduled for 11:23:32, banner "Hulu · $17.99 leaves your account tomorrow." shown in the foreground (via `ForegroundNotificationPresenter`). Free team, no push capability. The icon is blank until we add an AppIcon |
| 3a | Test Store purchase sheet appears for the current offering | ✅ 2026-09-26 | iPhone 17 Pro Max, iOS 27.0. Sheet: "Test Store Purchase", Product ID `monthly`, $9.99 (RevenueCat default price) |
| 3b | Simulated success → `parachute_pro` entitlement active | ✅ 2026-09-26 | "Test valid purchase" → "Purchased. Active entitlements: parachute_pro" |
| 3c | Works without the In-App Purchase capability (free Apple ID) | ✅ 2026-09-26 | Free Personal Team, no IAP capability in the entitlements |

## Already verified (build time, 2026-09-25)
- ✅ AlarmKit API from the iOS 27 SDK's `AlarmKit.swiftinterface`: `AlarmManager.AlarmConfiguration.alarm(schedule:attributes:stopIntent:secondaryIntent:sound:)`; both intents are `LiveActivityIntent`; `Alert.SecondaryButtonBehavior` is `.countdown` or `.custom`. `Alert(title:stopButton:…)` is deprecated in iOS 26.1 (Stop is system-provided), so the spike uses `Alert(title:secondaryButton:secondaryButtonBehavior:)` behind `#available(iOS 26.1, *)`.
- ✅ Apple docs ([Scheduling an alarm with AlarmKit](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit)): *"If the `NSAlarmKitUsageDescription` key is missing or its value is an empty string, apps can't schedule alarms with AlarmKit."*
- ✅ App Intents defined in the MoneyKit **Swift package** reach the app: `SpikeStopIntent` and `SpikeDecideIntent` appear in `Parachute.app/Metadata.appintents` via `MoneyKitIntentsPackage` → `ParachuteAppIntentsPackage`.
- ✅ `openAppWhenRun` is deprecated in iOS 26 (*"Please provide 'supportedModes' instead"*), so Decide uses `supportedModes = .foreground`.
- ✅ Free personal team signs all three targets with the App Group `group.<prefix>.parachute` (checked with `codesign -d --entitlements`).

## Observations for A4 (the real alarm)
- **Locked:** full screen. Title, time, app name, a big tinted **Decide** button, and a system **slide to stop** at the bottom. Users hit Decide by accident (happened twice in testing), which is fine: Decide is the "good" path.
- **Unlocked:** a compact banner at the top: app icon (alarm clock in our tint), "Parachute", the title, then **only icons**: our secondary button's SF Symbol (`hand.raised.fill`) and an **X** (Stop). The button *text* "Decide" isn't shown, so the symbol must carry the meaning on its own. ✅ The banner's **X** runs `stopIntent` exactly like the slider (11:28:42 Stop tapped → Re-armed #1 → 11:29:46 Decide → cancelled; read from the App Group plist on the device).
- **The app doesn't see intent changes while it's open.** Stop/Decide ran in the app's process and wrote the log, but the spike screen only refreshes on `scenePhase == .active`, so it looked like nothing happened. A4/A5 must observe `AlarmManager.alarmUpdates` (or an in-process change signal) so the UI updates live.
- The title is the whole message on both surfaces: keep it money-first and short ("Hulu charges $17.99 today" fits on two lines).

## Result
✅ **A0 passed (2026-09-26), 11/11, on a free Apple ID** (iPhone 17 Pro Max, iOS 27.0).
- **AlarmKit:** rings on Silent, locked or unlocked. Stop (slide or banner X) runs `stopIntent`, which re-arms even when the app was force-quit; Decide runs `secondaryIntent`, cold-launches the app and ends the chain. No Live Activity widget needed for a fixed-date alarm. The A4 design (CLAUDE.md rule 2) works as planned.
- **Local notifications:** work with no capability.
- **RevenueCat Test Store:** purchase sheet + `parachute_pro` entitlement, no In-App Purchase capability.
- **No workarounds needed.** Carry into A4: a clearer secondary-button symbol, live UI updates via `alarmUpdates`, and the iOS 27 "Alarms and Timers" volume (a user setting we can't override; ⚠️ not yet tested at zero).
