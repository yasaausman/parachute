import SwiftUI

/// Minimal design tokens. Grow this together; keep screens using these instead of raw values.
public enum Theme {
    public static let accent = Color.orange
    public static let money = Color.green
    public static let frozen = Color.cyan

    public static let cornerRadius: CGFloat = 16
    public static let spacing: CGFloat = 16
}

public extension Int {
    /// 1799 → "$17.99" in the given currency.
    func formattedCents(currencyCode: String = "USD") -> String {
        (Decimal(self) / 100).formatted(.currency(code: currencyCode))
    }
}
