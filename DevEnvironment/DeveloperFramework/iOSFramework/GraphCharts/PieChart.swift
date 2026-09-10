//
//  PieChart.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 26/03/25.
//
#if(os(iOS))
import SwiftUI

public func pieChart(title: String, shareNames: [String], percentages: [CGFloat], _ size: CGFloat) -> some View {
    let colors: [SwiftUI.Color] = [.red, .green, .blue, .yellow, .orange, .purple, .cyan, .pink]

    func startAngle(for index: Int) -> Angle {
        let total = percentages.reduce(0, +)
        let sum = percentages.prefix(index).reduce(0, +)
        return .degrees(Double(sum / total) * 360) - .degrees(90)
    }

    func endAngle(for index: Int) -> Angle {
        return startAngle(for: index) + .degrees(Double(percentages[index] / percentages.reduce(0, +)) * 360)
    }

    struct PieSlice: Shape {
        var startAngle: Angle
        var endAngle: Angle

        func path(in rect: CGRect) -> Path {
            var path = Path()
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2

            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.closeSubpath()

            return path
        }
    }

    return VStack {
        Text(title)
            .font(.title2)
            .bold()
        ZStack {
            ForEach(0..<percentages.count, id: \.self) { i in
                PieSlice(startAngle: startAngle(for: i), endAngle: endAngle(for: i))
                    .fill(colors[i % colors.count])
            }
        }
        .frame(width: size, height: size)
        VStack {
            ForEach(0..<shareNames.count, id: \.self) { i in
                HStack {
                    Rectangle()
                        .fill(colors[i % colors.count])
                        .frame(width: 20, height: 20)
                    Text("\(shareNames[i]) - \(Int(percentages[i]))%")
                    Spacer()
                }
                .padding(.leading)
            }
        }
    }
}

#endif
