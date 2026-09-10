//
//  FileUploader.swift
//  DevEnvironment
//
//  Created by Kajol on 27/03/25.
//
#if os(iOS)
import SwiftUI
import UIKit

public struct FileUploadView: View {
    @State private var fileNameArray: [String] = []
    @State private var currentFileIndex: Int = 0
    @State private var fileMarkedForDeletion: String? = nil
    @Binding var selectedFileNames: [String]
    
    public init(selectedFileNames: Binding<[String]>) {
        self._selectedFileNames = selectedFileNames
    }

    
    public var body: some View {
        VStack {
            // Upload Button
            Button(action: {
                withAnimation {
                    importFile()
                }
            }) {
                Image(systemName: "icloud.and.arrow.up")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.blue)
                    .padding(.top, 50)
            }
            
            // Scrollable File Stack
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 25) {
                    ForEach(fileNameArray, id: \ .self) { fileName in
                        ZStack {
                            // File Display
                            Text(fileNameDisplay(fileName))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .frame(width: 100, height: 90)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(10)
                                .onLongPressGesture {
                                    withAnimation {
                                        fileMarkedForDeletion = fileName
                                    }
                                }
                            
                            // Delete Button
                            if fileMarkedForDeletion == fileName {
                                Button(action: {
                                    withAnimation {
                                        removeFile(fileName)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.gray)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                                .offset(x: 40, y: -40)
                            }
                        }
                        .frame(width: 100, height: 100)
                        .padding(.top, 70)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
            Spacer(minLength: 0)
        }
        .frame(width: 330, height: 290)
        .background(
            BlurView(style: .systemUltraThinMaterial)
                .opacity(0.3)
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 3.0)
        )
        .padding()
    }
    
    public func fileNameDisplay(_ fileName: String) -> String {
        if fileName.count <= 10 {
            return fileName
        } else {
            let firstPart = String(fileName.prefix(10))
            let lastPart = String(fileName.suffix(10))
            return "\(firstPart)\n..............\n\(lastPart)"
        }
    }
    
    public func importFile() {
        if currentFileIndex < selectedFileNames.count {
            let newFileName = selectedFileNames[currentFileIndex]
            withAnimation {
                fileNameArray.append(newFileName)
            }
            currentFileIndex += 1
        }
    }
    
    public func removeFile(_ fileName: String) {
        if let index = fileNameArray.firstIndex(of: fileName) {
            fileNameArray.remove(at: index)
        }
        fileMarkedForDeletion = nil
    }
}

public struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    public init(style: UIBlurEffect.Style) {
        self.style = style
    }

    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
#endif
