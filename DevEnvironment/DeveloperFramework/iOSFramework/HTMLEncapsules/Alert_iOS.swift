#if os(iOS)
import Foundation
import SwiftUI

public struct SmartAlert: View {
    let title: String
    @Binding var showAlert: Bool
    @State private var alertOffset: CGFloat = -100
    @State private var opacity: Double = 0

    public var body: some View {
        ZStack {
            if showAlert {
                GeometryReader { geometry in
                    Text(title)
                        .padding()
                        .font(.system(size: 13))
                        .background(
                            LinearGradient(gradient: Gradient(colors: [
                                Color(red: 0.82, green: 0.50, blue: 0.02), // Gold
                                Color(red: 0.98, green: 0.8, blue: 0.41),
                                Color(red: 0.82, green: 0.50, blue: 0.02)
                            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .multilineTextAlignment(.leading)
                        .cornerRadius(20)
                        .frame(width: 350)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .foregroundColor(.black)
                        .offset(y: alertOffset)
                        .position(x: geometry.size.width/2, y: 80)
                        .opacity(opacity)
                        .onAppear {
                            
                            let characterCount = title.count
                            let duration: Double
                            if characterCount < 10 {
                                duration = 3 // short
                            } else if characterCount < 30 {
                                duration = 5
                            } else if characterCount < 50 {
                                duration = 7
                            } else if characterCount < 80 {
                                        duration = 11
                            } else if characterCount < 150 {
                                duration = 19 // medium
                            } else {
                                duration = 30 // long
                            }

                            // Reset the alert before showing
                            alertOffset = -100
                            opacity = 0
                            withAnimation(.easeOut(duration: 0.5)) {
                                alertOffset = -50
                                opacity = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration - 1.5) {
                                withAnimation {
                                    alertOffset = -100
                                    opacity = 0
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                showAlert = false
                            }
                        }
                }
            }
        }
        .zIndex(1)
    }
}

public struct SmartConfirmAlert1: View {
    var title: String
    @Binding var showAlert: Bool
    var onCancel: () -> Void
    var onConfirm: () -> Void
    @Binding var isPresented: Bool
    @State private var alertOffset: CGFloat = -400
    @State private var opacity: Double = 0
    
    public init(title: String,
                onCancel: @escaping () -> Void,
                onConfirm: @escaping () -> Void,
                isPresented: Binding<Bool>) {
        self.title = title
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        self._showAlert = isPresented
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            if showAlert {
                VStack(spacing: 5) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding()
                        .cornerRadius(6)
                        .shadow(radius: 2)
                     
                    HStack(spacing: 20) {
                        // Cancel → Smart Red Button
                        SmartRedButton(label: "Cancel") {
                            onCancel()
                        }

                        // Confirm → Smart Green Button
                        SmartGreenButton(label: "OK") {
                            onConfirm()
                        }
                    }
                }
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [
                                Color(red: 0.82, green: 0.50, blue: 0.02),
                                Color(red: 0.98, green: 0.8, blue: 0.41)
                            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(radius: 5)
                )
                .frame(width: 350)
                .offset(x: 0, y: alertOffset)
                .animation(.easeInOut(duration: 0.3), value: alertOffset)
                .opacity(opacity)
                .onAppear {
                    let characterCount = title.count
                    let duration: Double
                    if characterCount < 10 {
                        duration = 3
                    } else if characterCount < 30 {
                        duration = 5
                    } else if characterCount < 50 {
                        duration = 7
                    } else if characterCount < 80 {
                        duration = 11
                    } else if characterCount < 150 {
                        duration = 19
                    } else {
                        duration = 30
                    }

                    alertOffset = -400
                    opacity = 0
                    withAnimation(.easeOut(duration: 0.5)) {
                        alertOffset = -300
                        opacity = 1
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            alertOffset = -400
                            opacity = 0
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.2) {
                        isPresented = false
                    }
                }
            }
        }
        .zIndex(1)
    }
}

public struct SmartPrompt: View {
    let title: String
    let content: String
    @Binding var isPresented: Bool
    let onCancel: (String?) -> Void
    let onConfirm: (String?) -> Void

    @State private var offsetY: CGFloat = -UIScreen.main.bounds.height
    @State private var showError = false
    @State private var inputText = ""

    public init(title: String,
                content: String,
                isPresented: Binding<Bool>,
                onCancel: @escaping (String?) -> Void,
                onConfirm: @escaping (String?) -> Void) {
        self.title = title
        self.content = content
        self._isPresented = isPresented
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }

    public var body: some View {
        if isPresented {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black) // fixed color
                    .padding(.top, 6)
                    .multilineTextAlignment(.center)

                
                TextField("", text: $inputText, prompt: Text(content).foregroundColor(.gray))
                    .padding(8)
                    .background(Color.lemonChiffonYellow)
                    .foregroundColor(.black) // typed text always black
                    .cornerRadius(6)
                    .font(.system(size: 14))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    .keyboardType(.default)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(showError ? Color.red : Color.gray, lineWidth: 1.5)
                    )
                    .padding(.horizontal, 10)
                    .onAppear {
                        inputText = ""
                        offsetY = -UIScreen.main.bounds.height
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            offsetY = -300
                        }
                    }

                if showError {
                    Text("Please enter something")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                        .padding(.top, 2)
                }

                HStack(spacing: 12) {
                    SmartRedButton(label: "Cancel") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            closePrompt()
                            onCancel(inputText.isEmpty ? nil : inputText)
                            showError = false
                        }
                    }
                    SmartGreenButton(label: "OK") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            if inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                showError = true
                            } else {
                                showError = false
                                closePrompt()
                                onConfirm(inputText)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.82, green: 0.50, blue: 0.02),
                    Color(red: 0.98, green: 0.8, blue: 0.41)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(12)
            .shadow(radius: 8)
            .frame(width: 250)
            .offset(y: offsetY)
            .zIndex(1)
        }
    }

    public func closePrompt() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            offsetY = -UIScreen.main.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isPresented = false
        }
    }
}

