//
//  ThreeDPieChart.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 26/03/25.
//
#if os(iOS)
import SwiftUI
public struct PieSlice3D: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    var depth: CGFloat

    public var body: some View {
        ZStack {
            // Side depth layers with smooth shading
            ForEach(0..<Int(depth), id: \.self) { i in
                PieSlice(startAngle: startAngle, endAngle: endAngle)
                    .fill(color.opacity(1 - Double(i) * 0.03)) // Gradient shading for 3D effect
                    .offset(y: CGFloat(i) * 0.8) // More visible depth
            }
            // Top surface
            PieSlice(startAngle: startAngle, endAngle: endAngle)
                .fill(color)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2) // Light shadow for depth
        }
    }
}

public struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()

        return path
    }
}

public func pieChart3D(_ title: String, _ shareNames: [String], _ percentages: [CGFloat], _ size: CGFloat, _ colorScheme: ColorScheme) -> some View {
    let colors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .cyan, .pink]

    func startAngle(for index: Int) -> Angle {
        let total = percentages.reduce(0, +)
        let sum = percentages.prefix(index).reduce(0, +)
        return .degrees(Double(sum / total) * 360) - .degrees(90)
    }

    func endAngle(for index: Int) -> Angle {
        return startAngle(for: index) + .degrees(Double(percentages[index] / percentages.reduce(0, +)) * 360)
    }

    return VStack {
        Text(title)
            .font(.title2)
            .bold()
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.top, -5)

        ZStack {
            ForEach(0..<percentages.count, id: \.self) { i in
                PieSlice3D(startAngle: startAngle(for: i), endAngle: endAngle(for: i), color: colors[i % colors.count], depth: 30) // More depth
            }
        }
        .frame(width: max(size, 300), height: max(size, 300)) // Slightly larger for better visibility

        VStack {
            ForEach(0..<shareNames.count, id: \.self) { i in
                HStack {
                    Rectangle()
                        .fill(colors[i % colors.count])
                        .frame(width: 20, height: 20)
                    Text("\(shareNames[i]) - \(Int(percentages[i]))%")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
        }
        .padding(.top, 30)
    }
}
#endif
