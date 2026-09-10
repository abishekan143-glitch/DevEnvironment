#if os(iOS)

import SwiftUI

public func liquidGlass(content: AnyView) -> some View {
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
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(goldGradient, lineWidth: 2.0)
                    )
                
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.6),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .blur(radius: 2)
            }
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
}

 
#endif
