//
//  OneLineGraph.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 26/03/25.
//

#if os(iOS)
import SwiftUI

public struct OneLineGraph: View {
    let title: String
    let shareNames: [String]
    let percentages: [CGFloat]
    let size: CGFloat

    @State private var showFullTitle = false

    public init(_ title: String, _ shareNames: [String], _ percentages: [CGFloat], _ size: CGFloat = 350) {
        self.title = title
        self.shareNames = shareNames
        self.percentages = percentages
        self.size = size
    }

    public var body: some View {
        let width = size
        let height = size
        let padding: CGFloat = 60
        let graphWidth = width - (2 * padding)
        let graphHeight = height - (2 * padding)

        let maxValue = percentages.max() ?? 1
        let points = percentages.enumerated().map { (index, value) -> CGPoint in
            let x = padding + (CGFloat(index) / CGFloat(percentages.count - 1)) * graphWidth
            let y = height - padding - (value / maxValue) * graphHeight
            return CGPoint(x: x, y: y)
        }

        return VStack {
            // Title with single-line and popup
            ZStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.silverGray)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation {
                            showFullTitle.toggle()
                        }
                    }

                if showFullTitle {
                    Text(title)
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.opacity)
                        .offset(y: 40)
                        .zIndex(1)
                        .onTapGesture {
                            withAnimation {
                                showFullTitle = false
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 15)

            ZStack {
                VStack(spacing: 15) {
                    ForEach((0...5).reversed(), id: \.self) { step in
                        let percentageValue = (CGFloat(step) / 5) * maxValue
                        Text("\(Int(percentageValue))%")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 40, alignment: .trailing)
                        Spacer()
                    }
                    .padding(.leading, -25)
                }
                .frame(height: height - 2 * padding)
                .offset(x: -size / 2 + padding - 10, y: padding / 2)

                Canvas { context, size in
                    var path = Path()
                    if let firstPoint = points.first {
                        path.move(to: firstPoint)
                    }
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                    context.stroke(path, with: .color(.blue), lineWidth: 4)
                }
                .frame(width: width, height: height)

                ForEach(0..<points.count, id: \.self) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .position(points[index])
                }
            }
            .frame(width: width, height: height)

            HStack {
                ForEach(shareNames.indices, id: \.self) { index in
                    Text(shareNames[index])
                        .font(.caption2)
                        .foregroundColor(Color.silverGray)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: width - padding)
            .padding(.top, -10)
            .padding(.leading, 25)
        }
        .padding(.horizontal, -30)
        .padding(.vertical, -30)
    }
}

#endif
