//
//  CheckBox_iOS.swift
//  DevEnvironment
//
//  Created by Kajol on 21/03/25.
//
#if os(iOS)
import SwiftUI

public struct CheckmarkAnimationView: View {
    @State private var showOutline = false
    @State private var fillCircle = false
    @State private var drawCheckmark = false
    @State private var showParticles = false

    public var body: some View {
        ZStack {
            if showParticles {
                ParticleView(circleRadius: 100, centerPosition: CGPoint(x: 75, y: 75))
                    .frame(width: 150, height: 150) // Matches the circle size
                    .transition(.scale.combined(with: .opacity))
            }

            Circle()
                .trim(from: 0, to: showOutline ? 1 : 0)
                .stroke(customGradient(), lineWidth: 6)
                .frame(width: 150, height: 150)
                .animation(.easeIn(duration: 0.5), value: showOutline)

            ZStack {
                Circle()
                    .fill(customGradient())
                    .frame(width: 150, height: 150)
                    .opacity(fillCircle ? 1 : 0)

                CheckmarkShape()
                    .trim(from: 0, to: drawCheckmark ? 1 : 0)
                    .stroke(Color.white, lineWidth: 6)
                    .frame(width: 100, height: 100)
            }
            .opacity(fillCircle ? 1 : 0)
            .animation(.easeIn(duration: 0.3).delay(0.5), value: fillCircle)
        }
        .onAppear {
            showOutline = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                fillCircle = true
                drawCheckmark = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showParticles = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showParticles = false
                    }
                }
            }
        }
    }

    public func customGradient() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [
                SwiftUI.Color(red: 0.9, green: 0.7, blue: 0.2),
                SwiftUI.Color(red: 1.0, green: 0.85, blue: 0.4),
                SwiftUI.Color(red: 0.8, green: 0.6, blue: 0.2)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

public struct CheckmarkShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let startX = rect.width * 0.2
        let startY = rect.height * 0.5
        let midX = rect.width * 0.45
        let midY = rect.height * 0.75
        let endX = rect.width * 0.8
        let endY = rect.height * 0.25

        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: midX, y: midY))
        path.addLine(to: CGPoint(x: endX, y: endY))

        return path
    }
}

public struct ParticleView: View {
    let circleRadius: CGFloat
    let centerPosition: CGPoint
    @State private var particles: [Particle] = []

    public var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(customGradient())
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            generateParticles()
        }
    }

    public func generateParticles() {
        particles = (0..<30).map { index in
            let angle = (Double(index) / 30.0) * 2 * .pi
            let x = centerPosition.x + circleRadius * cos(angle)
            let y = centerPosition.y + circleRadius * sin(angle)

            return Particle(
                position: CGPoint(x: x, y: y),
                size: CGFloat.random(in: 6...10), // Bigger size
                opacity: 1.0
            )
        }

        withAnimation(.easeOut(duration: 1.0)) {
            for i in particles.indices {
                particles[i].opacity = 0.0
            }
        }
    }


    public func customGradient() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.9, green: 0.7, blue: 0.2),
                Color(red: 1.0, green: 0.85, blue: 0.4),
                Color(red: 0.8, green: 0.6, blue: 0.2)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}
#endif
