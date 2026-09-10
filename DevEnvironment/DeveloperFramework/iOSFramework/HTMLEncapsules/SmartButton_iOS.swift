#if os(iOS)

import Foundation
import Network
import AVFoundation
import SwiftUI
import SwiftUI
// MARK: - Hex Color Extension
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            (r, g, b) = (
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8) & 0xFF) / 255,
                Double(int & 0xFF) / 255
            )
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(red: r, green: g, blue: b)
    }
}
public struct SmartBlackButton: View {
    var label: String
    var action: () -> Void

    @State private var isPressed = false
    @State private var shineOffsets: [CGSize] = [
        .zero,
        CGSize(width: -140 * 1.2, height: -40 * 1.2)
    ]
    @State private var showSecondShine = false
    
    public init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }


    public var body: some View {
        ZStack {
            outerBorder
            innerContent
        }
        .frame(width: 140, height: 40)
        .onTapGesture {
            if !isPressed {
                isPressed = true
                action() // perform passed action
                startShineAnimations()
            }
        }
    }

    
    public var outerBorder: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // 🔸 Base golden border
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )

                // 🔸 First shimmer (center → right)
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: Color(hex: "#ffd277"), location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: UnitPoint(x: 0 + shineOffsets[0].width / width,
                                                  y: 0 + shineOffsets[0].height / height),
                            endPoint: UnitPoint(x: 1 + shineOffsets[0].width / width,
                                                y: 1 + shineOffsets[0].height / height)
                        ),
                        lineWidth: 3
                    )
                    .blendMode(.screen)

                // 🔸 Second shimmer (left → center)
                if showSecondShine {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: Color(hex: "#ffd277"), location: 0.5),
                                    .init(color: .clear, location: 1.0)
                                ]),
                                startPoint: UnitPoint(x: 0 + shineOffsets[1].width / width,
                                                      y: 0 + shineOffsets[1].height / height),
                                endPoint: UnitPoint(x: 1 + shineOffsets[1].width / width,
                                                    y: 1 + shineOffsets[1].height / height)
                            ),
                            lineWidth: 3
                        )
                        .blendMode(.screen)
                }
            }
        }
    }

    private var innerContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.84))
                .padding(2)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .padding(2)
                .overlay(shimmerOverlay)
                .mask(
                    RoundedRectangle(cornerRadius: 8)
                        .padding(2)
                )

            Text(label)
                .foregroundColor(Color(hex: "#ffd277"))
                .fontWeight(.bold)
                .font(.system(size: 16))
        }
    }

    private var shimmerOverlay: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let shineWidth = width * 0.2

            let adjustedOffset0 = CGSize(
                width: shineOffsets[0].width + (width * 0.5 - shineWidth) / 2,
                height: shineOffsets[0].height
            )
            let adjustedOffset1 = CGSize(
                width: shineOffsets[1].width + (width * 0.5 - shineWidth) / 2,
                height: shineOffsets[1].height
            )

            ZStack {
                Rectangle()
                    .fill(shimmerGradient)
                    .frame(width: shineWidth, height: height * 2)
                    .rotationEffect(.degrees(25))
                    .offset(adjustedOffset0)
                    .blur(radius: 25)
                    .blendMode(.screen)

                if showSecondShine {
                    Rectangle()
                        .fill(shimmerGradient)
                        .frame(width: shineWidth, height: height * 2)
                        .rotationEffect(.degrees(25))
                        .offset(adjustedOffset1)
                        .blur(radius: 25)
                        .blendMode(.screen)
                }
            }
        }
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.yellow.opacity(0.0), location: 0.0),
                .init(color: Color.yellow.opacity(0.3), location: 0.4),
                .init(color: Color.yellow.opacity(0.0), location: 1.0),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func startShineAnimations() {
        let width: CGFloat = 140
        let height: CGFloat = 40

        shineOffsets[0] = .zero
        shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2)
        showSecondShine = true

        withAnimation(.easeInOut(duration: 0.8)) {
            shineOffsets[0] = CGSize(width: width * 1.2, height: height * 1.2)
            shineOffsets[1] = .zero
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isPressed = false
            shineOffsets[0] = .zero
            shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2)
            showSecondShine = false
        }
    }
}
public struct SmartGreenButton1: View {
    var label: String
    var action: () -> Void
    @State private var isPressed = false
    @State private var shineOffsets: [CGSize] = [
        .zero, // First shine starts centered
        CGSize(width: -140 * 1.2, height: -40 * 1.2) // Second shine starts off-screen left
    ]
    @State private var showSecondShine = false
    
