import CoreGraphics
import Foundation
import ImageIO
import Vision

/// On-device OCR (Vision). Returns the lines top to bottom, left to right.
public enum TextRecognizer {
    public static func text(in image: CGImage) async throws -> String {
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        let observations = try await request.perform(on: image)
        return observations
            .sorted { lhs, rhs in
                // Normalized coordinates: origin at the bottom left, so higher y comes first.
                let dy = lhs.boundingBox.origin.y - rhs.boundingBox.origin.y
                if abs(dy) > 0.01 { return dy > 0 }
                return lhs.boundingBox.origin.x < rhs.boundingBox.origin.x
            }
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }

    public static func text(inImageData data: Data) async throws -> String {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { throw CaptureError.unreadableImage }
        return try await text(in: image)
    }
}

public enum CaptureError: Error, Sendable {
    case unreadableImage
}
