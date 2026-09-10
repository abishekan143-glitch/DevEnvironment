//
//  VideoUploader.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 27/03/25.
//
#if os(iOS)
import SwiftUI
import AVKit

public struct VideoUploader: View {
    @State private var players: [Int: AVPlayer] = [:]
    @State private var videoNames: [String] = ["video-1", "video-2", "video-3", "video-5", "video-6"]
    @State private var selectedIndex = 1  // Center video
    @Environment(\.colorScheme) var colorScheme
    var id: String
    
    public init(id: String) {
        self.id = id
    }


    public var body: some View {
        coverFlowView()
            .gesture(
                DragGesture()
                    .onEnded { value in
                        withAnimation(.easeInOut(duration: 0.4)) {
                            if value.translation.width < -10 {
                                selectedIndex = min(selectedIndex + 1, videoNames.count - 1)
                            } else if value.translation.width > 50 {
                                selectedIndex = max(selectedIndex - 1, 0)
                            }
                        }
                    }
            )
    }

    public func coverFlowView() -> some View {
        ZStack {
            if colorScheme == .dark {
                Image("darkmood")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white]), center: .top, startRadius: 50, endRadius: 500)
                    .ignoresSafeArea()
            }
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.0))
                    .frame(width: 400, height: 400)
                    .shadow(color: Color.black.opacity(1.9), radius: 30, x: 0, y: 4)
                    .overlay(
                        VStack {
                            HStack {
                                // ADD button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        // Find all videos in the bundle
                                        let allVideos = (1...8).map { "video-\($0)" }
                                        
                                        // Find unadded videos
                                        let unaddedVideos = allVideos.filter { !videoNames.contains($0) }
                                        
                                        if let newVideo = unaddedVideos.randomElement() {
                                            videoNames.append(newVideo)
                                            players.removeAll() // Reset players to avoid issues
                                        }
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 0.9, green: 0.7, blue: 0.2),
                                                        Color(red: 1.0, green: 0.85, blue: 0.4),
                                                        Color(red: 0.8, green: 0.6, blue: 0.2)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                            .frame(width: 30, height: 40)
                                        Image(systemName: "plus")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.1))
                                    }
                                }
                                .shadow(radius: 5)
                                .padding(.horizontal, 141)
                                .padding(.top, -76)

                                // DELETE button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        if !videoNames.isEmpty {
                                            // Remove the selected video
                                            videoNames.remove(at: selectedIndex)
                                            
                                            // Remove associated player to prevent memory leaks
                                            players.removeValue(forKey: selectedIndex)
                                            
                                            // Adjust selectedIndex to prevent crashes
                                            selectedIndex = max(0, min(selectedIndex, videoNames.count - 1))
                                        }
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 0.9, green: 0.7, blue: 0.2),
                                                        Color(red: 1.0, green: 0.85, blue: 0.4),
                                                        Color(red: 0.8, green: 0.6, blue: 0.2)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                            .frame(width: 30, height: 40)
                                        
                                        Image(systemName: "minus")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.1))
                                    }
                                }
                                .shadow(radius: 5)
                                .padding(.horizontal, 141)
                                .padding(.top, -76)

                            }
                            Spacer()
                            if videoNames.isEmpty {
                                Text("No videos left")
                                    .font(.title)
                                    .foregroundColor(.white)
                            } else {
                                ZStack {
                                    ForEach(videoNames.indices, id: \.self) { index in
                                        coverItem(for: index)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                    selectedIndex = index
                                                }
                                            }
                                    }
                                }
                                .frame(height: 360)
                            }
                            Spacer()
                        }
                        .padding()
                    )
                Spacer()
            }
            .backgroundCard()
        }
    }

    public func coverItem(for index: Int) -> some View {
        let isCentered = index == selectedIndex
        let spacing: CGFloat = 185
        let rotation: Double = isCentered ? 0 : (index < selectedIndex ? -50 : 50)
        let scale: CGFloat = isCentered ? 1.1 : 1.0
        let xOffset = CGFloat(index - selectedIndex) * spacing
        let videoSize: CGFloat = 200
        let reflectionWidthMultiplier: CGFloat = 1.0 // Adjust this (e.g., 0.8 for narrower reflection)

        let player = createPlayer(for: index, videoName: videoNames[index])
        // Play the selected video, pause others
        DispatchQueue.main.async {
            self.players.forEach { (index, player) in
                if index == self.selectedIndex {
                    player.play()
                } else {
                    player.pause()
                }
            }
        }
        return VStack(spacing: 0) {
            ZStack {
                if let player = player {
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: videoSize * 1.1, height: videoSize * 1.2)
                        .cornerRadius(10)
                        .shadow(radius: 7)
                        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: -1, z: 0))
                        .scaleEffect(scale)
                        .offset(x: xOffset)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedIndex)
                        .padding(.top, -50)
                    // Reflection effect
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: videoSize * reflectionWidthMultiplier, height: videoSize * 1.8)
                        .scaleEffect(y: -1)
                        .mask(
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.15), Color.black.opacity(0.0), Color.clear]), startPoint: .top, endPoint: .bottom)
                        )
                        .blur(radius: -5)
                        .opacity(0.9)
                        .offset(y: videoSize)
                        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: -1, z: 0))
                        .scaleEffect(scale)
                        .offset(x: xOffset)
                        .padding(.bottom, -120)
                }
            }
        }
    }

    public func createPlayer(for index: Int, videoName: String) -> AVPlayer? {
        if let existingPlayer = players[index] {
            return existingPlayer
        }

        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("🚨 Video \(videoName).mp4 not found in bundle!")
            return nil
        }

        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        
        DispatchQueue.main.async {
            self.players[index] = player
            if index == self.selectedIndex {
                player.play() // Ensure the selected video starts playing
            }
        }

        return player
    }
}


#endif
