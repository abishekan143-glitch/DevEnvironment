#if os(iOS)

import SwiftUI

public func backgroundCard(content: AnyView) -> some View {
    let goldGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.yellow.opacity(0.8),
            Color.orange.opacity(0.9),
            Color.yellow.opacity(0.6)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    return content
        .padding(10)
        .frame(
            maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 800 : UIScreen.main.bounds.width * 0.9,
            maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? 800 : UIScreen.main.bounds.height * 0.6
        )
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(SwiftUI.Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(goldGradient, lineWidth: 2.0)
                    )
                
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                SwiftUI.Color.white.opacity(0.6),
                                SwiftUI.Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .blur(radius: 2)
            }
        )
        .shadow(color: SwiftUI.Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
}

public extension View {
    func backgroundCard() -> some View {
        let goldGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color.yellow.opacity(0.8),
                Color.orange.opacity(0.9),
                Color.yellow.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return self
            .padding(10)
            .frame(
                maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 800 : UIScreen.main.bounds.width * 0.9,
                maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? 800 : UIScreen.main.bounds.height * 0.9
            )
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(SwiftUI.Color.white.opacity(0.1)) // Glass Effect
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(goldGradient, lineWidth: 2.0) // Gold Border
                        )
                    
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    SwiftUI.Color.white.opacity(0.6),
                                    SwiftUI.Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .blur(radius: 4) // Softens the inner glow
                }
            )
            .shadow(color: SwiftUI.Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)  // Centers the card horizontally
    }
}
extension View {
    func liquidGlass(cardWidth: CGFloat = 370) -> some View {
        self
            .frame(width: cardWidth)
            .background(
                // Transparent gradient background
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(Color.clear)
            )
            .overlay(
                // Soft border for glass edge
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
#endif
