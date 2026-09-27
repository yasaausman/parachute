import SwiftUI
import SwiftData
import SharedKit

public struct FrozenTaskEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var unfreezeProvider: any UnfreezeProviding
    
    @State private var taskTitle: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var isRequestingPlan: Bool = false
    @State private var createdTask: FrozenTask?
    @State private var generatedPlan: UnfreezePlan?
    @State private var navigateToPlan: Bool = false
    
    public init(unfreezeProvider: any UnfreezeProviding) {
        self.unfreezeProvider = unfreezeProvider
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("It's okay. Let's break this down together.")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Theme.frozen)
                        .padding(.top, 40)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's overwhelming you?")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("e.g. 8-page essay due at midnight", text: $taskTitle, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(Theme.cornerRadius)
                            .font(.body)
                    }
                    
                    Toggle("I have a deadline", isOn: $hasDueDate)
                        .tint(Theme.frozen)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate)
                            .datePickerStyle(.compact)
                            .tint(Theme.frozen)
                    }
                    
                    Spacer(minLength: 40)
                    
                    Button(action: helpMeStart) {
                        HStack {
                            if isRequestingPlan {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Help me start")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : Theme.frozen)
                        .foregroundColor(.white)
                        .cornerRadius(Theme.cornerRadius)
                    }
                    .disabled(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isRequestingPlan)
                }
                .padding()
            }
            .navigationTitle("I'm frozen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToPlan) {
                if let plan = generatedPlan {
                    UnfreezeView(plan: plan) { outcome in
                        // Handle outcome — update the task status
                        if let task = createdTask {
                            switch outcome {
                            case .completed:
                                task.status = .done
                                task.steps.forEach { step in
                                    if step.doneAt == nil { step.doneAt = .now }
                                }
                            case .gaveUp:
                                task.status = .abandoned
                            case .snoozed:
                                break // task stays active
                            }
                            try? modelContext.save()
                        }
                        dismiss()
                    }
                    .navigationBarBackButtonHidden()
                }
            }
        }
    }
    
    private func helpMeStart() {
        guard !taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isRequestingPlan = true
        
        Task {
            do {
                let request = UnfreezeRequest.task(title: taskTitle, dueDate: hasDueDate ? dueDate : nil)
                let plan = try await unfreezeProvider.plan(for: request)
                
                await MainActor.run {
                    let newTask = FrozenTask(title: taskTitle, dueDate: hasDueDate ? dueDate : nil)
                    modelContext.insert(newTask)
                    try? modelContext.save()
                    
                    self.createdTask = newTask
                    self.generatedPlan = plan
                    self.isRequestingPlan = false
                    self.navigateToPlan = true
                }
            } catch {
                await MainActor.run {
                    isRequestingPlan = false
                    // Error handling logic would go here
                }
            }
        }
    }
}
