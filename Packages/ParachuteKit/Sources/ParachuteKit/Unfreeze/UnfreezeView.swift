import SwiftUI
import SharedKit
import AudioToolbox

public struct UnfreezeView: View {
    let plan: UnfreezePlan
    let onFinish: (UnfreezeOutcome) -> Void
    
    @State private var currentStepIndex: Int = -1 // -1 means Intro, plan.steps.count means Finish
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var companionLine: String = ""
    @State private var showingGiveUpConfirmation = false
    
    let companionLines = [
        "I'll wait right here.",
        "You're doing it.",
        "Just this one step.",
        "Almost there.",
        "One tiny thing. That's all.",
        "You've got this.",
        "No rush. I'm not going anywhere."
    ]
    
    public init(plan: UnfreezePlan, onFinish: @escaping (UnfreezeOutcome) -> Void) {
        self.plan = plan
        self.onFinish = onFinish
    }
    
    public var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            if currentStepIndex == -1 {
                introScreen
            } else if currentStepIndex < plan.steps.count {
                stepScreen(step: plan.steps[currentStepIndex])
            } else {
                finishScreen
            }
        }
        .animation(.easeInOut, value: currentStepIndex)
        .onAppear {
            pickCompanionLine()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    showingGiveUpConfirmation = true
                }
            }
        }
        .alert("Step away for now?", isPresented: $showingGiveUpConfirmation) {
            Button("Keep Going", role: .cancel) { }
            Button("Step Away", role: .destructive) {
                stopTimer()
                onFinish(.gaveUp)
            }
        } message: {
            Text("No judgment. You can always come back.")
        }
    }
    
    private var introScreen: some View {
        VStack(spacing: Theme.spacing * 2) {
            Spacer()
            
            Text("Let's do this.\nOne step at a time.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            if plan.isSuggested {
                Text("Suggested steps")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Button(action: nextStep) {
                Text("Start")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.frozen)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.cornerRadius)
            }
            .padding(.horizontal, Theme.spacing * 2)
            
            Text(companionLine)
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.bottom, Theme.spacing * 2)
        }
    }
    
    private func stepScreen(step: PlanStep) -> some View {
        VStack(spacing: Theme.spacing) {
            HStack {
                Text("Step \(currentStepIndex + 1) of \(plan.steps.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                if plan.isSuggested {
                    Text("Suggested")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding()
            
            Spacer()
            
            Text(step.text)
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            if step.seconds > 0 {
                ZStack {
                    Circle()
                        .stroke(Theme.frozen.opacity(0.3), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(step.seconds))
                        .stroke(Theme.frozen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: timeRemaining)
                    
                    Text("\(timeRemaining)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.frozen)
                }
                .frame(width: 100, height: 100)
                .padding()
            }
            
            Spacer()
            
            Button(action: nextStep) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Done")
                }
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.frozen)
                .foregroundColor(.white)
                .cornerRadius(Theme.cornerRadius)
            }
            .padding(.horizontal, Theme.spacing * 2)
            
            Button(action: nextStep) {
                Text("Skip")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
            
            Text(companionLine)
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.vertical, Theme.spacing * 2)
        }
        .id(currentStepIndex)
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
    }
    
    private var finishScreen: some View {
        VStack(spacing: Theme.spacing * 2) {
            Spacer()
            
            Image(systemName: "party.popper.fill")
                .font(.system(size: 60))
                .foregroundColor(Theme.frozen)
            
            Text("You did it!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Nice work following through.")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                onFinish(.completed)
            }) {
                Text("Finish")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.frozen)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.cornerRadius)
            }
            .padding(.horizontal, Theme.spacing * 2)
            .padding(.bottom, Theme.spacing * 2)
        }
    }
    
    private func nextStep() {
        stopTimer()
        currentStepIndex += 1
        pickCompanionLine()
        
        if currentStepIndex < plan.steps.count {
            let step = plan.steps[currentStepIndex]
            if step.seconds > 0 {
                timeRemaining = step.seconds
                startTimer()
            }
        }
    }
    
    private func pickCompanionLine() {
        companionLine = companionLines.randomElement() ?? companionLines[0]
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    AudioServicesPlaySystemSound(1005) // System alarm/beep
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
