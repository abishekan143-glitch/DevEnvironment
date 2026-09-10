//
//  RatingStars.swift
//  rating star final
//
//  Created by Anisha R on 04/03/25.
//
#if os(iOS)
import SwiftUI
public var stars: [String: Int] = [:]

public struct StarRatingView: View {
    var id: String
    @State private var rating: Int = 0
    @State private var rotations: [Int: Double] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
    @State private var scales: [Int: CGFloat] = [1: 1.0, 2: 1.0, 3: 1.0, 4: 1.0, 5: 1.0]

    public var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let starSize = availableWidth / 6

            HStack(spacing: 0) {
                ForEach(1..<6) { i in
                    Text(getEmojiForRating(rating: i))
                        .font(.system(size: starSize))
                        .rotationEffect(.degrees(rotations[i] ?? 0))
                        .foregroundColor(i <= rating ? .yellow : .gray)
                        .scaleEffect(scales[i] ?? 1.0)
                        .onTapGesture {
                            rating = i
                            stars[id] = rating
                            animateStars(for: i)
                        }
                }
            }
            .frame(width: availableWidth)
        }
        .frame(height: 90)
        
    }

    public func animateStars(for selectedRating: Int) {
        for j in 1...selectedRating {
            let delay = Double(j) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.interpolatingSpring(stiffness: 150, damping: 8)) {
                    scales[j] = 1.6
                }
                withAnimation(.easeInOut(duration: 0.4)) {
                    rotations[j] = (rotations[j] ?? 0) + 720
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0)) {
                        scales[j] = 1.0
                    }
                }
            }
        }
    }

    public func getEmojiForRating(rating: Int) -> String {
        if rating <= self.rating {
            switch self.rating {
            case 1: return "😡"
            case 2: return "😞"
            case 3: return "😐"
            case 4: return "😊"
            case 5: return "😁"
            default: return "⭐"
            }
        }
        return "⭐"
    }
}

public struct FixedStars: View {
    var rating: Int
    @State private var rotations: [Int: Double] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
    @State private var scales: [Int: CGFloat] = [1: 1.0, 2: 1.0, 3: 1.0, 4: 1.0, 5: 1.0]

    public var body: some View {
        ZStack {
            GeometryReader { geometry in
                let availableWidth = geometry.size.width
                let starSize = availableWidth / 6
                
                HStack(spacing: 0) {
                    ForEach(1..<6) { i in
                        Text(getEmojiForRating(rating: i == rating ? rating : i < rating ? 0 : 6))
                            .font(.system(size: starSize))
                            .foregroundColor(i <= rating ? .yellow : .gray)
                    }
                }
                .frame(width: availableWidth)
            }
        }
    }

    public func getEmojiForRating(rating: Int) -> String {
        if rating <= self.rating {
            switch rating {
            case 1: return "😡"
            case 2: return "😞"
            case 3: return "😐"
            case 4: return "😊"
            case 5: return "😁"
            default: return "⭐️"
            }
        }
        return "☆"
    }
}
#endif
