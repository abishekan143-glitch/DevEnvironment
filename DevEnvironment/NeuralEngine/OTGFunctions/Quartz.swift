//
//  Quartz.swift
//  DevEnvironment
//
//  Created by Raghul S on 28/02/25.
//

import Foundation

public func getDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
}

public func getTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    return formatter.string(from: Date())
}

public func formatDate(_ inputString: String) -> String {
    let containsColon = inputString.contains(":")
    let containsDash = inputString.contains("-") || inputString.contains("/")
    let containsSpace = inputString.contains(" ")
    if containsDash && containsColon {
        let delimiters: CharacterSet = CharacterSet(charactersIn: " &t")
        let parts = inputString.components(separatedBy: delimiters).filter { !$0.isEmpty }
        let fDate = fDate(parts[0])
        let fTime = fTime(parts[1])
        return fDate + " at " + fTime
    } else if (containsColon && !containsDash) || containsSpace {
        return fTime(inputString)
    } else {
        return fDate(inputString)
    }
    func fTime(_ time24: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.amSymbol = "AM"
        outputFormatter.pmSymbol = "PM"

        if let date = inputFormatter.date(from: time24) {
            return outputFormatter.string(from: date)
        } else {
            return ""
        }
    }
    func fDate(_ inputString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let inputFormatter2 = DateFormatter()
        inputFormatter2.dateFormat = "dd-MM-yyyy"
        
        let inputFormatter3 = DateFormatter()
        inputFormatter2.dateFormat = "dd/MM/yyyy"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        if inputFormatter.date(from: inputString) != nil {
            if let date = inputFormatter.date(from: inputString) {
                return outputFormatter.string(from: date)
            }
        } else if inputFormatter2.date(from: inputString) != nil {
            if let date = inputFormatter2.date(from: inputString) {
                return outputFormatter.string(from: date)
            }
        } else {
            if let date = inputFormatter3.date(from: inputString) {
                return outputFormatter.string(from: date)
            }
        }
        return inputString
    }
}



