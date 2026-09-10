//
//  MultiLineGraph.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 26/03/25.
//

#if os(iOS)
import SwiftUI

public struct MultiLineGraph: View {
    var title: String
    var shareNames: [String]
    var percentageSets: [[CGFloat]]
    var labels: [String]
    var size: CGFloat

    @State private var selectedLabelIndex: Int? = nil

    public init(
        title: String,
        shareNames: [String],
        percentageSets: [[CGFloat]],
        labels: [String],
        size: CGFloat = 350
    ) {
        self.title = title
        self.shareNames = shareNames
        self.percentageSets = percentageSets
        self.labels = labels
        self.size = size
    }

    public var body: some View {
        let width = size
        let height = size
        let padding: CGFloat = 60
        let graphWidth = width - (2 * padding)
        let graphHeight = height - (2 * padding)

        let lineColors: [Color] = [
            .blue, .green, .red, .orange, .purple, .pink, .yellow, .gray
        ]

        let pointsSets = percentageSets.map { percentages in
            percentages.enumerated().map { (index, value) in
                let x = padding + (CGFloat(index) / CGFloat(percentages.count - 1)) * graphWidth
                let y = height - padding - (value / 100) * graphHeight
                return CGPoint(x: x, y: y)
            }
        }

        return VStack(spacing: 10) {
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
                            selectedLabelIndex = -1 // Use -1 to indicate title tap
                        }
                    }

                if selectedLabelIndex == -1 {
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
                                selectedLabelIndex = nil
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)


            ZStack {
                VStack(spacing: 15) {
                    ForEach((0...5).reversed(), id: \.self) { step in
                        let percentageValue = CGFloat(step) * 20
                        Text("\(Int(percentageValue))%")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 40, alignment: .trailing)
                        Spacer()
                    }
                    .padding(.leading, -50)
                }
                .frame(height: height - 2 * padding)
                .offset(x: -size / 2 + padding - 10, y: padding / 2)

                ForEach(0..<percentageSets.count, id: \.self) { lineIndex in
                    let lineColor = lineColors[lineIndex % lineColors.count]

                    Canvas { context, size in
                        var path = Path()
                        if let firstPoint = pointsSets[lineIndex].first {
                            path.move(to: firstPoint)
                        }
                        for point in pointsSets[lineIndex].dropFirst() {
                            path.addLine(to: point)
                        }
                        context.stroke(path, with: .color(lineColor), lineWidth: 4)
                    }
                    .frame(width: width, height: height)

                    ForEach(0..<pointsSets[lineIndex].count, id: \.self) { index in
                        Circle()
                            .fill(lineColor)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .position(pointsSets[lineIndex][index])
                    }
                }
            }
            .frame(width: width, height: height)

            // Truncated X-Axis Labels
            HStack {
                ForEach(shareNames.indices, id: \.self) { index in
                    let fullName = shareNames[index]
                    let truncated = truncatedText(fullName, maxLength: 6)

                    VStack(spacing: 4) {
                        Text(truncated)
                            .font(.caption2)
                            .foregroundColor(Color.silverGray)
                            .frame(maxWidth: .infinity)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .onTapGesture {
                                withAnimation {
                                    selectedLabelIndex = selectedLabelIndex == index ? nil : index
                                }
                            }

                        if selectedLabelIndex == index {
                            Text(fullName)
                                .font(.caption)
                                .padding(4)
                                .foregroundColor(Color.silverGray)
                                .cornerRadius(5)
                                .transition(.scale)
                        }
                    }
                }
            }
            .frame(width: width - padding)
            .padding(.top, -10)
            .padding(.leading, 10)

            // Legends
            HStack(spacing: 12) {
                ForEach(0..<labels.count, id: \.self) { lineIndex in
                    let lineColor = lineColors[lineIndex % lineColors.count]

                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(lineColor)
                            .frame(width: 20, height: 20)
                        Text("\(labels[lineIndex])")
                            .font(.caption)
                            .foregroundColor(lineColor)
                    }
                }
            }
            .padding(.top, 10)
        }
    }

    private func truncatedText(_ text: String, maxLength: Int) -> String {
        if text.count <= maxLength {
            return text
        } else if maxLength <= 3 {
            return "..."
        } else {
            let endIndex = text.index(text.startIndex, offsetBy: maxLength - 3)
            return String(text[..<endIndex]) + "..."
        }
    }
}

#endif
