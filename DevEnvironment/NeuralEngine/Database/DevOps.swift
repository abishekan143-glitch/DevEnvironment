//
//  DevOps.swift
//  DevEnvironment
//
//  Created by Raghul S on 01/03/25.
//

//var clIterator: Int = 0
//var clPrevMsg: String = ""
//var clPrevType: String = ""
//var clPrevLine: Int = -1
//var clPrevFunction: String = ""
//var clPrevClassName: String = ""
//var clPrevFileName: String = ""
//
//public func cl<T>(_ object: Any? = nil, _ msg: T = "Reached Line $line : Iterated $i times", type: String = "Quick Print", line: Int = #line, function: String = #function, file: String = #file){
//    var m = String(describing: msg)
//    if m == "Reached Line $line : Iterated $i times"{
//        m = "Reached Line \(line)"
//    }
//    
//    let filename = file.split(separator: "/").last ?? "No File Name"
//    let className: String
//    if let object = object {
//        className = String(describing: Swift.type(of: object))
//    } else {
//        className = "nil"
//    }
//    
//        
//    if clPrevFileName != filename || clPrevClassName != className || clPrevFunction != function || clPrevType != type{
//        clIterator = 0
//        clPrevFileName = String(filename)
//        clPrevClassName = className
//        clPrevFunction = function
//        clPrevType = type
//        clPrevLine = line
//        print("\(type) : --------------------------")
//        print("\(type) : \(filename) / \(className) / \(function)")
//        print("\(type) : on Line \(line) : \(m)")
//    }
//    else{
//        if clPrevLine != line{
//            clIterator = 0
//            clPrevLine = line
//            print("\(type) : on Line \(line) : \(m)")
//        }
//        else{
//            clIterator += 1
//            print("\(type) : on Line \(line) : \(m) : Iteration \(clIterator)")
//        }
//    }
//    var tableName = "t"+getDate().replacingOccurrences(of: "-", with: "")
//    var toe = getTime()
//    _ = DevOps.executeQuery("insert into \(tableName) (fileName,className,function,type,line,message,toe) values ('\(filename)','\(className)','\(function)','\(type)','\(line)','\(m)','\(toe)');")
//}
//
//public func cl<T>(
//    _ msg: T = "Reached Line $line : Iterated $i times",
//    type: String = "Quick Print",
//    line: Int = #line,
//    function: String = #function,
//    file: String = #file
//) {
//
//    var m: String
//    var className = "Self isnt Passed"
//
//    let mirror = Mirror(reflecting: msg)
//
//    if mirror.displayStyle == .class {
//
//        // msg is a class object
//        className = String(describing: Swift.type(of: msg))
//
//        m = mirror.children
//            .map { String(describing: $0.value) }
//            .joined(separator: ", ")
//
//    } else {
//
//        m = String(describing: msg)
//    }
//
//    if m == "Reached Line $line : Iterated $i times" {
//        m = "Reached Line \(line)"
//    }
//
//    let filename = file.split(separator: "/").last ?? "No File Name"
//    
//        
//    if clPrevFileName != filename || clPrevClassName != className || clPrevFunction != function || clPrevType != type{
//        clIterator = 0
//        clPrevFileName = String(filename)
//        clPrevClassName = className
//        clPrevFunction = function
//        clPrevType = type
//        clPrevLine = line
//        print("\(type) : --------------------------")
//        print("\(type) : \(filename) / \(className) / \(function)")
//        print("\(type) : on Line \(line) : \(m)")
//    }
//    else{
//        if clPrevLine != line{
//            clIterator = 0
//            clPrevLine = line
//            print("\(type) : on Line \(line) : \(m)")
//        }else{
//            clIterator += 1
//            print("\(type) : on Line \(line) : \(m) : Iteration \(clIterator)")
//        }
//    }
//    
//    var tableName = "t"+getDate().replacingOccurrences(of: "-", with: "")
//    var toe = getTime()
//    _ = DevOps.executeQuery("insert into \(tableName) (fileName,className,function,type,line,message,toe) values ('\(filename)','\(className)','\(function)','\(type)','\(line)','\(m)','\(toe)');")
//}

import SwiftUI
import Foundation


var clIterator: Int = 0

var clPrevMsg: String = ""

var clPrevType: String = ""

var clPrevLine: Int = -1

var clPrevFunction: String = ""

var clPrevClassName: String = ""

var clPrevFileName: String = ""

var hasPrintedDatabasePath = false


// MARK: - CL With Object

