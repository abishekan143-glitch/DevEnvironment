//
//  ListViewer_iOS.swift
//  DevEnvironment
//
//  Created by SahanaSri on 21/03/25.
//
#if os(iOS)
import Foundation
import SwiftUI
public func displayList(headline: String, items: [String]) -> some View {
    VStack(alignment: .leading, spacing: 5) {
        Text(headline)
            .font(.system(size: 20, weight: .bold))
        
        ForEach(items, id: \..self) { item in
            Text("     ➜ \(item)")
                .font(.body)
        }
        
        Spacer().frame(height: 8)
    }
    .padding()
}
#endif
