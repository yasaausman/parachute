import SharedKit
import SwiftData
import SwiftUI

/// The Home tab: one big "Get unstuck" button, the task to pick back up, and the refund total.
public struct HomeView: View {
    @Query(sort: \FrozenTask.createdAt, order: .reverse) private var tasks: [FrozenTask]
    @Query private var records: [CompletionRecord]
    @Query(sort: \MoneyDeadline.dueDate) private var deadlines: [MoneyDeadline]
    @State private var showingEntry = false
    @State private var playing: FrozenTask?
    #if DEBUG
    @State private var showingDebug = false
    #endif

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var isLarge: Bool { dynamicTypeSize.isAccessibilitySize }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shownCents = 0

    /// Opens Decide for a money deadline. The app target wires this to MoneyKit's router.
    private let onOpenDeadline: ((UUID) -> Void)?

    public init(onOpenDeadline: ((UUID) -> Void)? = nil) {
        self.onOpenDeadline = onOpenDeadline
    }

    /// The soonest trial still waiting on a decision.
    private var nextDeadline: MoneyDeadline? {
        deadlines.first { ($0.status == .tracking || $0.status == .snoozed) && $0.dueDate > .now }
    }

    private var current: FrozenTask? { tasks.first { $0.status == .active } }
    private var entries: [ScoreEntry] { records.map { ScoreEntry(kind: $0.kind, amountCents: $0.amountCents, date: $0.date) } }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacing * 1.5) {
                    if let nextDeadline { NextChargeTicket(deadline: nextDeadline) { onOpenDeadline?(nextDeadline.id) } }
                    scoreCard
                    frozenButton
                    if let current { resumeCard(current) }
                }
                .padding(.horizontal, Theme.screenPadding)
                .padding(.vertical, Theme.spacing)
            }
            .untaxScreen()
            .navigationTitle("Untax")
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
        .tint(Theme.accentText)
    }

    private var frozenButton: some View {
        Button { showingEntry = true } label: {
            HStack(alignment: .center, spacing: Theme.spacing) {
                VStack(alignment: .leading, spacing: 6) {
                    // At accessibility sizes the icon and chevron steal width from the words.
                    Label("Get unstuck", systemImage: "snowflake")
                        .font(Theme.display())
                        .labelStyle(isLarge ? AnyLabelStyle(.titleOnly) : AnyLabelStyle(.titleAndIcon))
                    Text("Untax your brain, too. One tiny step at a time.")
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
            .background(Theme.frozenFill, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
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
                        .foregroundStyle(Theme.frozenText)
                        .accessibilityHidden(true)
                }
            }
            .untaxCard()
        }
        .buttonStyle(.plain)
        .accessibilityHint("Picks up where you left off")
    }

    /// Plain type, no box: the refund total leads the screen, in mono like a receipt total.
    private var scoreCard: some View {
        let tasks = ScoreMath.tasksUnfrozen(entries)
        return VStack(alignment: .leading, spacing: 4) {
            Text("ADHD TAX REFUNDED")
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(Theme.inkMuted)
            Text(shownCents.formattedCents())
                .font(Theme.number(.largeTitle).monospacedDigit())
                .contentTransition(.numericText(value: Double(shownCents)))
                .foregroundStyle(Theme.moneyText)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text("\(tasks) \(tasks == 1 ? "task" : "tasks") unfrozen")
                .font(.subheadline)
                .foregroundStyle(Theme.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        // Count up to the total so the win lands every time Home appears.
        .onAppear { countUp(to: ScoreMath.refundedCents(entries)) }
        .onChange(of: ScoreMath.refundedCents(entries)) { _, total in countUp(to: total) }
    }

    private func countUp(to total: Int) {
        guard !reduceMotion else { shownCents = total; return }
        shownCents = 0
        withAnimation(.snappy(duration: 0.9).delay(0.15)) { shownCents = total }
    }
}

/// The coral ticket for the next charge: live countdown, torn receipt edge, tap to decide.
private struct NextChargeTicket: View {
    let deadline: MoneyDeadline
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("NEXT CHARGE")
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .tracking(1.5)
                    Spacer()
                    Text(deadline.amountCents.formattedCents(currencyCode: deadline.currencyCode))
                        .font(.system(.headline, design: .monospaced, weight: .bold).monospacedDigit())
                }
                .foregroundStyle(.white.opacity(0.9))
                Text("\(deadline.serviceName) charges you in")
                    .font(Theme.headline(.title2))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(countdown(from: context.date))
                        .font(Theme.number(.largeTitle).monospacedDigit())
                        .foregroundStyle(.white)
                        .contentTransition(.numericText(countsDown: true))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                HStack(spacing: 6) {
                    Text("Tap to decide")
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.spacing * 1.25)
            .padding(.top, Theme.spacing * 1.25)
            .padding(.bottom, Theme.spacing * 1.25 + 10)
            .background(ReceiptShape(tooth: 10).fill(Theme.accentFill))
            .contentShape(ReceiptShape(tooth: 10))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens Decide: cancel, keep, or snooze")
    }

    /// Calendar days to match Decide ("3 days"); a ticking "14:03:22" on the last day.
    private func countdown(from now: Date) -> String {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: now), to: cal.startOfDay(for: deadline.dueDate)).day ?? 0
        if days >= 2 { return "\(days) days" }
        let seconds = max(0, Int(deadline.dueDate.timeIntervalSince(now)))
        let hours = seconds / 3_600, minutes = (seconds % 3_600) / 60, secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [FrozenTask.self, MicroStep.self, CompletionRecord.self, MoneyDeadline.self], inMemory: true)
}
