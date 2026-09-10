//
//  DonutChart.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 26/03/25.
//
#if os(iOS)
import SwiftUI

public struct DoubleDoughnutChart: View {
    var title: String = ""
    var shareNames: [String]
    var percentages: [CGFloat]
    var size: CGFloat = 270
    var centerText: String? = nil
    var centerImage: Image? = nil

    @State private var selectedIndex: Int? = nil
    
    public init(
        title: String = "",
        shareNames: [String],
        percentages: [CGFloat],
        size: CGFloat = 270,
        centerText: String? = nil,
        centerImage: Image? = nil
    ) {
        self.title = title
        self.shareNames = shareNames
        self.percentages = percentages
        self.size = size
        self.centerText = centerText
        self.centerImage = centerImage
    }


    public var body: some View {
        VStack {
            if !title.isEmpty {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.silverGray)
                    .padding(40)
            }

            ZStack {
                let total = percentages.reduce(0, +)
                let normalized = percentages.map { $0 / total * 100 }
                let outerRadius = size * 0.45
                let innerRadius = size * 0.3
                let outerStrokeWidth = size / 6
                let innerStrokeWidth = size / 8

                ForEach(0..<percentages.count, id: \.self) { i in
                    let startAngle = normalized[..<i].reduce(-90) { $0 + ($1 / 100 * 360) }
                    let sweep = normalized[i] / 100 * 360
                    let endAngle = startAngle + sweep
                    let midAngle = startAngle + sweep / 2

                    let color = colorForIndex(i, total: percentages.count)

                    // Draw arcs
                    CircleSegment(startAngle: Angle(degrees: startAngle), sweepAngle: Angle(degrees: sweep))
                        .stroke(color, lineWidth: outerStrokeWidth)
                        .frame(width: size, height: size)

                    CircleSegment(startAngle: Angle(degrees: startAngle), sweepAngle: Angle(degrees: sweep))
                        .stroke(color.opacity(0.6), lineWidth: innerStrokeWidth)
                        .frame(width: size * 0.71, height: size * 0.71)

                    let fullName = shareNames[i]

                    // Check letter angular positions for overlap
                    let showEye = isTextOverlappingArc(text: fullName, startAngle: startAngle, endAngle: endAngle)
                    let radians = midAngle * .pi / 180
                    let labelRadius = outerRadius - outerStrokeWidth * -0.3
                    let x = size / 2 + labelRadius * cos(radians)
                    let y = size / 2 + labelRadius * sin(radians)

                    ZStack {
                        if showEye {
                            if percentages[i] != 0 {
                                CurvedText(
                                    text: truncatedText(for: fullName, startAngle: startAngle, endAngle: endAngle),
                                    radius: labelRadius,
                                    angle: midAngle,
                                    center: CGPoint(x: size / 2, y: size / 2)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedIndex = selectedIndex == i ? nil : i
                                    }
                                }
                            }

                            if selectedIndex == i {
                                Text(fullName)
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.primary.opacity(0.8))
                                    .foregroundColor(Color.silverGray)
                                    .cornerRadius(8)
                                    .position(x: x, y: y - 30)
                                    .transition(.scale)
                            }
                        } else {
                            CurvedText(
                                text: fullName,
                                radius: labelRadius,
                                angle: midAngle,
                                center: CGPoint(x: size / 2, y: size / 2)
                            )
                            .onTapGesture {
                                selectedIndex = selectedIndex == i ? nil : i
                            }
                        }

                        // Percentage inside inner ring
                        let innerTextRadius = innerRadius - innerStrokeWidth * -0.4
                        let innerX = size / 2 + innerTextRadius * cos(radians)
                        let innerY = size / 2 + innerTextRadius * sin(radians)
                        if percentages[i] != 0 {
                            Text("\(Int(percentages[i]))%")
                                .font(.caption2)
                                .foregroundColor(Color.silverGray)
                                .position(x: innerX, y: innerY)
                        }
                    }
                }
                // Center Content
                if let image = centerImage {
                    image
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: size * 0.6, height: size * 0.6)
                } else if let text = centerText {
                    Text(text)
                        .foregroundColor(Color.silverGray)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(width: size * 0.4)
                }
            }
            .frame(width: size, height: size)
        }
        .padding()
    }
    public func isTextOverlappingArc(text: String, startAngle: CGFloat, endAngle: CGFloat, letterSpacingDegrees: CGFloat = 5) -> Bool {
        let arcSpan = endAngle - startAngle
        let midAngle = startAngle + arcSpan / 2
        let totalTextWidth = CGFloat(text.count - 1) * letterSpacingDegrees
        let firstLetterAngle = midAngle - totalTextWidth / 2

        for i in 0..<text.count {
            let letterAngle = firstLetterAngle + CGFloat(i) * letterSpacingDegrees
            if letterAngle < startAngle || letterAngle > endAngle {
                return true
            }
        }
        return false
    }
    public func truncatedText(for text: String, startAngle: CGFloat, endAngle: CGFloat, letterSpacingDegrees: CGFloat = 5) -> String {
        let arcSpan = endAngle - startAngle
        let maxLetters = Int(arcSpan / letterSpacingDegrees)

        if text.count <= maxLetters-2 {
            return text
        } else if maxLetters <= 3 {
            return "..."
        } else {
            let endIndex = text.index(text.startIndex, offsetBy: maxLetters - 5)
            return String(text[..<endIndex]) + "..."
        }
    }

    public func colorForIndex(_ index: Int, total: Int) -> Color {
        var hue = Double(index) / Double(total)
        // Skip green hues
        if hue >= 0.25 && hue <= 0.45 {
            hue += 0.2
            if hue > 1.0 { hue -= 1.0 }
        }
        // Higher saturation, lower brightness → no light colours
        return Color(hue: hue, saturation: 0.85, brightness: 0.55)
    }

}

