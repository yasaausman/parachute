import SharedKit
import SwiftUI

/// B1: one step on screen, a soft 90-second ring, a companion line, and Done / Break it smaller / Skip.
///
/// Gating (B10): curated and Apple-settings plans are free. AI plans show step 1 free, then an upsell.
/// Voice + ambient sound are Pro. "Break it smaller" is never blocked; nobody gets stuck mid-freeze.
public struct UnfreezeView: View {
    private let goal: String
    private let isAIPlan: Bool
    private let win: CelebrationView.Win?
    private let onProgress: ((_ steps: [PlanStep], _ nextIndex: Int) -> Void)?
    private let onFinish: (UnfreezeOutcome) -> Void

    @Environment(\.parachute) private var services
    @Environment(\.openURL) private var openURL
    @ScaledMetric(relativeTo: .title) private var ringSize: CGFloat = 110

    @State private var steps: [PlanStep]
    @State private var isSuggested: Bool
    @State private var index: Int
    @State private var started: Bool
    @State private var stepToken = 0
    @State private var remaining = 0
    @State private var line = CompanionLine.random()
    @State private var isBreaking = false
    @State private var isPro = false
    @State private var audio = AudioCompanion()
    @State private var confirmingStepAway = false
    @State private var celebrating = false

    /// - Parameters:
    ///   - goal: what this is for ("Cancel Hulu", "History essay"), used by "Break it smaller".
    ///   - startAt: resume a saved task at this step.
    ///   - win: shown with confetti at the end; defaults to "+1 task unfrozen".
    ///   - onProgress: the (possibly re-split) steps and the index of the next undone step.
    public init(
        plan: UnfreezePlan,
        goal: String = "",
        startAt: Int = 0,
        win: CelebrationView.Win? = nil,
        onProgress: ((_ steps: [PlanStep], _ nextIndex: Int) -> Void)? = nil,
        onFinish: @escaping (UnfreezeOutcome) -> Void
    ) {
        self.goal = goal
        self.isAIPlan = plan.source == .ai
        self.win = win ?? .task(title: goal)
        self.onProgress = onProgress
        self.onFinish = onFinish
        let start = min(max(startAt, 0), plan.steps.count)
        _steps = State(initialValue: plan.steps)
        _isSuggested = State(initialValue: plan.isSuggested)
        _index = State(initialValue: start)
        _started = State(initialValue: start > 0)
    }

