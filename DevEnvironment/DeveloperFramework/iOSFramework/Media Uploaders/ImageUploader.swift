#if os(iOS)
import SwiftUI
import PhotosUI

public struct CoverFlowView: View {
    @State private var imageNames = ["image-1", "image-2", "image-3", "image-4", "image-5", "images-6", "image-7", "image-8", "image-9", "image-10"]
    @State private var selectedIndex = 0
    @State private var isAddingImage = false
    @State private var selectedImage: UIImage?

    @Environment(\.colorScheme) var colorScheme
    
    public init() {}


    public var body: some View {
        ZStack {
            // Background
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
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 400, height: 500)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .overlay(
                        VStack {
                            smartButton(title: "Add Image") {
                                isAddingImage = true
                            }

                            Spacer()

                            if imageNames.isEmpty {
                                Text("No images left")
                                    .font(.title)
                                    .foregroundColor(.white)
                            } else {
                                ZStack {
                                    ForEach(imageNames.indices, id: \..self) { index in
                                        CoverImage(image: UIImage(named: imageNames[index]) ?? UIImage(), offset: index - selectedIndex, onClick: {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                selectedIndex = index
                                            }
                                        }, isCentered: index == selectedIndex)
                                    }
                                }
                                .frame(height: 360)
                            }

                            Spacer()

                            if !imageNames.isEmpty {
                                smartButton(title: "Remove Image") {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        imageNames.remove(at: selectedIndex)
                                        if selectedIndex >= imageNames.count {
                                            selectedIndex = max(0, imageNames.count - 1)
                                        }
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                        }
                        .padding()
                    )

                Spacer()
            }
        }
        .sheet(isPresented: $isAddingImage) {
            ImagePicker(image: $selectedImage, onImageSelected: { newImage in
                if let newImage = newImage {
                    imageNames.insert("new-image", at: selectedIndex)
                }
                isAddingImage = false
            })
        }
    }

    public func smartButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(width: 200)
                .background(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.7, blue: 0.2),
                        Color(red: 1.0, green: 0.85, blue: 0.4),
                        Color(red: 0.8, green: 0.6, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.6), radius: 8, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

public struct CoverImage: View {
    let image: UIImage
    let offset: Int
    let onClick: () -> Void
    let isCentered: Bool
    
    public init(image: UIImage, offset: Int, onClick: @escaping () -> Void, isCentered: Bool) {
        self.image = image
        self.offset = offset
        self.onClick = onClick
        self.isCentered = isCentered
    }


    public var body: some View {
        let xOffset = CGFloat(offset * 108)

        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 150)
                .clipped()
                .rotation3DEffect(.degrees(offset == 0 ? 0 : Double(offset * -30)), axis: (x: 0, y: 1, z: 0))
                .opacity(offset == 0 ? 1 : 0.5)
                .onTapGesture { onClick() }
                .offset(x: xOffset)

            Spacer().frame(height: 1.5)

            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 100)
                    .clipped()
                    .scaleEffect(y: -1)
                    .opacity(0.5)
                    .rotation3DEffect(.degrees(-5), axis: (x: 1, y: 0, z: 0))
            }

            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.clear]),
                                   startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 120, height: 50)
        }
        .animation(.easeInOut, value: offset)
    }
}

public struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImageSelected: (String?) -> Void
    
    public init(image: Binding<UIImage?>, onImageSelected: @escaping (String?) -> Void) {
        self._image = image
        self.onImageSelected = onImageSelected
    }

    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImageSelected("new-image")
            }
            picker.dismiss(animated: true)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
#endif