public struct SmartGreenButton: View {
    var label: String
    var action: () -> Void
    @State private var isPressed = false
    @State private var shineOffsets: [CGSize] = [
        .zero,
        CGSize(width: -140 * 1.2, height: -40 * 1.2)
    ]
    @State private var showSecondShine = false
    
    public init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    public var body: some View {
        ZStack {
            outerBorder
            innerContent
        }
        .frame(width: 90, height: 40)
        .onTapGesture {
            if !isPressed {
                isPressed = true
                action()
                startShineAnimations()
            }
        }
    }
    
    public var outerBorder: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // 🔸 Base golden border
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )

                // 🔸 First shimmer (center → right)
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: Color(hex: "#ffd277"), location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: UnitPoint(x: 0 + shineOffsets[0].width / width,
                                                  y: 0 + shineOffsets[0].height / height),
                            endPoint: UnitPoint(x: 1 + shineOffsets[0].width / width,
                                                y: 1 + shineOffsets[0].height / height)
                        ),
                        lineWidth: 3
                    )
                    .blendMode(.screen)

                // 🔸 Second shimmer (left → center)
                if showSecondShine {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: Color(hex: "#ffd277"), location: 0.5),
                                    .init(color: .clear, location: 1.0)
                                ]),
                                startPoint: UnitPoint(x: 0 + shineOffsets[1].width / width,
                                                      y: 0 + shineOffsets[1].height / height),
                                endPoint: UnitPoint(x: 1 + shineOffsets[1].width / width,
                                                    y: 1 + shineOffsets[1].height / height)
                            ),
                            lineWidth: 3
                        )
                        .blendMode(.screen)
                }
            }
        }
    }

    public var innerContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#004d00").opacity(0.85))
                .padding(2)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .padding(2)
                .overlay(shimmerOverlay)
                .mask(
                    RoundedRectangle(cornerRadius: 8)
                        .padding(2)
                )

            Text(label)
                .foregroundColor(Color(hex: "#ffd277"))
                .fontWeight(.bold)
                .font(.system(size: 16))
        }
    }

    public var shimmerOverlay: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                Rectangle()
                    .fill(shimmerGradient)
                    .frame(width: width * 0.5, height: height * 2)
                    .rotationEffect(.degrees(25))
                    .offset(shineOffsets[0])
                    .blur(radius: 25)
                    .blendMode(.screen)

                if showSecondShine {
                    Rectangle()
                        .fill(shimmerGradient)
                        .frame(width: width * 0.5, height: height * 2)
                        .rotationEffect(.degrees(25))
                        .offset(shineOffsets[1])
                        .blur(radius: 25)
                        .blendMode(.screen)
                }
            }
        }
    }

    public var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.yellow.opacity(0.0), location: 0.0),
                .init(color: Color.yellow.opacity(0.3), location: 0.4),
                .init(color: Color.yellow.opacity(0.0), location: 1.0),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public func startShineAnimations() {
        let width: CGFloat = 140
        let height: CGFloat = 40

        // Reset initial positions
        shineOffsets[0] = .zero // Shine 1 starts at center
        shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2) // Shine 2 starts from far left
        showSecondShine = true // Show both shines immediately

        // Animate both shines fast and together
        withAnimation(.easeInOut(duration: 0.8)) {
            shineOffsets[0] = CGSize(width: width * 1.2, height: height * 1.2) // Shine 1 → right
            shineOffsets[1] = .zero // Shine 2 → center
        }

        // Reset to original state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isPressed = false
            shineOffsets[0] = .zero
            shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2)
            showSecondShine = false
        }
    }
}

