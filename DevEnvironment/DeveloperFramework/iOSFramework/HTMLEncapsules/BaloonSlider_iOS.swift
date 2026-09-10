//
//  RangeSlider.swift
//  Functions
//
//  Created by Sabinash on 28/02/25.
//

#if os(iOS)

import Foundation
import SwiftUI

public struct BalloonSlider: View {
    @State private var value: Double
    @State private var isDragging: Bool = false
    @State private var balloonOffset: CGFloat = 0
    @State private var balloonRotation: Double = 0
    @State private var balloonScale: CGFloat = 0.5
    @State private var scale: CGFloat = 0.0
    @State private var width: CGFloat = 20
    @State private var height: CGFloat = 20
    @State private var offsetY: CGFloat = 30

    var startValue: Double
    var lastValue: Double
    var changeValue: Double
    var id: Binding<String>

    init(startValue: Double, lastValue: Double, changeValue: Double, id: Binding<String>) {
        self.startValue = startValue
        self.lastValue = lastValue
        self.changeValue = changeValue
        self.id = id
        _value = State(initialValue: startValue)
    }

    public var body: some View {
        ZStack {
            GeometryReader { geometry in
                let sliderWidth = geometry.size.width - 30
                let range = lastValue - startValue
                let normalizedValue = CGFloat((value - startValue) / range) * sliderWidth
                BalloonView(value: Float((value)), width: $width, height: $height)
                    .rotationEffect(.degrees(balloonRotation))
                    .offset(x: normalizedValue - 26 + balloonOffset, y: offsetY)
                    .opacity(isDragging ? 1 : 0)
                    .onChange(of: isDragging) { dragging in
                        if dragging {
                            withAnimation(.easeIn(duration: 0.5)) {
                                width = 50
                                height = 50
                                offsetY = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    width = 70
                                    height = 70
                                    offsetY = -50
                                }
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                width = 20
                                height = 20
                                offsetY = 30
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: offsetY)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(.systemGray4))
                        .frame(height: 2)
                        .frame(width: sliderWidth)
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 2)
                        .frame(width: normalizedValue)
                }
                .padding(.top, 50)
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                        if !isDragging {
                            Text(value.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))" : String(format: "%.2f", value))
                                .foregroundColor(Color.black)
                                .font(.system(size: 15))
                                .fontWeight(.bold)
                                .onAppear {
                                    id.wrappedValue = String(Double(value))
                                }
                        }
                    }
                    .offset(x: normalizedValue - 25, y: -20)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let position = gesture.location.x / sliderWidth
                                let steppedValue = round(position * range / changeValue) * changeValue + startValue
                                let newValue = min(max(startValue, steppedValue), lastValue)
                                let dragDirection = newValue - value

                                withAnimation(.easeInOut(duration: 0.10)) {
                                    self.balloonOffset = dragDirection > 0 ? -15 : 15
                                    self.balloonRotation = dragDirection > 0 ? -15 : 15
                                    self.balloonScale = 1.0
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        self.balloonOffset = 0
                                        self.balloonRotation = 0
                                    }
                                }

                                self.value = newValue
                                self.isDragging = true
                            }
                            .onEnded { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        self.isDragging = false
                                        self.balloonOffset = 0
                                        self.balloonRotation = 0
                                        self.balloonScale = 0.5
                                    }
                                }
                            }
                    )
                    .padding(.top, 50)
            }
            .frame(height: 80)
        }
        .padding(.leading, 30)
    }
}


public struct BalloonView: View {
    var value: Float
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    public var body: some View {
        VStack(spacing: 0) {
            Text(value.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))" : String(format: "%.2f", value))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.84, blue: 0.0),  // Gold
                                    Color(red: 0.93, green: 0.78, blue: 0.0), // Slightly darker gold
                                    Color(red: 0.85, green: 0.65, blue: 0.13) // Deeper golden hue
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            Triangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.84, blue: 0.0),  // Gold
                            Color(red: 0.93, green: 0.78, blue: 0.0), // Slightly darker gold
                            Color(red: 0.85, green: 0.65, blue: 0.13) // Deeper golden hue
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 10, height: 6)
        }
    }
}

public struct Triangle: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#endif
