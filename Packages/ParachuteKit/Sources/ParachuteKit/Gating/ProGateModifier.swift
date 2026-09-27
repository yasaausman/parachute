import SwiftUI
import SharedKit

/// View modifier that gates content behind Pro. "First step is always free."
public struct ProGateModifier: ViewModifier {
    let entitlements: any EntitlementsProviding
    let isFirstStep: Bool
    @State private var isPro = false

    public init(entitlements: any EntitlementsProviding, isFirstStep: Bool) {
        self.entitlements = entitlements
        self.isFirstStep = isFirstStep
    }

    public func body(content: Content) -> some View {
        Group {
            if isPro || isFirstStep {
                content
            } else {
                content
                    .blur(radius: 4)
                    .overlay {
                        VStack(spacing: 16) {
                            Text("Want to keep going?")
                                .font(.headline)

                            Text("Your first step is always free.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button {
                                entitlements.presentPaywall()
                            } label: {
                                Text("Unlock Parachute Pro")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.accent)
                                    .cornerRadius(Theme.cornerRadius)
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground).opacity(0.8))
                        .cornerRadius(Theme.cornerRadius)
                        .shadow(radius: 10)
                        .padding()
                    }
            }
        }
        .task {
            isPro = await entitlements.isPro
        }
    }
}

public extension View {
    func proGated(entitlements: any EntitlementsProviding, isFirstStep: Bool = false) -> some View {
        modifier(ProGateModifier(entitlements: entitlements, isFirstStep: isFirstStep))
    }
}

/// Wrapper that shows content for Pro users, or an upsell card for free users.
public struct ProGatedFeature<Content: View>: View {
    let entitlements: any EntitlementsProviding
    let feature: String
    @ViewBuilder let content: () -> Content
    @State private var isPro = false

    public init(entitlements: any EntitlementsProviding, feature: String, @ViewBuilder content: @escaping () -> Content) {
        self.entitlements = entitlements
        self.feature = feature
        self.content = content
    }

    public var body: some View {
        Group {
            if isPro {
                content()
            } else {
                VStack(spacing: 16) {
                    Text(feature)
                        .font(.headline)

                    Text("Your first step is always free. Want to keep going?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        entitlements.presentPaywall()
                    } label: {
                        Text("Unlock Parachute Pro")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Theme.accent)
                            .cornerRadius(Theme.cornerRadius)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(Theme.cornerRadius)
            }
        }
        .task {
            isPro = await entitlements.isPro
        }
    }
}
