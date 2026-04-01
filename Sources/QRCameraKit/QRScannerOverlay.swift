#if canImport(SwiftUI)
#if canImport(UIKit)
import SwiftUI

// MARK: - QRScannerOverlay

/// The default corner-bracket overlay drawn on top of the camera feed.
///
/// Rendered as four L-shaped corners with a subtle scanning line animation.
struct QRScannerOverlay: View {

    let color: QRScannerConfiguration.OverlayColor

    private var resolvedColor: Color {
        switch color {
        case .white:  return .white
        case .yellow: return .yellow
        case .green:  return Color(red: 0.2, green: 0.9, blue: 0.4)
        case .blue:   return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .custom(let r, let g, let b): return Color(red: r, green: g, blue: b)
        }
    }

    @State private var scanLineOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) * 0.65
            let x = (geo.size.width - size) / 2
            let y = (geo.size.height - size) / 2

            ZStack {
                // Dim everything outside the scan window
                Rectangle()
                    .fill(.black.opacity(0.5))
                    .mask(
                        Rectangle()
                            .fill(style: FillStyle(eoFill: true))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .frame(width: size, height: size)
                                    .blendMode(.destinationOut)
                            )
                    )

                // Corner brackets
                QRCornerBrackets(size: size, color: resolvedColor)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // Scanning line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, resolvedColor.opacity(0.8), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: size - 16, height: 2)
                    .position(x: geo.size.width / 2, y: y + scanLineOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true)
                        ) {
                            scanLineOffset = size
                        }
                    }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - QRCornerBrackets

private struct QRCornerBrackets: View {
    let size: CGFloat
    let color: Color
    let lineWidth: CGFloat = 4
    let cornerLength: CGFloat = 24
    let radius: CGFloat = 10

    var body: some View {
        ZStack {
            // Top-left
            CornerShape(corner: .topLeft, length: cornerLength, radius: radius)
            // Top-right
            CornerShape(corner: .topRight, length: cornerLength, radius: radius)
            // Bottom-left
            CornerShape(corner: .bottomLeft, length: cornerLength, radius: radius)
            // Bottom-right
            CornerShape(corner: .bottomRight, length: cornerLength, radius: radius)
        }
        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        .frame(width: size, height: size)
    }
}

// MARK: - CornerShape

private struct CornerShape: Shape {

    enum Corner { case topLeft, topRight, bottomLeft, bottomRight }

    let corner: Corner
    let length: CGFloat
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let (x, y, w, h) = (rect.minX, rect.minY, rect.maxX, rect.maxY)

        switch corner {
        case .topLeft:
            path.move(to: CGPoint(x: x, y: y + length))
            path.addLine(to: CGPoint(x: x, y: y + radius))
            path.addQuadCurve(to: CGPoint(x: x + radius, y: y),
                              control: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + length, y: y))

        case .topRight:
            path.move(to: CGPoint(x: w - length, y: y))
            path.addLine(to: CGPoint(x: w - radius, y: y))
            path.addQuadCurve(to: CGPoint(x: w, y: y + radius),
                              control: CGPoint(x: w, y: y))
            path.addLine(to: CGPoint(x: w, y: y + length))

        case .bottomLeft:
            path.move(to: CGPoint(x: x, y: h - length))
            path.addLine(to: CGPoint(x: x, y: h - radius))
            path.addQuadCurve(to: CGPoint(x: x + radius, y: h),
                              control: CGPoint(x: x, y: h))
            path.addLine(to: CGPoint(x: x + length, y: h))

        case .bottomRight:
            path.move(to: CGPoint(x: w - length, y: h))
            path.addLine(to: CGPoint(x: w - radius, y: h))
            path.addQuadCurve(to: CGPoint(x: w, y: h - radius),
                              control: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: w, y: h - length))
        }

        return path
    }
}
#endif
#endif
