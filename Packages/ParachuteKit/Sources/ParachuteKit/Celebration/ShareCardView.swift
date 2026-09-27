import SwiftUI
import SharedKit

public struct ShareCardView: View {
    let totalCentsRefunded: Int
    let tasksUnfrozen: Int
    let bestRun: Int
    
    public init(totalCentsRefunded: Int, tasksUnfrozen: Int, bestRun: Int) {
        self.totalCentsRefunded = totalCentsRefunded
        self.tasksUnfrozen = tasksUnfrozen
        self.bestRun = bestRun
    }
    
    public var body: some View {
        VStack(spacing: Theme.spacing) {
            Text("ADHD TAX REFUNDED")
                .font(.headline.bold())
                .foregroundColor(Theme.accent)
            
            Text(totalCentsRefunded.formattedCents(currencyCode: "USD"))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(Theme.money)
            
            HStack(spacing: 32) {
                VStack {
                    Text("\(tasksUnfrozen)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Tasks Unfrozen")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Text("\(bestRun)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Best Run")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 8)
            
            Text("Parachute - Your brain works.")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.top, Theme.spacing)
        }
        .padding(32)
        .background(Color.black)
        .cornerRadius(Theme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
        )
    }
    
    @MainActor
    public func renderImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}
