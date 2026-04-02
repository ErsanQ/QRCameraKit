#if canImport(SwiftUI)
#if os(iOS)
import SwiftUI
import AVFoundation

// MARK: - QRCameraPreview

/// A `UIViewRepresentable` that renders the live camera feed via an `AVCaptureVideoPreviewLayer`.
struct QRCameraPreview: UIViewRepresentable {

    let session: AVCaptureSession

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer.session = session
    }
}

// MARK: - PreviewView

/// A `UIView` subclass that uses `AVCaptureVideoPreviewLayer` as its backing layer.
final class PreviewView: UIView {

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}
#endif
#endif
