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

    public init() {}

    private var current: FrozenTask? { tasks.first { $0.status == .active } }
    private var entries: [ScoreEntry] { records.map { ScoreEntry(kind: $0.kind, amountCents: $0.amountCents, date: $0.date) } }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing * 1.5) {
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
    }

    private var frozenButton: some View {
        Button { showingEntry = true } label: {
            VStack(spacing: 12) {
                Image(systemName: "snowflake")
                    .font(.system(size: 48, weight: .semibold))
                    .accessibilityHidden(true)
                Text("I'm frozen")
                    .font(.largeTitle.bold())
                Text("Tell me what's too big. I'll make the first step tiny.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .opacity(0.9)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .padding(.horizontal)
            .background(Theme.frozen.gradient, in: RoundedRectangle(cornerRadius: Theme.cornerRadius * 1.5))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Breaks a task into tiny steps")
    }

    private func resumeCard(_ task: FrozenTask) -> some View {
        Button { playing = task } label: {
            HStack {
                TaskRow(task: task)
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(Theme.frozen)
                    .accessibilityHidden(true)
            }
            .padding()
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Picks up where you left off")
    }

    private var scoreCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("ADHD Tax Refunded")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(ScoreMath.refundedCents(entries).formattedCents())
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundStyle(Theme.money)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Tasks unfrozen")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(ScoreMath.tasksUnfrozen(entries))")
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundStyle(Theme.frozen)
            }
        }
        .padding()
        .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [FrozenTask.self, MicroStep.self, CompletionRecord.self], inMemory: true)
}
