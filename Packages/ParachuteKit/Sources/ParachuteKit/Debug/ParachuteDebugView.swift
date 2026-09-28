#if DEBUG
import SharedKit
import SwiftData
import SwiftUI
import UIKit

/// Dev B's debug tools (Home → ladybug): seed demo data (P2) and run the B0 atomizer spike.
struct ParachuteDebugView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var seeded = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Reset & seed demo data") {
                        DemoDataSeeder.seed(in: context)
                        seeded = true
                    }
                } footer: {
                    Text(seeded ? "Seeded: $214.89 back · 12 tasks · best run 5 days." : "Replaces Parachute's wins and tasks. Adds trials only if there are none.")
                }
                Section {
                    NavigationLink("Run B0 atomizer spike") { AtomizerSpikeView() }
                } footer: {
                    Text("Runs the 30 inputs from docs/b0-atomizer-spike.md on this iPhone's on-device model.")
                }
            }
            .navigationTitle("Parachute debug")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

/// B0: runs every spike input through the real model (no fallbacks) and copies the results as Markdown.
struct AtomizerSpikeView: View {
    @State private var report = ""
    @State private var progress = 0
    @State private var running = false
    private let atomizer = AIAtomizer()

    static let tasks: [(String, Int)] = [
        ("Write a 1,500-word history essay on the causes of World War I", 3), ("Finish my FAFSA renewal", 5),
        ("Email my professor to ask for an extension on the lab report", 1), ("Write the lab report for chemistry (titration experiment)", 2),
        ("Apply for the summer internship at a marketing agency", 4), ("Write my college application personal statement (650 words)", 7),
        ("Renew my driver's license", 10), ("File my state and federal taxes", 6),
        ("Email my landlord about the broken heater", 1), ("Update my resume for a part-time job application", 2),
        ("Fill out the housing application for next semester", 3), ("Write a cover letter for a barista job", 2),
        ("Submit my scholarship application with two short essays", 5), ("Study for Friday's calculus midterm", 3),
        ("Make slides for my group project presentation", 2), ("Renew my passport", 14),
        ("Reply to my advisor's email about picking classes", 1), ("Submit my reimbursement form with receipts at work", 2),
        ("Write a 5-page reading response for English class", 4), ("Schedule a doctor's appointment and fill out the new-patient form", 3),
    ]
    static let services = [
        "Hulu", "Peacock", "Adobe Creative Cloud", "Audible", "Duolingo",
        "The New York Times", "Planet Fitness", "HelloFresh", "Paramount+", "LinkedIn Premium",
    ]

    var body: some View {
        List {
            Section {
                LabeledContent("Apple Intelligence", value: atomizer.isModelAvailable ? "Available" : "Unavailable")
                Button(running ? "Running \(progress)/30…" : "Run all 30") { Task { await run() } }
                    .disabled(running || !atomizer.isModelAvailable)
                if !report.isEmpty {
                    Button("Copy Markdown") { UIPasteboard.general.string = report }
                }
            }
            if !report.isEmpty {
                Section("Output") {
                    Text(report).font(.caption.monospaced()).textSelection(.enabled)
                }
            }
        }
        .navigationTitle("B0 spike")
    }

    private func run() async {
        running = true
        progress = 0
        var out = "## Raw output (\(Date.now.formatted(date: .abbreviated, time: .shortened)))\n\n"
        for (i, (title, days)) in Self.tasks.enumerated() {
            let steps = await atomizer.modelSteps(forTask: title, dueDate: .now.addingTimeInterval(Double(days) * 86_400))
            out += section("T\(i + 1)", title, steps)
            progress += 1
        }
        for (i, name) in Self.services.enumerated() {
            out += section("S\(i + 1)", "Cancel \(name)", await atomizer.modelSteps(forCancel: name))
            progress += 1
        }
        report = out
        running = false
    }

    private func section(_ id: String, _ input: String, _ steps: [PlanStep]?) -> String {
        guard let steps else { return "### \(id): \(input)\n_Model failed → fallback (counts as ❌)_\n\n" }
        let lines = steps.enumerated().map { "\($0 + 1). \($1.text) (\($1.seconds)s)" }.joined(separator: "\n")
        return "### \(id): \(input)\n\(lines)\n\n"
    }
}
#endif
