import SwiftUI
import AVFoundation
import ARKit

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Handle updates
    }
}

class CameraViewController: UIViewController, ARSessionDelegate {
    private var captureSession: AVCaptureSession?
    private let session = ARSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupLiDAR()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession?.canAddInput(videoInput) == true else {
            print("Camera setup failed")
            return
        }

        captureSession?.addInput(videoInput)
        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoLayer.frame = view.layer.bounds
        videoLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoLayer)
        captureSession?.startRunning()
    }

    private func setupLiDAR() {
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) else {
            print("LiDAR not supported on this device")
            return
        }

        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = .sceneDepth
        session.run(configuration)
        session.delegate = self
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let depthMap = frame.sceneDepth?.depthMap {
            // Process depth map data here
            print("LiDAR depth data received")
        }
    }
}
