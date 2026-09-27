import MoneyKit
import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// A7: hosts MoneyKit's "Track it?" card for a shared screenshot or text.
final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? []).flatMap { $0.attachments ?? [] }
        let input = ShareInput(providers: providers)
        let host = UIHostingController(rootView: TrackTrialView(load: { await input.load() }) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil)
        })
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(host.view)
        host.didMove(toParent: self)
    }
}

/// Pulls the first image (or else text) out of the share. `NSItemProvider` isn't Sendable, so
/// this wrapper keeps it on one path and hands back plain data.
private final class ShareInput: @unchecked Sendable {
    private let providers: [NSItemProvider]

    init(providers: [NSItemProvider]) {
        self.providers = providers
    }

    func load() async -> TrackTrialView.Input {
        if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }),
           let data = await data(from: provider, type: .image) {
            return .image(data)
        }
        if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }),
           let data = await data(from: provider, type: .plainText),
           let text = String(data: data, encoding: .utf8) {
            return .text(text)
        }
        return .nothing
    }

    private func data(from provider: NSItemProvider, type: UTType) async -> Data? {
        await withCheckedContinuation { continuation in
            _ = provider.loadDataRepresentation(for: type) { data, _ in
                continuation.resume(returning: data)
            }
        }
    }
}
