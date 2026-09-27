import SwiftUI
import SwiftData
import SharedKit

public struct ScoreboardView: View {
    @Query(sort: \CompletionRecord.date, order: .reverse) private var records: [CompletionRecord]
    
    public init() {}
    
    private var totalRefunded: Int {
        records.filter { $0.kind == .moneyCancelled }.compactMap { $0.amountCents }.reduce(0, +)
    }
    
    private var tasksUnfrozen: Int {
        records.filter { $0.kind == .taskDone }.count
    }
    
    private var bestRun: Int {
        let dates = Set(records.map { Calendar.current.startOfDay(for: $0.date) }).sorted()
        guard !dates.isEmpty else { return 0 }
        
        var currentRun = 1
        var maxRun = 1
        
        for i in 1..<dates.count {
            if let days = Calendar.current.dateComponents([.day], from: dates[i-1], to: dates[i]).day, days == 1 {
                currentRun += 1
                maxRun = max(maxRun, currentRun)
            } else {
                currentRun = 1
            }
        }
        return maxRun
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing) {
                    if records.isEmpty {
                        emptyState
                    } else {
                        statsGrid
                        
                        Divider().padding(.vertical, Theme.spacing)
                        
                        historyList
                    }
                }
                .padding()
            }
            .navigationTitle("Scoreboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: shareWins) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(Theme.accent)
            Text("Nothing here yet — and that's okay. Your first win is one tap away.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
    
    private var statsGrid: some View {
        VStack(spacing: Theme.spacing) {
            HStack(spacing: Theme.spacing) {
                StatCard(
                    title: "ADHD Tax Refunded",
                    value: totalRefunded.formattedCents(currencyCode: "USD"),
                    color: Theme.money
                )
                
                StatCard(
                    title: "Tasks Unfrozen",
                    value: "\(tasksUnfrozen)",
                    color: Theme.frozen
                )
            }
            
            StatCard(
                title: "Best Run",
                value: "\(bestRun) \(bestRun == 1 ? "day" : "days")",
                color: Theme.accent
            )
        }
    }
    
    private var historyList: some View {
        VStack(alignment: .leading, spacing: Theme.spacing) {
            Text("Recent Wins")
                .font(.title2.bold())
            
            ForEach(records) { record in
                HStack {
                    VStack(alignment: .leading) {
                        Text(record.title)
                            .font(.headline)
                        Text(record.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if let amount = record.amountCents, record.kind == .moneyCancelled {
                        Text(amount.formattedCents(currencyCode: "USD"))
                            .foregroundColor(Theme.money)
                            .fontWeight(.semibold)
                    } else if record.kind == .taskDone {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.frozen)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(Theme.cornerRadius)
            }
        }
    }
    
    private func shareWins() {
        // Placeholder for sharing functionality
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(.title, design: .rounded).bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(Theme.cornerRadius)
    }
}
