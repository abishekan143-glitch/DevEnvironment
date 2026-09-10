//
//  AccessDenied.swift
//  DevEnvironment
//
//  Created by Raghul S on 05/03/25.
//
#if os(iOS)

import SwiftUI
import UIKit
import AVFoundation

public struct AccessDenied: View {
    var onContactTechTeam: () -> Void
    // Starting offsets for the swords off-screen on the left and right
    @State private var leftSwordOffset = CGSize(width: -UIScreen.main.bounds.width / 2, height: 0)
    @State private var rightSwordOffset = CGSize(width: UIScreen.main.bounds.width / 2, height: 0)
    @State private var audioPlayer: AVAudioPlayer?

    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.red]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("A C C E S S")
                        .font(Font.system(size: 36, weight: .bold, design: .default)) // You can adjust the size as needed
                        .foregroundColor(.white)
                        .bold()
                    Text("D E N I E D")
                        .font(Font.system(size: 36, weight: .bold, design: .default)) // You can adjust the size as needed
                        .foregroundColor(.white)
                        .bold()
                    
                    // Swords that will cross each other
                    ZStack {
                        // Left sword
                        Image("sword")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .offset(leftSwordOffset)
                            .rotationEffect(.degrees(0)) // Adjust as needed
                        
                        // Right sword
                        Image("sword")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .scaleEffect(x: -1, y: 1) // Flip the right sword horizontally
                            .offset(rightSwordOffset)
                            .rotationEffect(.degrees(-0)) // Adjust as needed
                            .padding(.vertical)
                    }
                    .onAppear {
                        // Trigger haptic feedback
                        playSound()
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.prepare()
                        withAnimation {
                            // Move the swords to the center
                            leftSwordOffset = CGSize(width: 0, height: 0)
                            rightSwordOffset = CGSize(width: 0, height: 0)
                        }
                        generator.impactOccurred()
                    }
                    NavigationLink(destination: ContactOurDeveloper()) {
                        Text("Contact Our Tech Team")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.bloodRed)
                            .cornerRadius(10)
                            .bold()
                            .padding(.horizontal)
                    }
                    Button(action: onContactTechTeam) {
                        Text("Go Back")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.bloodRed)
                            .cornerRadius(10)
                            .bold()
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    public func playSound() {
        guard let path = Bundle.main.path(forResource: "swordsoundeffect", ofType: "mp3") else {
            print("Could not find the sound file.")
            return
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.currentTime = 0.9 // Start playback from 1.2 seconds
            audioPlayer?.play()
        } catch {
            print("Could not load the file: \(error)")
        }
    }
}

#endif