    public var body: some View {
        VStack(spacing: 0) {
            topBar
            Group {
                if !started {
                    intro
                } else if index >= steps.count {
                    finish
                } else if needsUpsell {
                    upsell
                } else {
                    stepScreen(steps[index])
                        .id(stepToken)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .animation(.easeInOut(duration: 0.35), value: stepToken)
        .animation(.easeInOut(duration: 0.35), value: started)
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if celebrating, let win {
                CelebrationView(win: win) { celebrating = false }
                    .transition(.opacity)
            }
        }
        .task { isPro = await services.entitlements.isPro }
        .task(id: stepToken) { await runCountdown() }
        .sensoryFeedback(.impact(weight: .light), trigger: remaining) { old, new in old == 1 && new == 0 }
        .onChange(of: isPro) { _, pro in
            if pro, started { showStep() }
        }
        .onDisappear { audio.stop() }
        .confirmationDialog("Step away for now?", isPresented: $confirmingStepAway, titleVisibility: .visible) {
            Button("Keep going", role: .cancel) {}
            Button("Remind me in an hour") { leave(.snoozed(until: .now.addingTimeInterval(3600))) }
            Button("Step away") { leave(.gaveUp) }
        } message: {
            Text("No judgment. Your progress is saved.")
        }
    }

    // MARK: - Screens

    private var topBar: some View {
        HStack {
            Button {
                if index >= steps.count { leave(.completed) } else { confirmingStepAway = true }
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .padding(12)
                    .background(.fill.tertiary, in: Circle())
            }
            .accessibilityLabel("Close")

            Spacer()

            if started, index < steps.count {
                Text("Step \(index + 1) of \(steps.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                audioMenu
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .tint(.primary)
    }

    private var audioMenu: some View {
        Menu {
            Button {
                requirePro {
                    audio.setVoice(!audio.isVoiceOn)
                    speakCurrent()
                }
            } label: {
                Label(audio.isVoiceOn ? "Stop reading aloud" : "Read steps aloud", systemImage: "waveform")
            }
            Button {
                requirePro { audio.setAmbient(!audio.isAmbientOn) }
            } label: {
                Label(audio.isAmbientOn ? "Stop background sound" : "Calm background sound", systemImage: "cloud.rain")
            }
            if !isPro {
                Text("Voice and sound are part of Parachute Pro.")
            }
        } label: {
            Image(systemName: audio.isVoiceOn || audio.isAmbientOn ? "speaker.wave.2.fill" : "speaker.slash")
                .font(.body.weight(.semibold))
                .padding(12)
                .background(.fill.tertiary, in: Circle())
        }
        .accessibilityLabel("Companion sound")
    }

    private var intro: some View {
        VStack(spacing: Theme.spacing * 2) {
            Spacer()
            Image(systemName: "snowflake")
                .font(.system(size: 56))
                .foregroundStyle(Theme.frozen)
                .accessibilityHidden(true)
            Text("Let's do this.\nOne tiny step at a time.")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            if !goal.isEmpty {
                Text(goal)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if isSuggested { suggestedBadge }
            Spacer()
            primaryButton("Start", systemImage: "play.fill") {
                started = true
                showStep()
            }
            Text(line)
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .padding()
    }

    private func stepScreen(_ step: PlanStep) -> some View {
        VStack(spacing: Theme.spacing) {
            ScrollView {
                VStack(spacing: Theme.spacing * 1.5) {
                    if isSuggested { suggestedBadge }
                    Text(step.text)
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    if let url = step.url {
                        Button {
                            openURL(url)
                        } label: {
                            Label("Open the page", systemImage: "safari")
                                .font(.headline)
                        }
                        .buttonStyle(.bordered)
                        .tint(Theme.frozen)
                    }
                    ring(total: step.seconds)
                    Text(remaining == 0 ? "Take all the time you need." : line)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                .padding(.top, Theme.spacing * 2)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)

            VStack(spacing: 4) {
                primaryButton("Done", systemImage: "checkmark") { advance() }
                HStack {
                    Button {
                        Task { await breakSmaller() }
                    } label: {
                        if isBreaking {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Label("Break it smaller", systemImage: "scissors")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isBreaking)
                    .accessibilityHint("Splits this step into even smaller ones")
                    Button("Skip") { advance() }
                        .frame(maxWidth: .infinity)
                        .accessibilityHint("Moves on without this step")
                }
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.vertical, 10)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    private func ring(total: Int) -> some View {
        let size = min(ringSize, 180)
        return ZStack {
            Circle().stroke(Theme.frozen.opacity(0.2), lineWidth: 8)
            Circle()
                .trim(from: 0, to: total > 0 ? CGFloat(remaining) / CGFloat(total) : 0)
                .stroke(Theme.frozen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remaining)
            if remaining > 0 {
                Text("\(remaining)")
                    .font(.title.bold().monospacedDigit())
                    .foregroundStyle(Theme.frozen)
                    .contentTransition(.numericText(countsDown: true))
            } else {
                Image(systemName: "hourglass")
                    .font(.title)
                    .foregroundStyle(Theme.frozen)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel(remaining > 0 ? "About \(remaining) seconds" : "No rush")
    }

    private var upsell: some View {
        VStack(spacing: Theme.spacing * 1.5) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.money)
                .accessibilityHidden(true)
            Text("Step 1: done.")
                .font(.largeTitle.bold())
            Text("You're already moving. Parachute Pro walks you through the rest of any task, and any service.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            primaryButton("Keep going with Pro", systemImage: "sparkles") {
                services.entitlements.presentPaywall()
            }
            Button("Stop here for now") { leave(.snoozed(until: .now.addingTimeInterval(3600))) }
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .padding()
        .task {
            // Pick up a purchase made on the paywall without making anyone tap again.
            while !isPro, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.5))
                isPro = await services.entitlements.isPro
            }
        }
    }

    private var finish: some View {
        VStack(spacing: Theme.spacing * 2) {
            Spacer()
            Image(systemName: "party.popper.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.frozen)
                .accessibilityHidden(true)
            Text("You did it.")
                .font(.largeTitle.bold())
            Text("That was the hard part, and you did it anyway.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            primaryButton("Finish", systemImage: "checkmark") { leave(.completed) }
                .padding(.bottom)
        }
        .padding()
        .onAppear {
            audio.stop()
            celebrating = true
        }
    }

    private var suggestedBadge: some View {
        Label("Suggested steps", systemImage: "sparkles")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.fill.tertiary, in: Capsule())
            .accessibilityLabel("Suggested steps, made on this iPhone. Double-check before you tap anything that costs money.")
    }

    private func primaryButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Theme.frozen)
    }

    // MARK: - Flow

    private var needsUpsell: Bool { isAIPlan && !isPro && index >= 1 }

    private func showStep() {
        line = CompanionLine.random()
        stepToken += 1
        speakCurrent()
    }

    private func advance() {
        index += 1
        onProgress?(steps, index)
        showStep()
    }

    private func breakSmaller() async {
        guard index < steps.count else { return }
        isBreaking = true
        let smaller = await services.engine.smallerSteps(for: steps[index], goal: goal)
        isBreaking = false
        guard !smaller.isEmpty else { return }
        steps = PlanEditing.replace(stepAt: index, in: steps, with: smaller)
        isSuggested = true
        onProgress?(steps, index)
        showStep()
    }

    private func runCountdown() async {
        guard started, index < steps.count else { return }
        remaining = steps[index].seconds
        while remaining > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            remaining -= 1
        }
    }

    private func speakCurrent() {
        guard index < steps.count else { return }
        audio.speak(steps[index].text)
    }

    private func requirePro(_ action: () -> Void) {
        if isPro { action() } else { services.entitlements.presentPaywall() }
    }

    private func leave(_ outcome: UnfreezeOutcome) {
        audio.stop()
        onFinish(outcome)
    }
}

enum CompanionLine {
    static let all = [
        "I'll wait right here.",
        "Just this one step.",
        "One tiny thing. That's all.",
        "No rush. I'm not going anywhere.",
        "Messy counts. Done counts.",
        "You don't have to feel ready.",
        "Tiny steps still move you.",
    ]

    static func random() -> String { all.randomElement() ?? all[0] }
}

#Preview("AI plan") {
    UnfreezeView(
        plan: UnfreezePlan(steps: Fallbacks.task("History essay"), source: .ai, isSuggested: true),
        goal: "History essay"
    ) { _ in }
}
