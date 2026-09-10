//
//  Validators.swift
//  DevEnvironment
//
//  Created by Kavi Priya on 02/03/25.
//

import Foundation


public func validatePhoneNumber(_ phoneNumber: String) -> (Bool,String) {
    var cleanPhoneNumber = phoneNumber.filter { $0.isNumber }
    
    while cleanPhoneNumber.first == "0"{
        cleanPhoneNumber.removeFirst()
    }
    
    if cleanPhoneNumber.count == 10 {
        return (true,"+91" + cleanPhoneNumber)
    } else if cleanPhoneNumber.count == 12 {
        if cleanPhoneNumber.first == "9" && cleanPhoneNumber[1] == "1" {
            return (true,"+" + cleanPhoneNumber)
        } else {
            return (false,"Phone Number \(phoneNumber) isn't Valid")
        }
    } else if cleanPhoneNumber.count == 13 {
        if cleanPhoneNumber.first == "+" && cleanPhoneNumber[1] == "9" && cleanPhoneNumber[2] == "1" {
            return (true,cleanPhoneNumber)
        } else {
            return (false,"Phone Number \(phoneNumber) isn't Valid")
        }
    } else {
        return (false,"Phone Number \(phoneNumber) isn't Valid")
    }
}



public func validateName(_ name: String) -> (Bool,String) {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else { return (false,"Please Type-In a Name!") }
    
    let allowedCharacters = CharacterSet.letters.union(CharacterSet(charactersIn: ". "))
    if trimmedName.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
        return (false,"\(name) doesn't look like a name!")
    }
    
    var cleanedName = trimmedName.replacingOccurrences(of: ".", with: " ")
    cleanedName = cleanedName.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.joined(separator: " ")
    
    let words = cleanedName.split(separator: " ").map { word in
        return word.prefix(1).uppercased() + word.dropFirst().lowercased()
    }
    
    let formattedName = words.joined(separator: " ")
    
    if formattedName.contains(" "){
        if trimmedName.count < 5 {
            return (false,"How can a name be this short like \(name)?")
        }
        return (true,formattedName)
    } else {
        return (false,"Initial / Surname Missing in \(name)!")
    }
}

public func validateOTP(_ OTP: String) -> (Bool,String) {
      if OTP.isEmpty {
          return (false, "Type-In OTP")
      } else if let otpInt = Int(OTP) {
          if OTP.count == 6 {
              return (true,OTP)
          } else {
              return (false,"Incomplete OTP")
          }
      } else {
         return (false,"Invalid OTP")
      }
}

public func validateEmail(_ inputEmail: String) -> (Bool, String) {
    let email = inputEmail.lowercased() // ✅ Convert to lowercase inside function
    let allowedDomains = ["com", "org", "gov", "in", "net", "edu"]
    let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    
    let isValidFormat = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    let domainComponents = email.components(separatedBy: ".")
    
    if email.isEmpty {
        return (false, "")
    } else if !isValidFormat {
        return (false, "Invalid email format")
    } else if let tld = domainComponents.last?.lowercased(), !allowedDomains.contains(tld) {
        return (true, "Allowed domains: \(allowedDomains.joined(separator: ", "))")
    } else {
        return (true, email) // ✅ Return email in lowercase
    }
}

public func ValidateAddress(_ address: String) -> (Bool, String) {
    if address.isEmpty {
        return (false, "Address can't be empty")
    } else {
        var comma = 0
        var fulstop = 0
        var alphabetCount = 0
        var numberCount = 0
        var characters = Array(address)
        
        var i = 0
        while i < characters.count {
            
            if !(characters[i].isLetter || characters[i].isNumber || characters[i] == "," || characters[i] == "." || characters[i] == "/" || characters[i] == "-" || characters[i] == " ") {
                characters.remove(at: i)
                continue
            }
            
            if characters[i].isLetter {
                alphabetCount += 1
            }
            
            if characters[i].isNumber {
                numberCount += 1
            }
            
            if characters[i] == "," {
                comma += 1
                
                var j = i - 1
                while j >= 0 && characters[j] == " " {
                    characters.remove(at: j)
                    i -= 1
                    j -= 1
                }
                
                var spc = 0
                var k = i + 1
                while k < characters.count && (characters[k] == " " || characters[k] == ",") {
                    if characters[k] == "," {
                         characters.remove(at: k)  // Remove extra commas
                          continue
                    }
                    spc += 1
                    if spc > 1 {
                        characters.remove(at: k)
                        continue
                    }
                    k += 1
                }
                
                if characters[i + 1] != " " {
                    characters.insert(" ", at: i + 1)
                }
                if characters[i - 1] == " " {
                    characters.remove(at: i - 1)
                }
            }
            if characters[i] == "." {
                fulstop += 1
            }
            i += 1
        }
      
        if characters.last != "." {
            characters.append(".")
            fulstop += 1
        }

        let fixedAddress = String(characters)
        
        if comma >= 2 && fulstop == 1 && fixedAddress.count >= 15 && alphabetCount >= 10 && numberCount <= 5 && numberCount > 1 {
            return (true, fixedAddress)
        } else {
            return (false, "Invalid Address")
        }
    }
}