public func cl<T>(
    _ object: Any? = nil,
    _ msg: T = "Reached Line $line : Iterated $i times",
    type: String = "Quick Print",
    line: Int = #line,
    function: String = #function,
    file: String = #file
) {
    
 
 
    var m = String(describing: msg)

    if m == "Reached Line $line : Iterated $i times" {
        m = "Reached Line \(line)"
    }

    // ADD THIS
    let databasePath = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("DevOps.sqlite3")
        .path

    if !hasPrintedDatabasePath {
        print("open -R \"\(databasePath)\"")
        hasPrintedDatabasePath = true
    }
    let filename = file.split(separator: "/").last ?? "No File Name"

    let className: String

    if let object = object {
        className = String(describing: Swift.type(of: object))
    } else {
        className = "nil"
    }


    // FILE CHANGED
    if clPrevFileName != filename {

        clIterator = 0

        clPrevFileName = String(filename)
        clPrevClassName = className
        clPrevFunction = function
        clPrevType = type
        clPrevLine = line
        clPrevMsg = m

        print("\(type) : --------------------------")
        print("\(type) : \(filename) : \(className) : \(function)")
        print("\(type) : On line \(line) : \(m)")
    }

    // SAME FILE
    else {

        if clPrevClassName != className ||
           clPrevFunction != function ||
           clPrevType != type {

            clIterator = 0

            clPrevClassName = className
            clPrevFunction = function
            clPrevType = type
            clPrevLine = line
            clPrevMsg = m

            print("\(type) : \(filename) : \(className) : \(function)")
            print("\(type) : On line \(line) : \(m)")
        }

        else {

            if clPrevLine != line {

                clIterator = 0
                clPrevLine = line
                clPrevMsg = m

                print("\(type) : \(filename) : \(className) : \(function)")
                print("\(type) : On line \(line) : \(m)")
            }

            else {

                clIterator += 1

                print("\(type) : \(filename) : \(className) : \(function)")
                print("\(type) : On line \(line) : \(m) : Iteration \(clIterator)")
            }
        }
    }


    // MARK: - Database

    let tableName = "t" + getDate()
        .replacingOccurrences(of: "-", with: "")

    let toe = getTime()

    _ = DevOps.executeQuery("""
        INSERT INTO \(tableName)
        (fileName, className, function, type, line, message, toe)
        VALUES
        ('\(filename)',
         '\(className)',
         '\(function)',
         '\(type)',
         '\(line)',
         '\(m)',
         '\(toe)');
        """)
}



// MARK: - CL Without Object

public func cl<T>(
    _ msg: T = "Reached Line $line : Iterated $i times",
    type: String = "Quick Print",
    line: Int = #line,
    function: String = #function,
    file: String = #file
) {

    var m: String

    var className = "Self isnt Passed"

    let mirror = Mirror(reflecting: msg)

    if mirror.displayStyle == .class {

        className = String(describing: Swift.type(of: msg))

        m = mirror.children
            .map {
                String(describing: $0.value)
            }
            .joined(separator: ", ")

    } else {

        m = String(describing: msg)
    }


    if m == "Reached Line $line : Iterated $i times" {
        m = "Reached Line \(line)"
    }

    let databasePath = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("DevOps.sqlite3")
        .path

    if !hasPrintedDatabasePath {
        print("open -R \"\(databasePath)\"")
        hasPrintedDatabasePath = true
    }

    let filename = file.split(separator: "/").last ?? "No File Name"


    // FILE CHANGED
    if clPrevFileName != filename {

        clIterator = 0

        clPrevFileName = String(filename)
        clPrevClassName = className
        clPrevFunction = function
        clPrevType = type
        clPrevLine = line
        clPrevMsg = m

        print("\(type) : --------------------------")
        print("\(type) : \(filename) : \(className) : \(function)")
        print("\(type) : On line \(line) : \(m)")
    }

    // SAME FILE
    else {

        if clPrevClassName != className ||
           clPrevFunction != function ||
           clPrevType != type {

            clIterator = 0

            clPrevClassName = className
            clPrevFunction = function
            clPrevType = type
            clPrevLine = line
            clPrevMsg = m

            print("\(type) : \(filename) : \(className) : \(function)")
            print("\(type) : On line \(line) : \(m)")
        }

        else {

            if clPrevLine != line {

                clIterator = 0
                clPrevLine = line
                clPrevMsg = m

                print("\(type) : \(filename) : \(className) : \(function)")
                print("\(type) : On line \(line) : \(m)")
            }

            else {

                clIterator += 1

                print("\(type) : \(filename) : \(className) : \(function)")
                print("\(type) : On line \(line) : \(m) : Iteration \(clIterator)")
            }
        }
    }


    // MARK: - Database

    let tableName = "t" + getDate()
        .replacingOccurrences(of: "-", with: "")

    let toe = getTime()

    _ = DevOps.executeQuery("""
        INSERT INTO \(tableName)
        (fileName, className, function, type, line, message, toe)
        VALUES
        ('\(filename)',
         '\(className)',
         '\(function)',
         '\(type)',
         '\(line)',
         '\(m)',
         '\(toe)');
        """)
}


