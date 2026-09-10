//
//  AudioUploader.swift
//  DevEnvironment
//
//  Created by KaviPriya, Yaazhini on 27/03/25.
//
#if os(iOS)
import SwiftUI
import AVFoundation

public struct AudioUploderView: View {
    var audioFiles: [String]
    @State private var audioPlayer: AVAudioPlayer?
    private var audioPlayerDelegate = AudioPlayerDelegate()
    @State private var currentPlayingIndex: Int? = nil
    @State private var waveforms: [[CGFloat]] = []
    @State private var isPlaying = false
    @State private var currentTimeDict: [Int: String] = [:]
    @State private var totalTimeDict: [Int: String] = [:]
    @State private var playProgress: [Int: CGFloat] = [:]
    @State private var timers: [Int: Timer] = [:]
    @State private var visibleCards: Set<Int> = []
    @State private var showToast = false
    @State private var toastMessage = "No more audios"
    @State private var showDeleteButton: Set<Int> = []
    @State private var deletedAudioIndices: Set<Int> = []
    @Environment(\.colorScheme) var colorScheme
    public init(audioFiles: [String]) {
        self.audioFiles = audioFiles
    }
    // Pagination variables
    @State private var currentPage: Int = 0
    private let itemsPerPage: Int = 3 // Number of audio cards per page

    var totalPages: Int {
        return (audioFiles.count + itemsPerPage - 1) / itemsPerPage // Calculate total pages
    }

