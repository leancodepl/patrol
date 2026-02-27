#if os(iOS)
import AVFoundation
import CoreMedia
import UIKit

/// Captures the BrowserStack-injected image via a supported AVCapturePhoto API
/// and feeds it as a CMSampleBuffer to the AVCaptureVideoDataOutput delegate,
/// enabling QR scanner packages (like mobile_scanner) to detect injected QR codes.
class CameraViewfinderInjector: NSObject {
    static let shared = CameraViewfinderInjector()

    private var trackedSessions = NSHashTable<AVCaptureSession>.weakObjects()
    private var swizzlesInstalled = false

    // MARK: - Swizzling

    /// Swizzles AVCaptureSession.startRunning() to track active sessions.
    func installSwizzles() {
        guard !swizzlesInstalled else { return }
        swizzlesInstalled = true

        let originalSelector = #selector(AVCaptureSession.startRunning)
        let swizzledSelector = #selector(AVCaptureSession.patrol_startRunning)

        guard
            let originalMethod = class_getInstanceMethod(AVCaptureSession.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(AVCaptureSession.self, swizzledSelector)
        else {
            NSLog("[Patrol] Failed to swizzle AVCaptureSession.startRunning")
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
        NSLog("[Patrol] AVCaptureSession.startRunning swizzled successfully")
    }

    /// Called from the swizzled startRunning to track the session.
    func trackSession(_ session: AVCaptureSession) {
        trackedSessions.add(session)
        NSLog("[Patrol] Tracking AVCaptureSession: \(session)")
    }

    // MARK: - Feed Injected Image

    /// Captures the BrowserStack-injected photo and feeds it to the video data output delegate.
    func feedInjectedImageToViewfinder(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let session = trackedSessions.allObjects.first(where: { $0.isRunning }) else {
            completion(.failure(CameraInjectionError.noActiveSession))
            return
        }

        guard let videoDataOutput = session.outputs.compactMap({ $0 as? AVCaptureVideoDataOutput }).first else {
            completion(.failure(CameraInjectionError.noVideoDataOutput))
            return
        }

        guard let delegate = videoDataOutput.sampleBufferDelegate else {
            completion(.failure(CameraInjectionError.noSampleBufferDelegate))
            return
        }

        guard let callbackQueue = videoDataOutput.sampleBufferCallbackQueue else {
            completion(.failure(CameraInjectionError.noCallbackQueue))
            return
        }

        // Add a temporary AVCapturePhotoOutput to capture the BrowserStack-injected image
        let photoOutput = AVCapturePhotoOutput()

        session.beginConfiguration()
        guard session.canAddOutput(photoOutput) else {
            session.commitConfiguration()
            completion(.failure(CameraInjectionError.cannotAddPhotoOutput))
            return
        }
        session.addOutput(photoOutput)
        session.commitConfiguration()

        NSLog("[Patrol] Added temporary AVCapturePhotoOutput, capturing photo...")

        let captureDelegate = PhotoCaptureDelegate(
            videoDataOutput: videoDataOutput,
            delegate: delegate,
            callbackQueue: callbackQueue,
            session: session,
            photoOutput: photoOutput,
            completion: completion
        )

        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: captureDelegate)

        // Hold a strong reference until the capture completes
        objc_setAssociatedObject(
            photoOutput,
            "captureDelegate",
            captureDelegate,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}

// MARK: - AVCaptureSession Swizzle Extension

extension AVCaptureSession {
    @objc func patrol_startRunning() {
        CameraViewfinderInjector.shared.trackSession(self)
        // Calls the original startRunning (methods are swapped)
        self.patrol_startRunning()
    }
}

// MARK: - Photo Capture Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    let videoDataOutput: AVCaptureVideoDataOutput
    let delegate: AVCaptureVideoDataOutputSampleBufferDelegate
    let callbackQueue: DispatchQueue
    let session: AVCaptureSession
    let photoOutput: AVCapturePhotoOutput
    let completion: (Result<Void, Error>) -> Void

    init(
        videoDataOutput: AVCaptureVideoDataOutput,
        delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        callbackQueue: DispatchQueue,
        session: AVCaptureSession,
        photoOutput: AVCapturePhotoOutput,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.videoDataOutput = videoDataOutput
        self.delegate = delegate
        self.callbackQueue = callbackQueue
        self.session = session
        self.photoOutput = photoOutput
        self.completion = completion
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        defer { cleanup() }

        if let error = error {
            NSLog("[Patrol] Photo capture failed: \(error)")
            completion(.failure(error))
            return
        }

        guard let cgImage = photo.cgImageRepresentation() else {
            NSLog("[Patrol] Failed to get CGImage from captured photo")
            completion(.failure(CameraInjectionError.noCGImage))
            return
        }

        guard let pixelBuffer = createPixelBuffer(from: cgImage) else {
            NSLog("[Patrol] Failed to create pixel buffer from CGImage")
            completion(.failure(CameraInjectionError.pixelBufferCreationFailed))
            return
        }

        guard let sampleBuffer = createSampleBuffer(from: pixelBuffer) else {
            NSLog("[Patrol] Failed to create sample buffer")
            completion(.failure(CameraInjectionError.sampleBufferCreationFailed))
            return
        }

        NSLog("[Patrol] Feeding injected image to video data output delegate")

        let connection = videoDataOutput.connections.first

        callbackQueue.async { [self] in
            delegate.captureOutput?(videoDataOutput, didOutput: sampleBuffer, from: connection!)
            NSLog("[Patrol] Injected image fed to viewfinder successfully")
            completion(.success(()))
        }
    }

    private func cleanup() {
        session.beginConfiguration()
        session.removeOutput(photoOutput)
        session.commitConfiguration()
        NSLog("[Patrol] Removed temporary AVCapturePhotoOutput")

        // Release the associated strong reference
        objc_setAssociatedObject(photoOutput, "captureDelegate", nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - Pixel Buffer & Sample Buffer Helpers

    private func createPixelBuffer(from cgImage: CGImage) -> CVPixelBuffer? {
        let width = cgImage.width
        let height = cgImage.height

        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return buffer
    }

    private func createSampleBuffer(from pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var formatDescription: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )

        guard let format = formatDescription else { return nil }

        var timingInfo = CMSampleTimingInfo(
            duration: CMTime.invalid,
            presentationTimeStamp: CMClockGetTime(CMClockGetHostTimeClock()),
            decodeTimeStamp: CMTime.invalid
        )

        var sampleBuffer: CMSampleBuffer?
        CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: format,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )

        return sampleBuffer
    }
}

// MARK: - Errors

enum CameraInjectionError: LocalizedError {
    case noActiveSession
    case noVideoDataOutput
    case noSampleBufferDelegate
    case noCallbackQueue
    case cannotAddPhotoOutput
    case noCGImage
    case pixelBufferCreationFailed
    case sampleBufferCreationFailed

    var errorDescription: String? {
        switch self {
        case .noActiveSession:
            return "No active AVCaptureSession found. Is the camera running?"
        case .noVideoDataOutput:
            return "No AVCaptureVideoDataOutput found on the active session"
        case .noSampleBufferDelegate:
            return "No sampleBufferDelegate set on the AVCaptureVideoDataOutput"
        case .noCallbackQueue:
            return "No sampleBufferCallbackQueue set on the AVCaptureVideoDataOutput"
        case .cannotAddPhotoOutput:
            return "Cannot add AVCapturePhotoOutput to the session"
        case .noCGImage:
            return "Failed to get CGImage from captured photo"
        case .pixelBufferCreationFailed:
            return "Failed to create CVPixelBuffer from CGImage"
        case .sampleBufferCreationFailed:
            return "Failed to create CMSampleBuffer from CVPixelBuffer"
        }
    }
}

#endif
