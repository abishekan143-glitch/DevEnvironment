//
//  TwoLineGraph.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 26/03/25.
//
#if os(iOS)
import SwiftUI

public func twoLineGraph(
    _ title: String,
    _ shareNames: [String],
    _ percentages1: [CGFloat],
    _ percentages2: [CGFloat],
    _ label1: String,
    _ label2: String,
    _ size: CGFloat = 600 // Increased for iPad
) -> some View {
    let width = size
    let height = size
    let padding: CGFloat = 80  // Increased padding
    let graphWidth = width - (2 * padding)
    let graphHeight = height - (2 * padding)
    
    let maxValue = max(percentages1.max() ?? 1, percentages2.max() ?? 1)
    
    let points1 = percentages1.enumerated().map { (index, value) -> CGPoint in
        let x = padding + (CGFloat(index) / CGFloat(percentages1.count - 1)) * graphWidth
        let y = height - padding - (value / maxValue) * graphHeight
        return CGPoint(x: x, y: y)
    }
    
    let points2 = percentages2.enumerated().map { (index, value) -> CGPoint in
        let x = padding + (CGFloat(index) / CGFloat(percentages2.count - 1)) * graphWidth
        let y = height - padding - (value / maxValue) * graphHeight
        return CGPoint(x: x, y: y)
    }

    return VStack {
        // Title
        Text(title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(Color.silverGray)
            .padding(.bottom, 20)
        
        ZStack {
            // Y-Axis Labels (Percentages) with proper spacing
            VStack(spacing: 20) {  // Adjusted spacing for iPad
                ForEach((0...5).reversed(), id: \.self) { step in
                    let percentageValue = (CGFloat(step) / 5) * maxValue
                    Text("\(Int(percentageValue))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 50, alignment: .trailing)
                    Spacer()
                }
            }
            .frame(height: height - 2 * padding)
            .offset(x: -size / 2 + padding - 10, y: padding / 2)

            // Graph Line 1 (Blue)
            Canvas { context, size in
                var path = Path()
                if let firstPoint = points1.first {
                    path.move(to: firstPoint)
                }
                for point in points1.dropFirst() {
                    path.addLine(to: point)
                }
                context.stroke(path, with: .color(.blue), lineWidth: 5) // Thicker line for iPad
            }
            .frame(width: width, height: height)

            // Graph Line 2 (Green)
            Canvas { context, size in
                var path = Path()
                if let firstPoint = points2.first {
                    path.move(to: firstPoint)
                }
                for point in points2.dropFirst() {
                    path.addLine(to: point)
                }
                context.stroke(path, with: .color(.green), lineWidth: 5) // Thicker line for iPad
            }
            .frame(width: width, height: height)

            // Data Points for Line 1 (Blue)
            ForEach(0..<points1.count, id: \.self) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 18, height: 18) // Bigger points
                    .overlay(Circle().stroke(Color.white, lineWidth: 5))
                    .position(points1[index])
            }
            
            // Data Points for Line 2 (Green)
            ForEach(0..<points2.count, id: \.self) { index in
                Circle()
                    .fill(Color.green)
                    .frame(width: 18, height: 18) // Bigger points
                    .overlay(Circle().stroke(Color.white, lineWidth: 5))
                    .position(points2[index])
            }
        }
        .frame(width: width, height: height)

        // X-Axis Labels (Share Names)
        HStack {
            ForEach(shareNames.indices, id: \.self) { index in
                Text(shareNames[index])
                    .font(.caption)
                    .foregroundColor(Color.silverGray)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: width - padding)
        .padding(.top, 5) // Adjusted position
        .padding(.leading, 30)

        // Color Legends/Labels (Dataset names)
        HStack(spacing: 20) {
            HStack {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                Text(label1)
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            HStack {
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 20, height: 20)
                Text(label2)
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.top, 10)
    }
    .padding(.horizontal, -30)
    .padding(.vertical, -30)
}
#endif