    var visibleAudioFiles: [String] {
        let startIndex = currentPage * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, audioFiles.count)
        return Array(audioFiles[startIndex..<endIndex])
    }

    public var body: some View {
        VStack {
            BigTranslucentCard {
                VStack {
                    Button(action: {
                        revealNextAudioCard()
                    }) {
                        ZStack {
                            Text("Record/Upload")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .padding(50)
                                .frame(width: 320, height: 50)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.goldGradient, lineWidth: 4)
                                )
                                .cornerRadius(15)
                            
                            Image(systemName: "microphone.fill")
                                .resizable()
                                .frame(width: 15, height: 25)
                                .foregroundColor(.black)
                                .offset(x: 90)
                        }
                    }
                    .padding(.horizontal, 1)
                    .padding(.top, 20)
                    Spacer().frame(height: 30)
                    ScrollView {
                        VStack(spacing: 45) { // Adjust spacing as needed
                            ForEach(visibleAudioFiles.indices, id: \.self) { index in
                                let actualIndex = currentPage * itemsPerPage + index
                                if visibleCards.contains(actualIndex) {
                                    SmallTranslucentCard {
                                        VStack {
                                            ZStack(alignment: .topTrailing) {
                                                WaveformView(samples: waveforms.indices.contains(actualIndex) ? waveforms[actualIndex] : [], playProgress: Binding(
                                                    get: { playProgress[actualIndex, default: 0.0] },
                                                    set: { playProgress[actualIndex] = $0 }
                                                ), onSeek: { progress in
                                                    seekToProgress(progress, for: actualIndex)
                                                })
                                                .frame(height: 40)
                                                .padding(.top, 5)
                                                .padding(.leading, 68)
                                                .padding(.top, 8)
                                                
                                                HStack {
                                                    Button(action: {
                                                        togglePlayPause(at: actualIndex)
                                                    }) {
                                                        Image(systemName: currentPlayingIndex == actualIndex && isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                                            .resizable()
                                                            .frame(width: 35, height: 35)
                                                            .foregroundColor(.black)
                                                            .padding(.trailing, 50)
                                                            .padding(.top, 10)
                                                    }
                                                    .offset(x: 20)
                                                    
                                                    Spacer()
                                                }
                                                
                                                VStack(alignment: .trailing) {
                                                    Text("\(currentPlayingIndex == actualIndex ? (currentTimeDict[actualIndex] ?? "0:00") : totalTimeDict[actualIndex] ?? "--:--")")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                        .padding(.trailing, -5)
                                                        .padding(.vertical, 8)
                                                        .offset(x:-10,y: 13)
                                                }
                                                .padding(.leading, 290)
                                                
                                                if showDeleteButton.contains(actualIndex) {
                                                    Button(action: {
                                                        deleteAudio(at: actualIndex)
                                                    }) {
                                                        ZStack {
                                                            Circle()
                                                                .fill(Color.white.opacity(1))
                                                                .frame(width: 20, height: 20)
                                                            
                                                            Image(systemName: "xmark")
                                                                .resizable()
                                                                .frame(width: 10, height: 10)
                                                                .foregroundColor(.gray)
                                                        }
                                                    }
                                                    .transition(.opacity)
                                                    .offset(x: -13, y: 0)
                                                }
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onLongPressGesture {
                                            toggleDeleteButton(for: actualIndex)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 20) // Add padding to the bottom of the ScrollView
                    }
                    .frame(height: 400) // Set a fixed height for the ScrollView
                    
                    // Pagination controls
                    HStack {
                        Button(action: {
                            if currentPage > 0 {
                                currentPage -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .frame(width: 20, height: 30)
                                .foregroundColor(currentPage > 0 ? .blue : .gray)
                        }
                        .disabled(currentPage == 0)

                        Spacer()

                        // Display current page number
                        Text("\(currentPage + 1)/\(totalPages)")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)

                        Spacer()

                        Button(action: {
                            if (currentPage + 1) < totalPages {
                                currentPage += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 20, height: 30)
                                .foregroundColor((currentPage + 1) < totalPages ? .blue : .gray)
                        }
                        .disabled((currentPage + 1) >= totalPages)
                    }
                    .padding(.top, -50)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding()
            }
            Spacer()

            if showToast {
                Text(toastMessage)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.secondary)
                    .cornerRadius(25)
                    .padding(.bottom, 90)
                    .transition(.slide)
            }
        }
        .onAppear {
            if showToast {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    showToast = false
                }
            }
        }
    }

    public func revealNextAudioCard() {
        if let deletedIndex = deletedAudioIndices.first {
            deletedAudioIndices.remove(deletedIndex)
            visibleCards.insert(deletedIndex)

            // Preload waveform data
            if let audioURL = Bundle.main.url(forResource: audioFiles[deletedIndex], withExtension: "mp3") {
                DispatchQueue.global(qos: .userInitiated).async {
                    let waveform = extractWaveform(from: audioURL)
                    let duration = getTotalAudioDuration(url: audioURL)
                    DispatchQueue.main.async {
                        waveforms[deletedIndex] = waveform
                        totalTimeDict[deletedIndex] = duration
                    }
                }
            }
        } else {
            let nextIndex = visibleCards.count
            if nextIndex < audioFiles.count {
                visibleCards.insert(nextIndex)
                // Preload waveform data
                DispatchQueue.global(qos: .userInitiated).async {
                    if let audioURL = Bundle.main.url(forResource: audioFiles[nextIndex], withExtension: "mp3"), waveforms.indices.contains(nextIndex) == false {
                        let waveform = extractWaveform(from: audioURL)
                        let duration = getTotalAudioDuration(url: audioURL)
                        DispatchQueue.main.async {
                            waveforms.append(waveform)
                            totalTimeDict[nextIndex] = duration
                        }
                    }
                }
            } else {
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showToast = false
                }
            }
        }
    }
    public func togglePlayPause(at index: Int) {
        if currentPlayingIndex == index {
            if isPlaying {
                audioPlayer?.pause()
                isPlaying = false
                timers[index]?.invalidate()
            } else {
                audioPlayer?.play()
                isPlaying = true
                startTimer(for: index)
            }
        } else {
            // Immediately update the waveform display
            if waveforms.indices.contains(index) {
                // Set a default waveform or show loading state
                playProgress[index] = 0.0 // Reset progress
            }
            playAudio(at: index)
        }
    }
    public func playAudio(at index: Int) {
        if let player = audioPlayer, player.isPlaying {
            player.stop()
        }

        currentPlayingIndex = index
        isPlaying = true
        timers.values.forEach { $0.invalidate() }
        currentTimeDict[index] = "0:00"
        playProgress[index] = 0.0

        if let audioURL = Bundle.main.url(forResource: audioFiles[index], withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.delegate = audioPlayerDelegate
                audioPlayerDelegate.onFinishPlaying = {
                    resetAudioCard(for: index)
                }
                audioPlayer?.play()
                startTimer(for: index)
            } catch {
                print("Error loading \(audioFiles[index]): \(error)")
            }
        }
    }

    public func seekToProgress(_ progress: CGFloat, for index: Int) {
        guard let player = audioPlayer, currentPlayingIndex == index else { return }
        let duration = player.duration
        let newTime = duration * Double(progress)
        player.currentTime = newTime
        playProgress[index] = progress
    }

    public func startTimer(for index: Int) {
        timers[index]?.invalidate()
        timers[index] = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateCurrentTime(for: index)
        }
    }

    public func updateCurrentTime(for index: Int) {
        guard let player = audioPlayer, currentPlayingIndex == index, player.isPlaying else { return }

        let progress = CGFloat(player.currentTime / player.duration)
        playProgress[index] = progress

        let totalSeconds = Int(player.currentTime)
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        currentTimeDict[index] = String(format: "%d:%02d", minutes, seconds)
    }

    public func getTotalAudioDuration(url: URL) -> String {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            let totalSeconds = Int(player.duration)
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            return String(format: "%d:%02d", minutes, seconds)
        } catch {
            print("Error getting duration: \(error)")
            return "--:--"
        }
    }

    public func toggleDeleteButton(for index: Int) {
        if showDeleteButton.contains(index) {
            showDeleteButton.remove(index)
        } else {
            showDeleteButton.insert(index)
        }
    }

    public func deleteAudio(at index: Int) {
        if currentPlayingIndex == index {
            audioPlayer?.stop()
            isPlaying = false
            currentPlayingIndex = nil
        }

        visibleCards.remove(index)
        deletedAudioIndices.insert(index)

        if waveforms.indices.contains(index) {
            waveforms[index] = []
        }

        totalTimeDict.removeValue(forKey: index)
        playProgress.removeValue(forKey: index)
        currentTimeDict.removeValue(forKey: index)
        timers[index]?.invalidate()
        timers.removeValue(forKey: index)
        showDeleteButton.remove(index)
    }

    public func resetAudioCard(for index: Int) {
        DispatchQueue.main.async {
            isPlaying = false
            currentPlayingIndex = nil
            currentTimeDict[index] = "0:00"
            playProgress[index] = 0.0
            timers[index]?.invalidate()
        }
    }
}

// Function to extract waveform
public func extractWaveform(from url: URL) -> [CGFloat] {
    do {
        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        let frameCount = AVAudioFrameCount(file.length)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        try file.read(into: buffer)
        let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(frameCount)))
        let downSampled = samples.chunked(into: 100).map { chunk in
            CGFloat(chunk.map(abs).max() ?? 0)
        }
        return downSampled
    } catch {
        print("Error extracting waveform: \(error)")
        return []
    }
}