// Circle arc shape
public struct CircleSegment: Shape {
    var startAngle: Angle
    var sweepAngle: Angle
    
    public init(startAngle: Angle, sweepAngle: Angle) {
        self.startAngle = startAngle
        self.sweepAngle = sweepAngle
    }


    public func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()

        path.addArc(center: center, radius: radius,
                    startAngle: startAngle,
                    endAngle: startAngle + sweepAngle,
                    clockwise: false)

        return path
    }
}
public struct CurvedText2: View {
    let text: String
    let radius: CGFloat
    let angle: Double
    let center: CGPoint

    public init(text: String, radius: CGFloat, angle: Double, center: CGPoint) {
        self.text = text
        self.radius = radius
        self.angle = angle
        self.center = center
    }

    public var body: some View {
        let spacing: Double = 5.0
        var reversed = String(Array(text))
        if angle > 65 && angle < 110 {
            reversed = String(Array(text).reversed())
        }
        return ZStack {
            ForEach(Array(reversed.enumerated()), id: \.offset) { index, char in
                let offset = Double(index - reversed.count / 2) * spacing
                let drawAngle = angle + offset
                let radians = drawAngle * .pi / 180

                let x = center.x + radius * cos(radians)
                let y = center.y + radius * sin(radians)

                let normalizedAngle = drawAngle.truncatingRemainder(dividingBy: 360)
                let isBottomHalf = normalizedAngle > 65 && normalizedAngle < 110
                let rotation = drawAngle + (isBottomHalf ? -90 : 90)

                Text(String(char))
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(Color.silverGray)
                    .rotationEffect(.degrees(rotation))
                    .position(x: x, y: y)
            }
        }
    }
}
public struct CurvedText: View {
    let text: String
    let radius: CGFloat
    let angle: Double
    let center: CGPoint

    public init(text: String, radius: CGFloat, angle: Double, center: CGPoint) {
        self.text = text
        self.radius = radius
        self.angle = angle
        self.center = center
    }

    public var body: some View {
        let font = UIFont.systemFont(ofSize: 20, weight: .medium)
        var characters = String(Array(text))
        if angle > 45 && angle < 135 {
            characters = String(Array(text).reversed())
        }
        // Get widths for all characters
        let charWidths: [CGFloat] = characters.map { char in
            let str = String(char) as NSString
            return str.size(withAttributes: [.font: font]).width
        }

        let totalWidth = charWidths.reduce(0, +)
        let angularPerPoint = 1 / radius * 180 / .pi
        let totalAngleSpan = totalWidth * angularPerPoint

        let isBottomHalf = angle.truncatingRemainder(dividingBy: 360) > 45 &&
                           angle.truncatingRemainder(dividingBy: 360) < 135

        // Compute each character's angle offset
        var accumulated: CGFloat = -totalAngleSpan / 2
        let charAngles: [Double] = charWidths.map { width in
            let centerAngle = accumulated + width / 2 * angularPerPoint
            accumulated += width * angularPerPoint
            return Double(centerAngle)
        }

        return ZStack {
            ForEach(0..<characters.count, id: \.self) { i in
                let char = characters[i]
                let drawAngle = angle + charAngles[i]
                let radians = drawAngle * .pi / 180
                let x = center.x + radius * cos(radians)
                let y = center.y + radius * sin(radians)
                let rotation = drawAngle + (isBottomHalf ? -90 : 90)

                Text(String(char))
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(.silverGray)
                    .rotationEffect(.degrees(rotation))
                    .position(x: x, y: y)
            }
        }
    }
}


//struct ContentView: View {
//    var body: some View {
//        ScrollView {
//            VStack {
//                DoubleDoughnutChart(
//                    title: "Team Performance",
//                    shareNames: [
//                        "Alice chandru",
//                        "Bob",
//                        "Charlie",
//                        "Diana",
//                        "raj",
//                        "shalini","divakar"
//                    ],
//                    percentages: [25.0, 15.0, 30.0, 20.0, 10.0, 5.0,8.0]
//                )
//                .frame(width: 400, height: 400)
//                .padding()
//            }
//        }
//    }
//}

#endif
