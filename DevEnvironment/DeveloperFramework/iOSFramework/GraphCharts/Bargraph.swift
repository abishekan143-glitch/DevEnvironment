//
//  Bargraph.swift
//  DevEnvironment
//
//  Created by Shalini Sivakumar on 26/03/25.
//
#if os(iOS)
import SwiftUI
public func BarGraph(title1: String, shareNames: [String], percentage: [CGFloat], size: CGFloat) -> some View {
    let validShareNames = Array(shareNames.prefix(4))
    let validPercentages = Array(percentage.prefix(4))
    let width = size
    let maxBarHeight = size * 0.8
    let paddingBottom: CGFloat = 50
    let predefinedColors: [Color] = [
        Color(red: 229/255, green: 115/255, blue: 115/255),
        Color(red: 240/255, green: 98/255, blue: 146/255),
        Color(red: 186/255, green: 104/255, blue: 200/255),
        Color(red: 100/255, green: 181/255, blue: 246/255)
    ]
    let barWidth = width / 8
    let spacing = barWidth / 2
    var selectedTitleVisible = false

    
    return VStack {
        if shareNames.count >= 5 && percentage.count >= 5 {
            Text("Only the first 4 are used!")
                .foregroundColor(.red)
                .bold()
                .padding()
        }
        
        ZStack {
            Text(title1)
                .foregroundColor(Color.silverGray)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal)
                .onTapGesture {
                    withAnimation {
                        selectedTitleVisible.toggle()
                    }
                }

            if selectedTitleVisible {
                Text(title1)
                    .font(.caption)
                    .padding(8)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .transition(.opacity)
                    .offset(y: 40)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            selectedTitleVisible = false
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, -10)
        
        HStack(alignment: .bottom, spacing: spacing) {
            VStack(alignment: .trailing, spacing: 0) {
                ForEach((0...5).reversed(), id: \.self) { step in
                    let yValue = step * 20
                    Text("\(yValue)%")
                        .foregroundColor(Color.silverGray)
                        .font(.system(size: 12))
                        .frame(height: maxBarHeight / 5, alignment: .bottom)
                }
            }
            .padding(.trailing, 5)
            
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(0..<validShareNames.count, id: \.self) { index in
                    let barHeight = (validPercentages[index] / 100) * maxBarHeight
                    VStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(predefinedColors[index])
                            .frame(width: barWidth, height: barHeight)
                        
                        Text(validShareNames[index])
                            .foregroundColor(Color.silverGray)
                            .font(.system(size: 12))
                            .frame(width: barWidth + 10, height: 15)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                    }
                }
            }
        }
        .frame(width: width + 50, height: maxBarHeight + paddingBottom)
    }
    .padding()
}
#endif
