//
//  Randomize.swift
//  DevEnvironment
//
//  Created by Kavi Priya on 27/02/25.
//

public func generateRandomAlphaNumeric(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
}

public func generateRandomNumber(length: Int) -> String {
    let letters = "0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
}

public func generateRandomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyz"
    return String((0..<length).map { _ in letters.randomElement()! })
}
