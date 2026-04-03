import AVFoundation
import Combine
import SwiftUI
import UIKit

// MARK: - ViewModel (Main Actor)

@MainActor
class CameraViewModel: ObservableObject {

    @Published var palette: [UIColor] = []

    private let controller = CameraController()

    var session: AVCaptureSession { controller.session }

    init() {
        controller.onColors = { [weak self] colors in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.palette = colors
                }
            }
        }
    }

    func start() { controller.start() }
    func stop()  { controller.stop()  }
}

// MARK: - Camera Controller (no actor isolation)

private final class CameraController: NSObject {

    var onColors: (([UIColor]) -> Void)?

    let session = AVCaptureSession()

    private let videoOutput     = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "com.paletta.processing", qos: .userInitiated)
    private var lastProcessedAt: Date = .distantPast
    private let throttleInterval: TimeInterval = 0.4
    private var previousColors: [UIColor] = []

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .medium

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { session.commitConfiguration(); return }

        session.addInput(input)

        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)

        guard session.canAddOutput(videoOutput) else { session.commitConfiguration(); return }
        session.addOutput(videoOutput)

        session.commitConfiguration()
    }

    func start() {
        guard !session.isRunning else { return }
        processingQueue.async { self.session.startRunning() }
    }

    func stop() {
        guard session.isRunning else { return }
        processingQueue.async { self.session.stopRunning() }
    }
}

// MARK: - Frame Delegate

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        let now = Date()
        guard now.timeIntervalSince(lastProcessedAt) >= throttleInterval else { return }
        lastProcessedAt = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let colors = ColorExtractor.dominantColors(from: pixelBuffer)
        let smoothed = blend(colors, previous: previousColors)
        previousColors = smoothed
        onColors?(smoothed)
    }

    private func blend(_ new: [UIColor], previous: [UIColor]) -> [UIColor] {
        guard previous.count == new.count else { return new }
        return zip(new, previous).map { n, p in
            var nr: CGFloat = 0, ng: CGFloat = 0, nb: CGFloat = 0
            var pr: CGFloat = 0, pg: CGFloat = 0, pb: CGFloat = 0
            n.getRed(&nr, green: &ng, blue: &nb, alpha: nil)
            p.getRed(&pr, green: &pg, blue: &pb, alpha: nil)
            return UIColor(
                red:   0.7 * nr + 0.3 * pr,
                green: 0.7 * ng + 0.3 * pg,
                blue:  0.7 * nb + 0.3 * pb,
                alpha: 1
            )
        }
    }
}