var elIterator: Int = 0

var elPrevMsg: String = ""

var elPrevType: String = ""

var elPrevLine: Int = -1

var elPrevFunction: String = ""

var elPrevClassName: String = ""

var elPrevFileName: String = ""





public func el<T>(
    _ object: Any? = nil,
    _ msg: T = "Reached Line $line : Iterated $i times",
    type: String = "Quick Print",
    line: Int = #line,
    function: String = #function,
    file: String = #file
) {

    var m = String(describing: msg)

    if m == "Reached Line $line : Iterated $i times" {
        m = "Reached Line \(line)"
    }

    let filename = file.split(separator: "/").last ?? "No File Name"

    let className: String

    if let object = object {
        className = String(describing: Swift.type(of: object))
    } else {
        className = "nil"
    }


    // =========================================================
    // NEW FILE
    // =========================================================

    if elPrevFileName != String(filename) {

        elIterator = 0

        elPrevFileName = String(filename)
        elPrevClassName = className
        elPrevFunction = function
        elPrevType = type
        elPrevLine = line
        elPrevMsg = m

        print("\(type) : --------------------------")
        print("\(type) : \(filename) : \(className) : \(function)")
        print("\(type) : On line \(line) : \(m)")
    }

    else {

        // New class / function / type / line
        if elPrevClassName != className ||
           elPrevFunction != function ||
           elPrevType != type ||
           elPrevLine != line {

            elIterator = 0

            elPrevClassName = className
            elPrevFunction = function
            elPrevType = type
            elPrevLine = line
            elPrevMsg = m

            print("\(type) : \(filename) : \(className) : \(function)")
            print("\(type) : On line \(line) : \(m)")
        }

        else {

            elIterator += 1

            print("\(type) : \(filename) : \(className) : \(function)")
            print("\(type) : On line \(line) : \(m) : Iteration \(elIterator)")
        }
    }


    // =========================================================
    // DATABASE
    // =========================================================

    let toe = getTime()
    let doe = getDate()

    _ = AppleAlerts.executeQuery("""
        INSERT INTO error_logs
        (fileName, className, function, type, line, message, doe, toe)
        VALUES
        ('\(filename)',
         '\(className)',
         '\(function)',
         '\(type)',
         '\(line)',
         '\(m)',
         '\(doe)',
         '\(toe)');
        """)
}



// MARK: - EL Without Object

public func el<T>(
    _ msg: T = "Reached Line $line : Iterated $i times",
    type: String = "Quick Print",
    line: Int = #line,
    function: String = #function,
    file: String = #file
) {

    var m: String

    var className = "Self isnt Passed"

    let mirror = Mirror(reflecting: msg)

    if mirror.displayStyle == .class {

        className = String(describing: Swift.type(of: msg))

        m = mirror.children
            .map {
                String(describing: $0.value)
            }
            .joined(separator: ", ")

    } else {

        m = String(describing: msg)
    }


    if m == "Reached Line $line : Iterated $i times" {
        m = "Reached Line \(line)"
    }

    let filename = file.split(separator: "/").last ?? "No File Name"


    // =========================================================
    // NEW FILE
    // =========================================================

    if elPrevFileName != String(filename) {

        elIterator = 0

        elPrevFileName = String(filename)
        elPrevClassName = className
        elPrevFunction = function
        elPrevType = type
        elPrevLine = line
        elPrevMsg = m

        print("\(type) : --------------------------")
        print("\(type) : \(filename) : \(className) : \(function)")
        print("\(type) : On line \(line) : \(m)")
    }

    // =========================================================
    // SAME FILE
    // =========================================================

    else {

        // New class / function / type / line
        if elPrevClassName != className ||
           elPrevFunction != function ||
           elPrevType != type ||
           elPrevLine != line {

            elIterator = 0

            elPrevClassName = className
            elPrevFunction = function
            elPrevType = type
            elPrevLine = line
            elPrevMsg = m

            print("\(type) : \(filename) : \(className) : \(function)")
            print("\(type) : On line \(line) : \(m)")
        }

        // Same file + same class + same function + same type + same line
        else {

            elIterator += 1

            print("\(type) : \(filename) : \(className) : \(function)")
            print("\(type) : On line \(line) : \(m) : Iteration \(elIterator)")
        }
    }


    // =========================================================
    // DATABASE
    // =========================================================

    let toe = getTime()
    let doe = getDate()

    _ = AppleAlerts.executeQuery("""
        INSERT INTO error_logs
        (fileName, className, function, type, line, message, doe, toe)
        VALUES
        ('\(filename)',
         '\(className)',
         '\(function)',
         '\(type)',
         '\(line)',
         '\(m)',
         '\(doe)',
         '\(toe)');
        """)
}
