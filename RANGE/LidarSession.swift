import ARKit
import AVFoundation
import Combine
import Foundation
import UIKit

/// Real LiDAR depth on Pro devices; feature-point fallback otherwise.
/// A silent audio loop keeps the process alive when the app is backgrounded.
final class LidarSession: NSObject, ObservableObject, ARSessionDelegate {
    @Published var running = false
    @Published var distance: Double = 1.8
    @Published var hasSceneDepth = false

    private let session = ARSession()
    private var silent: AVAudioPlayer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    override init() {
        super.init()
        session.delegate = self
        prepareSilentAudio()
    }

    func start() {
        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics.insert(.sceneDepth)
            hasSceneDepth = true
        }
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        config.worldAlignment = .gravity
        session.run(config, options: [.resetTracking, .removeExistingAnchors])
        silent?.play()
        running = true
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func stop() {
        session.pause()
        silent?.pause()
        running = false
        UIApplication.shared.isIdleTimerDisabled = false
        endBackground()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let depth = frame.sceneDepth?.depthMap {
            hasSceneDepth = true
            distance = medianDepth(depth)
        } else if let pts = frame.rawFeaturePoints, pts.points.count > 0 {
            let zs = pts.points.prefix(80).map { Double(abs($0.z)) }
            distance = zs.reduce(0, +) / Double(max(zs.count, 1))
        }
    }

    func enterBackground() {
        guard running else { return }
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "RANGE-sensing") { [weak self] in
            self?.endBackground()
        }
        silent?.play()
    }

    private func endBackground() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    private func prepareSilentAudio() {
        let hz = 44100
        let samples = [Int16](repeating: 0, count: hz)
        let pcm = samples.withUnsafeBufferPointer { Data(buffer: $0) }
        var wav = Data()
        wav.append(contentsOf: Array("RIFF".utf8))
        wav.append(contentsOf: UInt32(36 + pcm.count).le)
        wav.append(contentsOf: Array("WAVEfmt ".utf8))
        wav.append(contentsOf: UInt32(16).le)
        wav.append(contentsOf: UInt16(1).le)
        wav.append(contentsOf: UInt16(1).le)
        wav.append(contentsOf: UInt32(44100).le)
        wav.append(contentsOf: UInt32(88200).le)
        wav.append(contentsOf: UInt16(2).le)
        wav.append(contentsOf: UInt16(16).le)
        wav.append(contentsOf: Array("data".utf8))
        wav.append(contentsOf: UInt32(pcm.count).le)
        wav.append(pcm)
        silent = try? AVAudioPlayer(data: wav)
        silent?.numberOfLoops = -1
        silent?.volume = 0.0
        silent?.prepareToPlay()
    }

    private func medianDepth(_ buf: CVPixelBuffer) -> Double {
        CVPixelBufferLockBaseAddress(buf, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buf, .readOnly) }
        let w = CVPixelBufferGetWidth(buf)
        let h = CVPixelBufferGetHeight(buf)
        guard let base = CVPixelBufferGetBaseAddress(buf) else { return distance }
        let ptr = base.assumingMemoryBound(to: Float32.self)
        let v = ptr[(h / 2) * w + (w / 2)]
        if v.isFinite, v > 0, v < 20 { return Double(v) }
        return distance
    }
}

private extension UInt16 {
    var le: [UInt8] { [UInt8(self & 0xff), UInt8(self >> 8)] }
}

private extension UInt32 {
    var le: [UInt8] {
        [UInt8(self & 0xff), UInt8((self >> 8) & 0xff), UInt8((self >> 16) & 0xff), UInt8((self >> 24) & 0xff)]
    }
}
