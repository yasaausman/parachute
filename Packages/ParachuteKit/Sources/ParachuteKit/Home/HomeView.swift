import SharedKit
import SwiftData
import SwiftUI

/// The Home tab: one big "I'm frozen" button, the task to pick back up, and the refund total.
public struct HomeView: View {
    @Query(sort: \FrozenTask.createdAt, order: .reverse) private var tasks: [FrozenTask]
    @Query private var records: [CompletionRecord]
    @State private var showingEntry = false
    @State private var playing: FrozenTask?
    #if DEBUG
    @State private var showingDebug = false
    #endif

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var isLarge: Bool { dynamicTypeSize.isAccessibilitySize }

    public init() {}

    private var current: FrozenTask? { tasks.first { $0.status == .active } }
    private var entries: [ScoreEntry] { records.map { ScoreEntry(kind: $0.kind, amountCents: $0.amountCents, date: $0.date) } }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacing * 1.5) {
                    frozenButton
                    if let current { resumeCard(current) }
                    scoreCard
                }
                .padding()
            }
            .navigationTitle("Parachute")
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Debug", systemImage: "ladybug") { showingDebug = true }
                }
            }
            .sheet(isPresented: $showingDebug) { ParachuteDebugView() }
            #endif
            .sheet(isPresented: $showingEntry) { FrozenTaskEntryView() }
            .fullScreenCover(item: $playing) { task in
                TaskPlayerView(task: task) { playing = nil }
            }
        }
        .tint(Palette.frozenInk)
    }

    private var frozenButton: some View {
        Button { showingEntry = true } label: {
            HStack(alignment: .center, spacing: Theme.spacing) {
                VStack(alignment: .leading, spacing: 6) {
                    // At accessibility sizes the icon and chevron steal width from the words.
                    Label("I'm frozen", systemImage: "snowflake")
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .labelStyle(isLarge ? AnyLabelStyle(.titleOnly) : AnyLabelStyle(.titleAndIcon))
                    Text("Tell me what's too big. I'll make the first step tiny.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                if !isLarge {
                    Image(systemName: "chevron.right")
                        .font(.title3.weight(.semibold))
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Theme.spacing * 1.75)
            .padding(.horizontal, Theme.spacing * 1.25)
            .background(Palette.frozenFill, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Breaks a task into tiny steps")
    }

    private func resumeCard(_ task: FrozenTask) -> some View {
        Button { playing = task } label: {
            HStack {
                TaskRow(task: task)
                if !isLarge {
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundStyle(Palette.frozenInk)
                        .accessibilityHidden(true)
                }
            }
            .padding()
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Picks up where you left off")
    }

    /// Plain type, no box: the refund total is a fact about the day, not another card.
    private var scoreCard: some View {
        let tasks = ScoreMath.tasksUnfrozen(entries)
        return VStack(alignment: .leading, spacing: 2) {
            Text(ScoreMath.refundedCents(entries).formattedCents())
                .font(.system(.title, design: .rounded).bold().monospacedDigit())
                .foregroundStyle(Palette.moneyInk)
            Text("ADHD Tax Refunded · \(tasks) \(tasks == 1 ? "task" : "tasks") unfrozen")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [FrozenTask.self, MicroStep.self, CompletionRecord.self], inMemory: true)
}