public struct SmartRedButton: View {
    var label: String
    var action: () -> Void
    @State private var isPressed = false
    @State private var shineOffsets: [CGSize] = [
        .zero, // First shine starts centered
        CGSize(width: -140 * 1.2, height: -40 * 1.2) // Second shine starts off-screen left
    ]
    @State private var showSecondShine = false
    
    public init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }

    public var body: some View {
        ZStack {
            outerBorder
            innerContent
        }
        .frame(width: 90, height: 40)
        .onTapGesture {
            if !isPressed {
                isPressed = true
                action()
                startShineAnimations()
            }
        }
    }
    public var outerBorder: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // 🔸 Base golden border
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a"),
                                Color(hex: "#77530a")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )

                // 🔸 First shimmer (center → right)
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: Color(hex: "#ffd277"), location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: UnitPoint(x: 0 + shineOffsets[0].width / width,
                                                  y: 0 + shineOffsets[0].height / height),
                            endPoint: UnitPoint(x: 1 + shineOffsets[0].width / width,
                                                y: 1 + shineOffsets[0].height / height)
                        ),
                        lineWidth: 3
                    )
                    .blendMode(.screen)

                // 🔸 Second shimmer (left → center)
                if showSecondShine {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: Color(hex: "#ffd277"), location: 0.5),
                                    .init(color: .clear, location: 1.0)
                                ]),
                                startPoint: UnitPoint(x: 0 + shineOffsets[1].width / width,
                                                      y: 0 + shineOffsets[1].height / height),
                                endPoint: UnitPoint(x: 1 + shineOffsets[1].width / width,
                                                    y: 1 + shineOffsets[1].height / height)
                            ),
                            lineWidth: 3
                        )
                        .blendMode(.screen)
                }
            }
        }
    }

    public var innerContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#5b0000").opacity(0.85)) // Dark Maroon
                .padding(2)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .padding(2)
                .overlay(shimmerOverlay)
                .mask(
                    RoundedRectangle(cornerRadius: 8)
                        .padding(2)
                )

            Text(label)
                .foregroundColor(Color(hex: "#ffd277")) // Gold text
                .fontWeight(.bold)
                .font(.system(size: 16))
        }
    }

    public var shimmerOverlay: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                Rectangle()
                    .fill(shimmerGradient)
                    .frame(width: width * 0.5, height: height * 2)
                    .rotationEffect(.degrees(25))
                    .offset(shineOffsets[0])
                    .blur(radius: 25)
                    .blendMode(.screen)

                if showSecondShine {
                    Rectangle()
                        .fill(shimmerGradient)
                        .frame(width: width * 0.5, height: height * 2)
                        .rotationEffect(.degrees(25))
                        .offset(shineOffsets[1])
                        .blur(radius: 25)
                        .blendMode(.screen)
                }
            }
        }
    }

    public var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.yellow.opacity(0.0), location: 0.0),
                .init(color: Color.yellow.opacity(0.3), location: 0.4),
                .init(color: Color.yellow.opacity(0.0), location: 1.0),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public func startShineAnimations() {
        let width: CGFloat = 140
        let height: CGFloat = 40

        // Reset initial positions
        shineOffsets[0] = .zero // Shine 1 starts at center
        shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2) // Shine 2 starts from far left
        showSecondShine = true // Show both shines immediately

        // Animate both shines fast and together
        withAnimation(.easeInOut(duration: 0.8)) {
            shineOffsets[0] = CGSize(width: width * 1.2, height: height * 1.2) // Shine 1 → right
            shineOffsets[1] = .zero // Shine 2 → center
        }

        // Reset to original state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isPressed = false
            shineOffsets[0] = .zero
            shineOffsets[1] = CGSize(width: -width * 1.2, height: -height * 1.2)
            showSecondShine = false
        }
    }
}
#endif
