//
//  QuickAccess.swift
//  DevEnvironment
//
//  Created by ravichandran raju on 19/03/25.
//

import Foundation
public func ua(_ input: String) -> String {
    return input.uppercased()
}
public func uc(_ input: String) -> String {
    let words = input.split(separator: " ", omittingEmptySubsequences: false)
    return words.map { word in
        word.isEmpty ? "" : word.prefix(1).uppercased() + word.dropFirst()
    }.joined(separator: " ")
}
public func nfi(_ input: String) -> (Bool, String?) {
    if input.allSatisfy({ $0.isLetter }) {
        return (false, nil)
    } else if input.contains(where: { $0.isLetter }) {
        return (false, nil)
    }
    let words = input.split(separator: " ", omittingEmptySubsequences: false) // Split words by space
    let formattedWords = words.map { word -> String in
        let cleanedWord = word.replacingOccurrences(of: ",", with: "") // Remove commas
        if let _ = Double(cleanedWord) { // Check if it's a number
            let components = cleanedWord.split(separator: ".", omittingEmptySubsequences: false)
            let integerPart = components.first ?? ""
            let decimalPart = components.count > 1 ? "." + components.dropFirst().joined(separator: ".") : ""

            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = true
            
            if let formattedInteger = formatter.string(from: NSNumber(value: Double(integerPart) ?? 0)) {
                return formattedInteger + decimalPart // Preserve decimal part exactly
            }
        }
        
        return String(word) // Return unchanged if not a number
    }
    return (true, formattedWords.joined(separator: " ")) // Join back words
}

public func numberToText(_ number: Int64) -> String {
    if number == 0 {
        return "zero"
    }
    
    let parts: [(Int64, String)] = [
        (1_00_00_00_00_00_000, "Quintillion"),
        (1_00_00_00_00_000, "Quadrillion"),
        (1_00_00_00_000, "trillion"),
        (1_00_00_00_0, "billion"),
        (1_00_00_000, "million"),
        (1_00_00_0, "crore"),
        (1_00_000, "lakh"),
        (1_000, "thousand"),
        (100, "hundred")
    ]
    let units = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
    let tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
    
     func convertNumToWords(_ num: Int) -> String {
        if num < 20 {
            return units[num]
        } else if num < 100 {
            return tens[num / 10] + (num % 10 > 0 ? " " + units[num % 10] : "")
        } else {
            return units[num / 100] + " hundred" + (num % 100 > 0 ? " and " + convertNumToWords(num % 100) : "")
        }
    }
    
    var num = number
    var words: [String] = []
    
    for (value, name) in parts {
        if num >= value {
            let chunk = num / value
            num %= value
            words.append("\(convertNumToWords(Int(chunk))) \(name)")
        }
    }
    
    if num > 0 {
        words.append(convertNumToWords(Int(num)))
    }
    
    return words.joined(separator: " ")
}
