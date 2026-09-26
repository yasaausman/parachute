import SharedKit
import SwiftData
import SwiftUI

/// A1: add or edit a money deadline by hand.
public struct DeadlineEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private let deadline: MoneyDeadline?
    private let curated = CuratedServices.load()

    @State private var serviceName: String
    @State private var amount: Decimal?
    @State private var dueDate: Date
    @State private var billedByApple: Bool
    @State private var currencyCode: String
    @State private var confirmingDelete = false

    public init(deadline: MoneyDeadline? = nil) {
        self.deadline = deadline
        _serviceName = State(initialValue: deadline?.serviceName ?? "")
        _amount = State(initialValue: deadline.map { Decimal($0.amountCents) / 100 })
        _dueDate = State(initialValue: deadline?.dueDate ?? Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now)
        _billedByApple = State(initialValue: deadline?.billedByApple ?? false)
        _currencyCode = State(initialValue: deadline?.currencyCode ?? Locale.current.currency?.identifier ?? "USD")
    }

    private var trimmedName: String {
        serviceName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && (amount ?? 0) > 0
    }

    public var body: some View {
        Form {
            Section {
                TextField("Service, e.g. Spotify", text: $serviceName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                if deadline == nil, trimmedName.isEmpty, !curated.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(curated) { service in
                                let name = CuratedServices.shortName(service)
                                Button(name) { serviceName = name }
                                    .buttonStyle(.bordered)
                            }
                        }
                    }
                }
            } header: {
                Text("What's the trial?")
            }

            Section {
                TextField("Amount", value: $amount, format: .currency(code: currencyCode))
                    .keyboardType(.decimalPad)
                DatePicker("Charges on", selection: $dueDate, displayedComponents: .date)
            } header: {
                Text("What happens if you forget")
            }

            Section {
                Toggle("Billed by Apple", isOn: $billedByApple)
            } footer: {
                Text("Turn this on if you started it inside an iPhone app and pay with your Apple Account. Apple needs you to cancel at least a day early, so Parachute counts down to the day before.")
            }

            if deadline != nil {
                Section {
                    Button("Delete", role: .destructive) { confirmingDelete = true }
                }
            }
        }
        .navigationTitle(deadline == nil ? "Add trial" : "Edit trial")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(!canSave)
            }
        }
        .confirmationDialog("Delete \(trimmedName)?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: delete)
        }
    }

    private func save() {
        guard canSave, let amount else { return }
        let cents = DeadlineMath.cents(from: amount)
        let due = DeadlineMath.normalizedDueDate(dueDate)
        let serviceID = CuratedServices.serviceID(for: trimmedName, in: curated)

        if let deadline {
            deadline.serviceName = trimmedName
            deadline.serviceID = serviceID
            deadline.amountCents = cents
            deadline.currencyCode = currencyCode
            deadline.dueDate = due
            deadline.billedByApple = billedByApple
        } else {
            context.insert(MoneyDeadline(
                serviceName: trimmedName,
                serviceID: serviceID,
                amountCents: cents,
                currencyCode: currencyCode,
                dueDate: due,
                billedByApple: billedByApple
            ))
        }
        try? context.save()
        dismiss()
    }

    private func delete() {
        if let deadline {
            context.delete(deadline)
            try? context.save()
        }
        dismiss()
    }
}

#Preview("Add") {
    NavigationStack { DeadlineEditorView() }
        .modelContainer(MoneyPreview.container)
}
