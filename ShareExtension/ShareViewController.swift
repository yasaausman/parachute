import SharedKit
import SwiftUI
import UIKit

// Dev A's target. Placeholder from Phase 0 (S0.1); the real "Track it?" flow is A7.
final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(rootView: SharePlaceholderView { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil)
        })
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(host.view)
        host.didMove(toParent: self)
    }
}

private struct SharePlaceholderView: View {
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            ContentUnavailableView("Coming soon", systemImage: "parachute", description: Text("Share a trial screenshot to track it."))
                .toolbar {
                    Button("Done", action: onDone)
                }
        }
    }
}
