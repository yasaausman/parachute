import SharedKit
import SwiftData
import SwiftUI
import TrialCapture

/// A7: the share sheet. Screenshot or text in → "Found: Spotify · $11.99 · Oct 26. Track it?"
/// One tap saves. Anything missing or wrong is editable right there (CLAUDE.md rule 3).
public struct TrackTrialView: View {
    public enum Input: Sendable {
        case image(Data)
        case text(String)
        case nothing
    }

    enum Phase: Equatable {
        case reading
        case ready(TrialCandidate.Source)
        case saved
    }

    private let load: @Sendable () async -> Input
    private let onDone: () -> Void

    @State private var phase: Phase = .reading
    @State private var serviceName = ""
    @State private var amount: Decimal?
    @State private var chargeDate = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var billedByApple = false
    @State private var editing = false
    @State private var saveFailed = false
    @State private var overLimit = false
    /// No price and no charge date: probably not a trial screen (e.g. a list of cancelled subscriptions).
    @State private var foundNothing = false

    public init(load: @escaping @Sendable () async -> Input, onDone: @escaping () -> Void) {
        self.load = load
        self.onDone = onDone
    }

    private var canSave: Bool {
        !serviceName.trimmingCharacters(in: .whitespaces).isEmpty && (amount ?? 0) > 0
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch phase {
                case .reading:
                    ProgressView("Reading it…")
                case .ready(let source):
                    form(source: source)
                case .saved:
                    ContentUnavailableView {
                        Label("Tracking \(serviceName)", systemImage: "checkmark.circle.fill")
                    } description: {
                        Text("Parachute will remind you before the charge. Open the app once to arm the final-day alarm.")
                    }
                    .foregroundStyle(Theme.accentText)
                }
            }
            .navigationTitle("Parachute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(phase == .saved ? "Done" : "Cancel") { onDone() }
                }
            }
        }
        .tint(Theme.accent)
        .task { await read() }
    }

    private func form(source: TrialCandidate.Source) -> some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    if foundNothing {
                        Text("No upcoming charge on this screen.")
                            .font(.title3.bold())
                        Text("Share the screen that shows the price and the date it charges (a trial confirmation or receipt), or fill it in below.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(canSave ? "Found:" : "Almost there. Fill in what's missing:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(summary)
                            .font(.title3.bold())
                    }
                }
                .padding(.vertical, 4)

                Button {
                    save()
                } label: {
                    Label("Track it", systemImage: "bell.badge.fill")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!canSave)
            } footer: {
                Text(source == .ai ? "Read on this iPhone with Apple Intelligence. Nothing left your phone." : "Read on this iPhone. Nothing left your phone.")
            }

            Section(isExpanded: .constant(editing || !canSave)) {
                TextField("Service, e.g. Spotify", text: $serviceName)
                    .textInputAutocapitalization(.words)
                TextField("Amount", value: $amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                DatePicker("Charges on", selection: $chargeDate, displayedComponents: .date)
                Toggle("Billed by Apple", isOn: $billedByApple)
            } header: {
                Button(editing ? "Hide details" : "Something's wrong? Edit") { editing.toggle() }
                    .font(.subheadline)
                    .textCase(nil)
            }

            if overLimit {
                Text("You're tracking \(ProFeatures.freeTrialLimit) trials, the free limit. Open Parachute to go Pro and add more.")
            }
            if saveFailed {
                Text("Couldn't save. Open Parachute and add it there.").foregroundStyle(.red)
            }
        }
    }

    private var summary: String {
        let name = serviceName.isEmpty ? "?" : serviceName
        let price = amount.map { (DeadlineMath.cents(from: $0)).formattedCents() } ?? "?"
        let date = chargeDate.formatted(.dateTime.month(.abbreviated).day())
        return "\(name) · \(price) · charges \(date)"
    }

    private func read() async {
        let known = CuratedServices.load().map(CuratedServices.shortName)
        var candidate: TrialCandidate
        var readText = ""
        switch await load() {
        case .image(let data):
            readText = (try? await TextRecognizer.text(inImageData: data)) ?? ""
            candidate = await TrialExtractor.extract(fromText: readText, knownServices: known)
        case .text(let text):
            readText = text
            candidate = await TrialExtractor.extract(fromText: text, knownServices: known)
        case .nothing:
            candidate = TrialCandidate()
        }
        CaptureDebugLog.save(text: readText, candidate: candidate)
        foundNothing = candidate.amountCents == nil && candidate.chargeDate == nil
        if foundNothing {
            // A name alone (e.g. from a list of cancelled subscriptions) isn't a trial.
            candidate.serviceName = nil
            editing = true
        }
        serviceName = candidate.serviceName ?? ""
        amount = candidate.amountCents.map { Decimal($0) / 100 }
        if let date = candidate.chargeDate { chargeDate = date }
        billedByApple = candidate.billedByApple
        phase = .ready(candidate.source)
    }

    private func save() {
        do {
            let container = try SharedStore.makeContainer()
            let context = ModelContext(container)
            // The extension can't ask RevenueCat, so it trusts the app's last known Pro state.
            let openCount = try context.fetch(FetchDescriptor<MoneyDeadline>()).filter(\.isOpen).count
            if !AppGroup.defaults.bool(forKey: ProFeatures.cachedProKey), openCount >= ProFeatures.freeTrialLimit {
                overLimit = true
                return
            }
            let name = serviceName.trimmingCharacters(in: .whitespaces)
            let deadline = MoneyDeadline(
                serviceName: name,
                serviceID: CuratedServices.serviceID(for: name, in: CuratedServices.load()),
                amountCents: DeadlineMath.cents(from: amount ?? 0),
                dueDate: DeadlineMath.normalizedDueDate(chargeDate),
                billedByApple: billedByApple
            )
            context.insert(deadline)
            try context.save()
            let snapshot = MoneyDeadlineSnapshot(deadline)
            // Reminders now; AlarmKit is left to the app, which arms the alarm next time it's active.
            let scheduler = EscalationScheduler(alarms: DeadlineAlarms(client: NoAlarmClient()))
            Task { try? await scheduler.schedule(deadline: snapshot) }
            phase = .saved
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                onDone()
            }
        } catch {
            saveFailed = true
        }
    }
}

/// Debug builds keep the last capture's OCR text and result, so a wrong card can be diagnosed
/// from the Debug tab (the share extension runs in its own process).
enum CaptureDebugLog {
    static let key = "debug.capture.last"

    static func save(text: String, candidate: TrialCandidate) {
        #if DEBUG
        let summary = [
            "name: \(candidate.serviceName ?? "-")",
            "amount: \(candidate.amountCents.map(String.init) ?? "-")",
            "date: \(candidate.chargeDate.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "-")",
            "apple: \(candidate.billedByApple)",
            "source: \(candidate.source.rawValue)",
        ].joined(separator: " · ")
        AppGroup.defaults.set("\(Date.now.formatted())\n\(summary)\n\nOCR:\n\(text)", forKey: key)
        #endif
    }

    static var last: String? {
        AppGroup.defaults.string(forKey: key)
    }
}
