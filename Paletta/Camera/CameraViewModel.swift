import AVFoundation
import SwiftUI

class CameraViewModel: NSObject, ObservableObject {

    @Published var palette: [UIColor] = []

    let session = AVCaptureSession()

    private let videoOutput = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "com.paletta.processing", qos: .userInitiated)
    private var lastProcessedAt: Date = .distantPast
    private let throttleInterval: TimeInterval = 0.4  // update palette ~2.5x per second

    override init() {
        super.init()
        setupSession()
    }

    // MARK: - Setup

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .medium  // smaller frames = faster processing

        // Back camera
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { session.commitConfiguration(); return }

        session.addInput(input)

        // Video output — request BGRA so ColorExtractor can read pixels directly
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)

        guard session.canAddOutput(videoOutput) else { session.commitConfiguration(); return }
        session.addOutput(videoOutput)

        session.commitConfiguration()
    }

    // MARK: - Start / Stop

    func start() {
        guard !session.isRunning else { return }
        processingQueue.async { self.session.startRunning() }
    }

    func stop() {
        guard session.isRunning else { return }
        processingQueue.async { self.session.stopRunning() }
    }
}

// MARK: - Frame delegate

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        let now = Date()
        guard now.timeIntervalSince(lastProcessedAt) >= throttleInterval else { return }
        lastProcessedAt = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let colors = ColorExtractor.dominantColors(from: pixelBuffer)

        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.palette = colors
            }
        }
    }
}