public func WaveformView(samples: [CGFloat], playProgress: Binding<CGFloat>, onSeek: @escaping (CGFloat) -> Void) -> some View {
    return GeometryReader { geometry in
        let waveformWidth = geometry.size.width
        let barWidth: CGFloat = 3
        let spacing: CGFloat = 5
        
        let rightSideLimit: CGFloat = 0.80
        
        let visibleWidth = waveformWidth * rightSideLimit
        let maxBars = Int(visibleWidth / (barWidth + spacing))
        let scaledSamples = downsample(samples, to: maxBars)

        let progressIndex = Int(playProgress.wrappedValue * CGFloat(maxBars))

        ZStack(alignment: .leading) {
            HStack(spacing: spacing) {
                ForEach(scaledSamples.indices, id: \ .self) { index in
                    let sample = scaledSamples[index]
                    RoundedRectangle(cornerRadius: barWidth / 2)
                        .fill(index < progressIndex ? Color.blue : Color.white.opacity(0.6))
                        .frame(width: barWidth, height: max(sample * 30, 4))
                        .animation(.easeInOut(duration: 0.1), value: playProgress.wrappedValue)
                }
            }
            .frame(width: visibleWidth, height: 30)
            .clipped()

            Circle()
                .fill(Color.blue)
                .frame(width: 15, height: 15)
                .offset(x: min(playProgress.wrappedValue * (visibleWidth - 20), visibleWidth - 20))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let clampedX = min(max(value.location.x, 0), visibleWidth - 20)
                            let newProgress = (clampedX / (visibleWidth - 20)).clamped(to: 0...1)
                            onSeek(newProgress)
                        }
                )
                .animation(.easeInOut(duration: 0.2), value: playProgress.wrappedValue)
        }
    }
    .frame(height: 40)
}

    public func downsample(_ samples: [CGFloat], to targetCount: Int) -> [CGFloat] {
        guard samples.count > targetCount else { return samples }
        let chunkSize = samples.count / targetCount
        return stride(from: 0, to: samples.count, by: chunkSize).map { i in
            Array(samples[i..<min(i + chunkSize, samples.count)]).max() ?? 0
        }
    }


public extension Comparable {
    public func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public extension CGFloat {
    public func clamped(to limits: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
    }
}

public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

public extension Color {
    static let goldGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.yellow.opacity(0.8),
            Color.orange.opacity(0.9),
            Color.yellow.opacity(0.6)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

public func BigTranslucentCard<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
    return VStack {
        content()
    }
    .frame(width: 350, height: 500)
    .background(Color.white.opacity(0.1))
    .cornerRadius(20)
    .shadow(color: .black.opacity(0.1), radius: 9, x: 0, y: 5)
    .overlay(
        RoundedRectangle(cornerRadius: 25)
            .stroke(Color.goldGradient, lineWidth: 2)
    )
    .offset(y: 100)
}


public func SmallTranslucentCard<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
    return VStack {
        content()
    }
    .frame(width: 320, height: 63)
    .background(Color.white.opacity(0.05))
    .cornerRadius(20)
    .shadow(color: .black.opacity(0.1), radius: 9, x: 0, y: 5)
    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.goldGradient, lineWidth: 1.5))
}

// Define the AudioPlayerDelegate class
public class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinishPlaying: (() -> Void)?

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinishPlaying?()
    }
}
#endif
