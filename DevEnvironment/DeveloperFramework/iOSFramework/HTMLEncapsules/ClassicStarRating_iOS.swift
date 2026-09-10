//
//  ClassicStarRating.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 27/03/25.
//
#if os(iOS)
import SwiftUI
import AVFoundation

public struct StarRatingBar: View {
    var id: String
    @State private var rating: Int = 0
    @State private var audioPlayer: AVAudioPlayer?

    public var body: some View {
        HStack(spacing: 12) {
            ForEach(1...5, id: \.self) { index in
                let isSelected = index == rating
                let isFilled = index <= rating  // Fill all previous stars with gold

                Text(isSelected ? getEmoji(for: index) : "★") // Change to emoji only when selected
                    .font(.system(size: 60))
                    .foregroundColor(isFilled ? Color.yellow : .gray)  // Gold for previous stars
                    .rotationEffect(.degrees(isSelected ? 720 : 0))
                    .scaleEffect(isSelected ? 1.4 : 1.0)
                    .animation(.easeOut(duration: 0.6), value: rating)
                    .onTapGesture {
                        rating = index
                        stars[id] = rating
                        playSound(for: rating)
                    }
            }
        }
    }

    public func getEmoji(for rating: Int) -> String {
        switch rating {
        case 1: return "🥺"
        case 2: return "😰"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "😍"
        default: return "★"
        }
    }

    public func playSound(for rating: Int) {
        let soundFile: String?
        switch rating {
        case 1: soundFile = "betterlucknxttime"
        case 2: soundFile = "youcan"
        case 3: soundFile = "goodjob"
        case 4: soundFile = "gratwork"
        case 5: soundFile = "excellent"
        default: soundFile = nil
        }

        if let fileName = soundFile, let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            print("Audio file found: \(url.absoluteString)")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.volume = -0.4  // Mild sound
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found: \(soundFile ?? "unknown").mp3")
        }
    }
}
#endif
