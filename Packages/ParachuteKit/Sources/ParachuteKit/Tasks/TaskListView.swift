import SwiftUI
import SwiftData
import SharedKit

public struct TaskListView: View {
    @Query(sort: \FrozenTask.createdAt, order: .reverse) private var tasks: [FrozenTask]
    @Environment(\.modelContext) private var modelContext
    
    var unfreezeProvider: any UnfreezeProviding
    
    @State private var showingAddView = false
    
    public init(unfreezeProvider: any UnfreezeProviding) {
        self.unfreezeProvider = unfreezeProvider
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(tasks) { task in
                            TaskRow(task: task)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddView = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Theme.frozen)
                    }
                }
            }
            .sheet(isPresented: $showingAddView) {
                FrozenTaskEntryView(unfreezeProvider: unfreezeProvider)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "snow")
                .font(.system(size: 60))
                .foregroundColor(Theme.frozen)
            Text("No tasks yet.\nTap 'I'm frozen' whenever something feels too big to start.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: { showingAddView = true }) {
                Text("I'm frozen")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.frozen)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.cornerRadius)
            }
            .padding(.top, 20)
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

private struct TaskRow: View {
    let task: FrozenTask
    
    private var completedSteps: Int {
        task.steps.filter { $0.doneAt != nil }.count
    }
    
    private var totalSteps: Int {
        max(task.steps.count, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.headline)
                Spacer()
                statusBadge
            }
            
            if let dueDate = task.dueDate {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            if !task.steps.isEmpty {
                ProgressView(value: Double(completedSteps), total: Double(totalSteps))
                    .tint(Theme.frozen)
                
                HStack {
                    Text("\(completedSteps)/\(task.steps.count) steps")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(Theme.cornerRadius)
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        let label: String = switch task.status {
        case .active: "Active"
        case .done: "Done"
        case .abandoned: "Abandoned"
        }
        Text(label)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch task.status {
        case .active: Theme.frozen
        case .done: Theme.money
        case .abandoned: .secondary
        }
    }
}