    public init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }


    public var body: some View {
        ZStack {
            outerBorder
            innerContent
        }
        .frame(width: 140, height: 40)
        .onTapGesture {
            if !isPressed {
                isPressed = true
                action()
                startShineAnimations()
            }
        }
    }

    
    public var outerBorder: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // 🔸 Base golden border
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )

                // 🔸 First shimmer (center → right)
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: Color(hex: "#ffd277"), location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: UnitPoint(x: 0 + shineOffsets[0].width / width,
                                                  y: 0 + shineOffsets[0].height / height),
                            endPoint: UnitPoint(x: 1 + shineOffsets[0].width / width,
                                                y: 1 + shineOffsets[0].height / height)
                        ),
                        lineWidth: 3
                    )
                    .blendMode(.screen)

                // 🔸 Second shimmer (left → center)
                if showSecondShine {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: Color(hex: "#ffd277"), location: 0.5),
                                    .init(color: .clear, location: 1.0)
                                ]),
                                startPoint: UnitPoint(x: 0 + shineOffsets[1].width / width,
                                                      y: 0 + shineOffsets[1].height / height),
                                endPoint: UnitPoint(x: 1 + shineOffsets[1].width / width,
                                                    y: 1 + shineOffsets[1].height / height)
                            ),
                            lineWidth: 3
                        )
                        .blendMode(.screen)
                }
            }
        }
    }

    public var innerContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#004d00").opacity(0.85))
                .padding(2)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .padding(2)
                .overlay(shimmerOverlay)
                .mask(
                    RoundedRectangle(cornerRadius: 8)
                        .padding(2)
                )

            Text(label)
                .foregroundColor(Color(hex: "#ffd277"))
                .fontWeight(.bold)
                .font(.system(size: 16))
        }
    }

    public var shimmerOverlay: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                Rectangle()
                    .fill(shimmerGradient)
                    .frame(width: width * 0.5, height: height * 2)
                    .rotationEffect(.degrees(25))
                    .offset(shineOffsets[0])
                    .blur(radius: 25)
                    .blendMode(.screen)

                if showSecondShine {
                    Rectangle()
                        .fill(shimmerGradient)
                        .frame(width: width * 0.5, height: height * 2)
                        .rotationEffect(.degrees(25))
                        .offset(shineOffsets[1])
                        .blur(radius: 25)
                        .blendMode(.screen)
                }
            }
        }
    }

    public var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.yellow.opacity(0.0), location: 0.0),
                .init(color: Color.yellow.opacity(0.3), location: 0.4),
                .init(color: Color.yellow.opacity(0.0), location: 1.0),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public func startShineAnimations() {
        let width: CGFloat = 140
        let height: CGFloat = 40

        // Reset initial positions
        shineOffsets[0] = .zero // Shine 1 starts at center
        shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2) // Shine 2 starts from far left
        showSecondShine = true // Show both shines immediately

        // Animate both shines fast and together
        withAnimation(.easeInOut(duration: 0.8)) {
            shineOffsets[0] = CGSize(width: width * 1.2, height: height * 1.2) // Shine 1 → right
            shineOffsets[1] = .zero // Shine 2 → center
        }

        // Reset to original state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isPressed = false
            shineOffsets[0] = .zero
            shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2)
            showSecondShine = false
        }
    }

}
public struct SmartRedButton1: View {
    var label: String
    var action: () -> Void
    @State private var isPressed = false
    @State private var shineOffsets: [CGSize] = [
        .zero, // First shine starts centered
        CGSize(width: -140 * 1.2, height: -40 * 1.2) // Second shine starts off-screen left
    ]
    @State private var showSecondShine = false
    
    public init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }

    public var body: some View {
        ZStack {
            outerBorder
            innerContent
        }
        .frame(width: 140, height: 40)
        .onTapGesture {
            if !isPressed {
                isPressed = true
                action()
                startShineAnimations()
            }
        }
    }
    public var outerBorder: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // 🔸 Base golden border
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )

                // 🔸 First shimmer (center → right)
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: Color(hex: "#ffd277"), location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: UnitPoint(x: 0 + shineOffsets[0].width / width,
                                                  y: 0 + shineOffsets[0].height / height),
                            endPoint: UnitPoint(x: 1 + shineOffsets[0].width / width,
                                                y: 1 + shineOffsets[0].height / height)
                        ),
                        lineWidth: 3
                    )
                    .blendMode(.screen)

                // 🔸 Second shimmer (left → center)
                if showSecondShine {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: Color(hex: "#ffd277"), location: 0.5),
                                    .init(color: .clear, location: 1.0)
                                ]),
                                startPoint: UnitPoint(x: 0 + shineOffsets[1].width / width,
                                                      y: 0 + shineOffsets[1].height / height),
                                endPoint: UnitPoint(x: 1 + shineOffsets[1].width / width,
                                                    y: 1 + shineOffsets[1].height / height)
                            ),
                            lineWidth: 3
                        )
                        .blendMode(.screen)
                }
            }
        }
    }

    public var innerContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#5b0000").opacity(0.85)) // Dark Maroon
                .padding(2)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .padding(2)
                .overlay(shimmerOverlay)
                .mask(
                    RoundedRectangle(cornerRadius: 8)
                        .padding(2)
                )

            Text(label)
                .foregroundColor(Color(hex: "#ffd277")) // Gold text
                .fontWeight(.bold)
                .font(.system(size: 16))
        }
    }

    public var shimmerOverlay: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                Rectangle()
                    .fill(shimmerGradient)
                    .frame(width: width * 0.5, height: height * 2)
                    .rotationEffect(.degrees(25))
                    .offset(shineOffsets[0])
                    .blur(radius: 25)
                    .blendMode(.screen)

                if showSecondShine {
                    Rectangle()
                        .fill(shimmerGradient)
                        .frame(width: width * 0.5, height: height * 2)
                        .rotationEffect(.degrees(25))
                        .offset(shineOffsets[1])
                        .blur(radius: 25)
                        .blendMode(.screen)
                }
            }
        }
    }

    public var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.yellow.opacity(0.0), location: 0.0),
                .init(color: Color.yellow.opacity(0.3), location: 0.4),
                .init(color: Color.yellow.opacity(0.0), location: 1.0),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public func startShineAnimations() {
        let width: CGFloat = 140
        let height: CGFloat = 40

        // Reset initial positions
        shineOffsets[0] = .zero // Shine 1 starts at center
        shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2) // Shine 2 starts from far left
        showSecondShine = true // Show both shines immediately

        // Animate both shines fast and together
        withAnimation(.easeInOut(duration: 0.8)) {
            shineOffsets[0] = CGSize(width: width * 1.2, height: height * 1.2) // Shine 1 → right
            shineOffsets[1] = .zero // Shine 2 → center
        }

        // Reset to original state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isPressed = false
            shineOffsets[0] = .zero
            shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2)
            showSecondShine = false
        }
    }
}
#endif
