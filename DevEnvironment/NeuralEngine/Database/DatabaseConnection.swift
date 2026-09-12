//
//  DatabaseConnections.swift
//  DevEnvironment
//
//  Created by Raghul S on 28/02/25.
//
import Foundation
import SQLCipher

private typealias SQLite3Database = OpaquePointer

@_silgen_name("sqlite3_key")
private func sqlcipher_key(
    _ db: SQLite3Database?,
    _ key: UnsafeRawPointer?,
    _ keyLength: Int32
) -> Int32

public class DatabaseConnectionEstablisher {
    public var db: OpaquePointer? = nil
    public var path: String = ""// Make sure to use the actual path to your database file

    public init() {
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("NeuralMemory.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("NeuralMemory.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to open database : NeuralMemory")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to set key for database : NeuralMemory")
                sqlite3_close(db)
                return
            }
            
            SQLiteEngineStrater()
            for eq in SQLQueriesToExcecute {
                executeQuery(eq)
            }

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    public func restart(){
        sqlite3_close(db)
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("NeuralMemory.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("NeuralMemory.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to re-open database : NeuralMemory")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to re-set key for database : NeuralMemory")
                sqlite3_close(db)
                return
            }

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    public func executeQuery(_ query: String) -> (Bool, [[String: String]]?) {
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            var result = sqlite3_step(statement)
            if result == SQLITE_ROW {
                // Handle SELECT queries
                var rows = [[String: String]]()
                repeat {
                    var row = [String: String]()
                    for i in 0..<sqlite3_column_count(statement) {
                        if let columnName = sqlite3_column_name(statement, i) {
                            let name = String(cString: columnName)
                            if let columnText = sqlite3_column_text(statement, i) {
                                let value = String(cString: columnText)
                                row[name] = value
                            }
                        }
                    }
                    rows.append(row)
                    result = sqlite3_step(statement)
                } while result == SQLITE_ROW
                sqlite3_finalize(statement)
                return (true, rows)
            } else if result == SQLITE_DONE {
                // Handle non-SELECT queries (INSERT, UPDATE, DELETE)
                sqlite3_finalize(statement)
                return (true, nil)
            } else {
                // If result is not SQLITE_ROW or SQLITE_DONE, it's an error
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("Failure @ SQL: \(errmsg) Query : \(query)")
                sqlite3_finalize(statement)
                return (false, nil)
            }
        } else {
            // Handle SQL preparation error
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Failure @ SQL: \(errmsg) Query : \(query)")
            sqlite3_finalize(statement)
            return (false, nil)
        }
    }

}

public class DevOpsConnectionEstablisher {
    private var db: OpaquePointer? = nil
    private var path: String = ""// Make sure to use the actual path to your database file

    var dosqt = [SqlTracker]()
    init() {
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("DevOps.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("DevOps.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to open database : DevOps")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to set key for database : DevOps")
                sqlite3_close(db)
                return
            }
            
            let tableName = "t" + getDate().replacingOccurrences(of: "-", with: "")
            _ = executeQuery("""
                            CREATE TABLE IF NOT EXISTS \(tableName) (
                                fileName TEXT,
                                className TEXT,
                                function TEXT,
                                type TEXT,
                                line TEXT,
                                message TEXT,
                                toe TEXT
                            );
                            """)

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    public func restart(){
        sqlite3_close(db)
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("DevOps.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("DevOps.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to re-open database : DevOps")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to re-set key for database : DevOps")
                sqlite3_close(db)
                return
            }

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    public func executeQuery(_ query: String) -> (Bool, [[String: String]]?) {
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            var result = sqlite3_step(statement)
            if result == SQLITE_ROW {
                // Handle SELECT queries
                var rows = [[String: String]]()
                repeat {
                    var row = [String: String]()
                    for i in 0..<sqlite3_column_count(statement) {
                        if let columnName = sqlite3_column_name(statement, i) {
                            let name = String(cString: columnName)
                            if let columnText = sqlite3_column_text(statement, i) {
                                let value = String(cString: columnText)
                                row[name] = value
                            }
                        }
                    }
                    rows.append(row)
                    result = sqlite3_step(statement)
                } while result == SQLITE_ROW
                sqlite3_finalize(statement)
                return (true, rows)
            } else if result == SQLITE_DONE {
                // Handle non-SELECT queries (INSERT, UPDATE, DELETE)
                sqlite3_finalize(statement)
                return (true, nil)
            } else {
                // If result is not SQLITE_ROW or SQLITE_DONE, it's an error
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("Failure @ SQL: \(errmsg) Query : \(query)")
                sqlite3_finalize(statement)
                return (false, nil)
            }
        } else {
            // Handle SQL preparation error
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Failure @ SQL: \(errmsg) Query : \(query)")
            sqlite3_finalize(statement)
            return (false, nil)
        }
    }
    
    public func select(_ qry: String, file: String = #file, line: Int = #line, ErrorHandling: Bool = true) -> [String:String]?{
        let query = "select " + qry
        
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line)
        let track = fileName + lineNumber
        
        for sqlTracer in dosqt{
            if sqlTracer.tracker == track{
                if sqlTracer.query == query{
                    if sqlTracer.tableData.indices.contains(sqlTracer.nextRow) {
                        let returnData =  sqlTracer.tableData[sqlTracer.nextRow]
                        sqlTracer.nextRow += 1
                        return returnData
                    } else {
                        return nil
                    }
                }
                else{
                    print("SQL Error thrown by Sqlize.select : tracker : \(track) reused for \(sqlTracer.query) and \(query)")
                    return nil
                }
            }
        }
        let eR = executeQuery(query)
        if eR.0 == true{
            if let temp = eR.1{
                dosqt.insert(SqlTracker(tracker: String(track), tableData: temp, query: query), at: 0)
                guard temp.isEmpty else{
                    dosqt[0].nextRow = 1
                    return temp[0]
                }
            }else{
                if ErrorHandling {
                    print("SQL Error thrown by Sqlize.select : No Data Returned by Database for Tracker : \(track) and Query : \(query)")
                }
                return nil
            }
        }
        else{
            print("SQL Error thrown by Sqlize.select : Execution Failed for Tracker : \(track) and Query : \(query)")
            return nil
        }
        
        print("SQL Error thrown by Sqlize.select : Unknown Problem for tracker : \(track) and query : \(query)")
        return nil
    }

}
public var DevOps = DevOpsConnectionEstablisher()

public class DeviceFingerprintConnectionEstablisher {
    private var db: OpaquePointer? = nil
    private var path: String = ""// Make sure to use the actual path to your database file

    var dfsqt = [SqlTracker]()
    init() {
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to open database : DeviceFingerprint")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to set key for database : DeviceFingerprint")
                sqlite3_close(db)
                return
            }
            
            let tableName = "t" + getDate().replacingOccurrences(of: "-", with: "")
            _ = executeQuery("""
                            CREATE TABLE if not exists all_system_projects_assigned_to_developers ('projectcode' TEXT NOT NULL DEFAULT '','company' TEXT NOT NULL DEFAULT '','hardnesslevel' TEXT NOT NULL DEFAULT '','category' TEXT NOT NULL DEFAULT '','pronam' TEXT NOT NULL DEFAULT '','wing' TEXT NOT NULL DEFAULT '','prolink' TEXT NOT NULL DEFAULT '','prodes' TEXT NOT NULL DEFAULT '','dat' TEXT NOT NULL DEFAULT '','deadlinedat' TEXT NOT NULL DEFAULT '','completedat' TEXT NOT NULL DEFAULT '','delayed_days' TEXT NOT NULL DEFAULT '','creditpoints' TEXT NOT NULL DEFAULT '','marks' TEXT NOT NULL DEFAULT '','developer_unique_member_id' TEXT NOT NULL DEFAULT '','offinam' TEXT NOT NULL DEFAULT '','rating' TEXT NOT NULL DEFAULT '','tbl' TEXT NOT NULL DEFAULT '','newtbl' TEXT NOT NULL DEFAULT '','updation' TEXT NOT NULL DEFAULT '',    area TEXT NOT NULL DEFAULT '',
                                mcounti INTEGER NOT NULL DEFAULT 0,
                                fromdat DATE,
                                ftodat DATE DEFAULT '0000-00-00',
                                ftotim TIME,
                                ftovername TEXT NOT NULL DEFAULT '',
                                ftover TEXT NOT NULL DEFAULT '',
                                ftopid TEXT NOT NULL DEFAULT '',
                                todat DATE DEFAULT '0000-00-00',
                                totim TIME,
                                tovername TEXT NOT NULL DEFAULT '',
                                tover TEXT NOT NULL DEFAULT '',
                                topid TEXT NOT NULL DEFAULT '',
                                deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                                basesite TEXT NOT NULL DEFAULT 'NONE',
                                owncomcode TEXT NOT NULL DEFAULT 'NONE',
                                testeridentity TEXT NOT NULL DEFAULT '',
                                testcontrol TEXT NOT NULL DEFAULT '',
                                adderpid TEXT NOT NULL DEFAULT '',
                                addername TEXT NOT NULL DEFAULT '',
                                adder TEXT NOT NULL DEFAULT '',
                                syncstatus TEXT NOT NULL DEFAULT '',
                                ipmac TEXT NOT NULL DEFAULT '',
                                localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                                counti TEXT NOT NULL DEFAULT '',
                                doe DATE,
                                toe TIME);
                            """)
            
            
            _ = executeQuery("""
                            CREATE TABLE if not exists all_system_developer_details ('offinam' TEXT NOT NULL DEFAULT '','email' TEXT NOT NULL DEFAULT '','phone' TEXT NOT NULL DEFAULT '','queue' TEXT NOT NULL DEFAULT '','otp' TEXT NOT NULL DEFAULT '','overallstars' TEXT NOT NULL DEFAULT '','cp' TEXT NOT NULL DEFAULT '','rank' TEXT NOT NULL DEFAULT '','login' TEXT NOT NULL DEFAULT '','unique_member_id' TEXT NOT NULL DEFAULT '',    area TEXT NOT NULL DEFAULT '',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME,
                            'offphoto' TEXT NOT NULL DEFAULT '');
                            """)

            _ = executeQuery("""
                            CREATE TABLE if not exists all_system_leaderboard ('fname' TEXT NOT NULL DEFAULT '','fphoto' TEXT NOT NULL DEFAULT '','sname' TEXT NOT NULL DEFAULT '','sphoto' TEXT NOT NULL DEFAULT '','tname' TEXT NOT NULL DEFAULT '','tphoto' TEXT NOT NULL DEFAULT '',    area TEXT NOT NULL DEFAULT '',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)
            
            _ = executeQuery("""
                            CREATE TABLE if not exists last_communication_with_server ('otp' TEXT NOT NULL DEFAULT '','currentdoe' DATE NOT NULL DEFAULT '0000-00-00','currenttoe' TIME NOT NULL DEFAULT '00:00:00',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)
            
            _ = executeQuery("""
                            CREATE TABLE if not exists last_page_worked_on ('pagename' TEXT NOT NULL DEFAULT '','currentdoe' DATE NOT NULL DEFAULT '0000-00-00','currenttoe' TIME NOT NULL DEFAULT '00:00:00',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)
            _ = executeQuery("""
                            CREATE TABLE if not exists digital_pay_transaction ('amount' TEXT NOT NULL DEFAULT '','transactionid' TEXT NOT NULL DEFAULT '','uniquememberid' TEXT NOT NULL DEFAULT '','paidbyname' TEXT NOT NULL DEFAULT '','paidfor' TEXT NOT NULL DEFAULT '',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    public func restart(){
        sqlite3_close(db)
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to re-open database : DeviceFingerprint")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to re-set key for database : DeviceFingerprint")
                sqlite3_close(db)
                return
            }

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    public func executeQuery(_ query: String) -> (Bool, [[String: String]]?) {
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            var result = sqlite3_step(statement)
            if result == SQLITE_ROW {
                // Handle SELECT queries
                var rows = [[String: String]]()
                repeat {
                    var row = [String: String]()
                    for i in 0..<sqlite3_column_count(statement) {
                        if let columnName = sqlite3_column_name(statement, i) {
                            let name = String(cString: columnName)
                            if let columnText = sqlite3_column_text(statement, i) {
                                let value = String(cString: columnText)
                                row[name] = value
                            }
                        }
                    }
                    rows.append(row)
                    result = sqlite3_step(statement)
                } while result == SQLITE_ROW
                sqlite3_finalize(statement)
                return (true, rows)
            } else if result == SQLITE_DONE {
                // Handle non-SELECT queries (INSERT, UPDATE, DELETE)
                sqlite3_finalize(statement)
                return (true, nil)
            } else {
                // If result is not SQLITE_ROW or SQLITE_DONE, it's an error
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("Failure @ SQL: \(errmsg) Query : \(query)")
                sqlite3_finalize(statement)
                return (false, nil)
            }
        } else {
            // Handle SQL preparation error
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Failure @ SQL: \(errmsg) Query : \(query)")
            sqlite3_finalize(statement)
            return (false, nil)
        }
    }
    public func reset(line: Int = #line, file: String = #file) -> Bool{
        
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line + 1)
        let track = fileName + lineNumber

        var i: Int = 0
        for cv in dfsqt {
            if cv.tracker == track {
                dfsqt.remove(at: i)
                return true
            }
            else {
                i+=1
            }
        }
        return false
    }
    public func select(_ qry: String, file: String = #file, line: Int = #line, ErrorHandling: Bool = true) -> [String:String]?{
        let query = "select " + qry
        
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line)
        let track = fileName + lineNumber
        
        for sqlTracer in dfsqt{
            if sqlTracer.tracker == track{
                if sqlTracer.query == query{
                    if sqlTracer.tableData.indices.contains(sqlTracer.nextRow) {
                        let returnData =  sqlTracer.tableData[sqlTracer.nextRow]
                        sqlTracer.nextRow += 1
                        return returnData
                    } else {
                        return nil
                    }
                }
                else{
                    print("SQL Error thrown by Sqlize.select : tracker : \(track) reused for \(sqlTracer.query) and \(query)")
                    return nil
                }
            }
        }
        let eR = executeQuery(query)
        if eR.0 == true{
            if let temp = eR.1{
                dfsqt.insert(SqlTracker(tracker: String(track), tableData: temp, query: query), at: 0)
                guard temp.isEmpty else{
                    dfsqt[0].nextRow = 1
                    return temp[0]
                }
            }else{
                if ErrorHandling {
                    print("SQL Error thrown by Sqlize.select : No Data Returned by Database for Tracker : \(track) and Query : \(query)")
                }
                return nil
            }
        }
        else{
            print("SQL Error thrown by Sqlize.select : Execution Failed for Tracker : \(track) and Query : \(query)")
            return nil
        }
        
        print("SQL Error thrown by Sqlize.select : Unknown Problem for tracker : \(track) and query : \(query)")
        return nil
    }
    

}

public var DF = DeviceFingerprintConnectionEstablisher()

public class AttentionRequireConnectionEstablisher {
    private var db: OpaquePointer? = nil
    private var path: String = ""// Make sure to use the actual path to your database file

    var dfsqt = [SqlTracker]()
    init() {
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to open database : DeviceFingerprint")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to set key for database : DeviceFingerprint")
                sqlite3_close(db)
                return
            }
            
            let tableName = "t" + getDate().replacingOccurrences(of: "-", with: "")
            _ = executeQuery("""
                            CREATE TABLE if not exists all_system_projects_assigned_to_developers ('projectcode' TEXT NOT NULL DEFAULT '','company' TEXT NOT NULL DEFAULT '','hardnesslevel' TEXT NOT NULL DEFAULT '','category' TEXT NOT NULL DEFAULT '','pronam' TEXT NOT NULL DEFAULT '','wing' TEXT NOT NULL DEFAULT '','prolink' TEXT NOT NULL DEFAULT '','prodes' TEXT NOT NULL DEFAULT '','dat' TEXT NOT NULL DEFAULT '','deadlinedat' TEXT NOT NULL DEFAULT '','completedat' TEXT NOT NULL DEFAULT '','delayed_days' TEXT NOT NULL DEFAULT '','creditpoints' TEXT NOT NULL DEFAULT '','marks' TEXT NOT NULL DEFAULT '','developer_unique_member_id' TEXT NOT NULL DEFAULT '','offinam' TEXT NOT NULL DEFAULT '','rating' TEXT NOT NULL DEFAULT '','tbl' TEXT NOT NULL DEFAULT '','newtbl' TEXT NOT NULL DEFAULT '','updation' TEXT NOT NULL DEFAULT '',    area TEXT NOT NULL DEFAULT '',
                                mcounti INTEGER NOT NULL DEFAULT 0,
                                fromdat DATE,
                                ftodat DATE DEFAULT '0000-00-00',
                                ftotim TIME,
                                ftovername TEXT NOT NULL DEFAULT '',
                                ftover TEXT NOT NULL DEFAULT '',
                                ftopid TEXT NOT NULL DEFAULT '',
                                todat DATE DEFAULT '0000-00-00',
                                totim TIME,
                                tovername TEXT NOT NULL DEFAULT '',
                                tover TEXT NOT NULL DEFAULT '',
                                topid TEXT NOT NULL DEFAULT '',
                                deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                                basesite TEXT NOT NULL DEFAULT 'NONE',
                                owncomcode TEXT NOT NULL DEFAULT 'NONE',
                                testeridentity TEXT NOT NULL DEFAULT '',
                                testcontrol TEXT NOT NULL DEFAULT '',
                                adderpid TEXT NOT NULL DEFAULT '',
                                addername TEXT NOT NULL DEFAULT '',
                                adder TEXT NOT NULL DEFAULT '',
                                syncstatus TEXT NOT NULL DEFAULT '',
                                ipmac TEXT NOT NULL DEFAULT '',
                                localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                                counti TEXT NOT NULL DEFAULT '',
                                doe DATE,
                                toe TIME);
                            """)
            
            
            _ = executeQuery("""
                            CREATE TABLE if not exists all_system_developer_details ('offinam' TEXT NOT NULL DEFAULT '','email' TEXT NOT NULL DEFAULT '','phone' TEXT NOT NULL DEFAULT '','queue' TEXT NOT NULL DEFAULT '','otp' TEXT NOT NULL DEFAULT '','overallstars' TEXT NOT NULL DEFAULT '','cp' TEXT NOT NULL DEFAULT '','rank' TEXT NOT NULL DEFAULT '','login' TEXT NOT NULL DEFAULT '','unique_member_id' TEXT NOT NULL DEFAULT '',    area TEXT NOT NULL DEFAULT '',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME,
                            'offphoto' TEXT NOT NULL DEFAULT '');
                            """)

            _ = executeQuery("""
                            CREATE TABLE if not exists all_system_leaderboard ('fname' TEXT NOT NULL DEFAULT '','fphoto' TEXT NOT NULL DEFAULT '','sname' TEXT NOT NULL DEFAULT '','sphoto' TEXT NOT NULL DEFAULT '','tname' TEXT NOT NULL DEFAULT '','tphoto' TEXT NOT NULL DEFAULT '',    area TEXT NOT NULL DEFAULT '',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)
            
            _ = executeQuery("""
                            CREATE TABLE if not exists last_communication_with_server ('otp' TEXT NOT NULL DEFAULT '','currentdoe' DATE NOT NULL DEFAULT '0000-00-00','currenttoe' TIME NOT NULL DEFAULT '00:00:00',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)
            
            _ = executeQuery("""
                            CREATE TABLE if not exists last_page_worked_on ('pagename' TEXT NOT NULL DEFAULT '','currentdoe' DATE NOT NULL DEFAULT '0000-00-00','currenttoe' TIME NOT NULL DEFAULT '00:00:00',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)
            _ = executeQuery("""
                            CREATE TABLE if not exists digital_pay_transaction ('amount' TEXT NOT NULL DEFAULT '','transactionid' TEXT NOT NULL DEFAULT '','uniquememberid' TEXT NOT NULL DEFAULT '','paidbyname' TEXT NOT NULL DEFAULT '','paidfor' TEXT NOT NULL DEFAULT '',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    public func restart(){
        sqlite3_close(db)
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to re-open database : DeviceFingerprint")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to re-set key for database : DeviceFingerprint")
                sqlite3_close(db)
                return
            }

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    public func executeQuery(_ query: String) -> (Bool, [[String: String]]?) {
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            var result = sqlite3_step(statement)
            if result == SQLITE_ROW {
                // Handle SELECT queries
                var rows = [[String: String]]()
                repeat {
                    var row = [String: String]()
                    for i in 0..<sqlite3_column_count(statement) {
                        if let columnName = sqlite3_column_name(statement, i) {
                            let name = String(cString: columnName)
                            if let columnText = sqlite3_column_text(statement, i) {
                                let value = String(cString: columnText)
                                row[name] = value
                            }
                        }
                    }
                    rows.append(row)
                    result = sqlite3_step(statement)
                } while result == SQLITE_ROW
                sqlite3_finalize(statement)
                return (true, rows)
            } else if result == SQLITE_DONE {
                // Handle non-SELECT queries (INSERT, UPDATE, DELETE)
                sqlite3_finalize(statement)
                return (true, nil)
            } else {
                // If result is not SQLITE_ROW or SQLITE_DONE, it's an error
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("Failure @ SQL: \(errmsg) Query : \(query)")
                sqlite3_finalize(statement)
                return (false, nil)
            }
        } else {
            // Handle SQL preparation error
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Failure @ SQL: \(errmsg) Query : \(query)")
            sqlite3_finalize(statement)
            return (false, nil)
        }
    }
    public func reset(line: Int = #line, file: String = #file) -> Bool{
        
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line + 1)
        let track = fileName + lineNumber

        var i: Int = 0
        for cv in dfsqt {
            if cv.tracker == track {
                dfsqt.remove(at: i)
                return true
            }
            else {
                i+=1
            }
        }
        return false
    }
    public func select(_ qry: String, file: String = #file, line: Int = #line, ErrorHandling: Bool = true) -> [String:String]?{
        let query = "select " + qry
        
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line)
        let track = fileName + lineNumber
        
        for sqlTracer in dfsqt{
            if sqlTracer.tracker == track{
                if sqlTracer.query == query{
                    if sqlTracer.tableData.indices.contains(sqlTracer.nextRow) {
                        let returnData =  sqlTracer.tableData[sqlTracer.nextRow]
                        sqlTracer.nextRow += 1
                        return returnData
                    } else {
                        return nil
                    }
                }
                else{
                    print("SQL Error thrown by Sqlize.select : tracker : \(track) reused for \(sqlTracer.query) and \(query)")
                    return nil
                }
            }
        }
        let eR = executeQuery(query)
        if eR.0 == true{
            if let temp = eR.1{
                dfsqt.insert(SqlTracker(tracker: String(track), tableData: temp, query: query), at: 0)
                guard temp.isEmpty else{
                    dfsqt[0].nextRow = 1
                    return temp[0]
                }
            }else{
                if ErrorHandling {
                    print("SQL Error thrown by Sqlize.select : No Data Returned by Database for Tracker : \(track) and Query : \(query)")
                }
                return nil
            }
        }
        else{
            print("SQL Error thrown by Sqlize.select : Execution Failed for Tracker : \(track) and Query : \(query)")
            return nil
        }
        
        print("SQL Error thrown by Sqlize.select : Unknown Problem for tracker : \(track) and query : \(query)")
        return nil
    }
    

}
public var AR = AttentionRequireConnectionEstablisher()

public class NeuralMemoryConnectionEstablisher {
    private var db: OpaquePointer? = nil
    private var path: String = ""// Make sure to use the actual path to your database file

    var dfsqt = [SqlTracker]()
    init() {
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to open database : DeviceFingerprint")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to set key for database : DeviceFingerprint")
                sqlite3_close(db)
                return
            }
            
            let tableName = "t" + getDate().replacingOccurrences(of: "-", with: "")
            _ = executeQuery("""
                            CREATE TABLE if not exists all_system_projects_assigned_to_developers ('projectcode' TEXT NOT NULL DEFAULT '','company' TEXT NOT NULL DEFAULT '','hardnesslevel' TEXT NOT NULL DEFAULT '','category' TEXT NOT NULL DEFAULT '','pronam' TEXT NOT NULL DEFAULT '','wing' TEXT NOT NULL DEFAULT '','prolink' TEXT NOT NULL DEFAULT '','prodes' TEXT NOT NULL DEFAULT '','dat' TEXT NOT NULL DEFAULT '','deadlinedat' TEXT NOT NULL DEFAULT '','completedat' TEXT NOT NULL DEFAULT '','delayed_days' TEXT NOT NULL DEFAULT '','creditpoints' TEXT NOT NULL DEFAULT '','marks' TEXT NOT NULL DEFAULT '','developer_unique_member_id' TEXT NOT NULL DEFAULT '','offinam' TEXT NOT NULL DEFAULT '','rating' TEXT NOT NULL DEFAULT '','tbl' TEXT NOT NULL DEFAULT '','newtbl' TEXT NOT NULL DEFAULT '','updation' TEXT NOT NULL DEFAULT '',    area TEXT NOT NULL DEFAULT '',
                                mcounti INTEGER NOT NULL DEFAULT 0,
                                fromdat DATE,
                                ftodat DATE DEFAULT '0000-00-00',
                                ftotim TIME,
                                ftovername TEXT NOT NULL DEFAULT '',
                                ftover TEXT NOT NULL DEFAULT '',
                                ftopid TEXT NOT NULL DEFAULT '',
                                todat DATE DEFAULT '0000-00-00',
                                totim TIME,
                                tovername TEXT NOT NULL DEFAULT '',
                                tover TEXT NOT NULL DEFAULT '',
                                topid TEXT NOT NULL DEFAULT '',
                                deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                                basesite TEXT NOT NULL DEFAULT 'NONE',
                                owncomcode TEXT NOT NULL DEFAULT 'NONE',
                                testeridentity TEXT NOT NULL DEFAULT '',
                                testcontrol TEXT NOT NULL DEFAULT '',
                                adderpid TEXT NOT NULL DEFAULT '',
                                addername TEXT NOT NULL DEFAULT '',
                                adder TEXT NOT NULL DEFAULT '',
                                syncstatus TEXT NOT NULL DEFAULT '',
                                ipmac TEXT NOT NULL DEFAULT '',
                                localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                                counti TEXT NOT NULL DEFAULT '',
                                doe DATE,
                                toe TIME);
                            """)
            
            
            _ = executeQuery("""
                            CREATE TABLE if not exists all_system_developer_details ('offinam' TEXT NOT NULL DEFAULT '','email' TEXT NOT NULL DEFAULT '','phone' TEXT NOT NULL DEFAULT '','queue' TEXT NOT NULL DEFAULT '','otp' TEXT NOT NULL DEFAULT '','overallstars' TEXT NOT NULL DEFAULT '','cp' TEXT NOT NULL DEFAULT '','rank' TEXT NOT NULL DEFAULT '','login' TEXT NOT NULL DEFAULT '','unique_member_id' TEXT NOT NULL DEFAULT '',    area TEXT NOT NULL DEFAULT '',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME,
                            'offphoto' TEXT NOT NULL DEFAULT '');
                            """)

            _ = executeQuery("""
                            CREATE TABLE if not exists all_system_leaderboard ('fname' TEXT NOT NULL DEFAULT '','fphoto' TEXT NOT NULL DEFAULT '','sname' TEXT NOT NULL DEFAULT '','sphoto' TEXT NOT NULL DEFAULT '','tname' TEXT NOT NULL DEFAULT '','tphoto' TEXT NOT NULL DEFAULT '',    area TEXT NOT NULL DEFAULT '',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)
            
            _ = executeQuery("""
                            CREATE TABLE if not exists last_communication_with_server ('otp' TEXT NOT NULL DEFAULT '','currentdoe' DATE NOT NULL DEFAULT '0000-00-00','currenttoe' TIME NOT NULL DEFAULT '00:00:00',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)
            
            _ = executeQuery("""
                            CREATE TABLE if not exists last_page_worked_on ('pagename' TEXT NOT NULL DEFAULT '','currentdoe' DATE NOT NULL DEFAULT '0000-00-00','currenttoe' TIME NOT NULL DEFAULT '00:00:00',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)
            _ = executeQuery("""
                            CREATE TABLE if not exists digital_pay_transaction ('amount' TEXT NOT NULL DEFAULT '','transactionid' TEXT NOT NULL DEFAULT '','uniquememberid' TEXT NOT NULL DEFAULT '','paidbyname' TEXT NOT NULL DEFAULT '','paidfor' TEXT NOT NULL DEFAULT '',
                            mcounti INTEGER NOT NULL DEFAULT 0,
                            fromdat DATE,
                            ftodat DATE DEFAULT '0000-00-00',
                            ftotim TIME,
                            ftovername TEXT NOT NULL DEFAULT '',
                            ftover TEXT NOT NULL DEFAULT '',
                            ftopid TEXT NOT NULL DEFAULT '',
                            todat DATE DEFAULT '0000-00-00',
                            totim TIME,
                            tovername TEXT NOT NULL DEFAULT '',
                            tover TEXT NOT NULL DEFAULT '',
                            topid TEXT NOT NULL DEFAULT '',
                            deviceanduserainfo TEXT NOT NULL DEFAULT 'NONE',
                            basesite TEXT NOT NULL DEFAULT 'NONE',
                            owncomcode TEXT NOT NULL DEFAULT 'NONE',
                            testeridentity TEXT NOT NULL DEFAULT '',
                            testcontrol TEXT NOT NULL DEFAULT '',
                            adderpid TEXT NOT NULL DEFAULT '',
                            addername TEXT NOT NULL DEFAULT '',
                            adder TEXT NOT NULL DEFAULT '',
                            syncstatus TEXT NOT NULL DEFAULT '',
                            ipmac TEXT NOT NULL DEFAULT '',
                            localcounti INTEGER PRIMARY KEY AUTOINCREMENT,
                            counti TEXT NOT NULL DEFAULT '',
                            doe DATE,
                            toe TIME);
                            """)

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    public func restart(){
        sqlite3_close(db)
        do {
            #if os(visionOS) || os(iOS)
            let fileManager = FileManager.default
            
            let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let appSupportDirectory = urls[0]

            // If the directory does not exist, this will create it
            if !fileManager.fileExists(atPath: appSupportDirectory.path) {
                try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        
            let fileURL = appSupportDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif
            
            #if os(macOS)
            let fileManager = FileManager.default
            // Change the search directory to `.documentDirectory` to get the path for the Documents directory
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]

            // Create the file URL for the database
            let fileURL = documentsDirectory.appendingPathComponent("DeviceFingerprint.sqlite3")
            path = fileURL.path
            #endif


            if sqlite3_open(path, &db) != SQLITE_OK {
                print("Unable to re-open database : DeviceFingerprint")
                return
            }

            let key = "123"
            if sqlcipher_key(db, key, Int32(key.count)) != SQLITE_OK {
                print("Unable to re-set key for database : DeviceFingerprint")
                sqlite3_close(db)
                return
            }

        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    public func executeQuery(_ query: String) -> (Bool, [[String: String]]?) {
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            var result = sqlite3_step(statement)
            if result == SQLITE_ROW {
                // Handle SELECT queries
                var rows = [[String: String]]()
                repeat {
                    var row = [String: String]()
                    for i in 0..<sqlite3_column_count(statement) {
                        if let columnName = sqlite3_column_name(statement, i) {
                            let name = String(cString: columnName)
                            if let columnText = sqlite3_column_text(statement, i) {
                                let value = String(cString: columnText)
                                row[name] = value
                            }
                        }
                    }
                    rows.append(row)
                    result = sqlite3_step(statement)
                } while result == SQLITE_ROW
                sqlite3_finalize(statement)
                return (true, rows)
            } else if result == SQLITE_DONE {
                // Handle non-SELECT queries (INSERT, UPDATE, DELETE)
                sqlite3_finalize(statement)
                return (true, nil)
            } else {
                // If result is not SQLITE_ROW or SQLITE_DONE, it's an error
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("Failure @ SQL: \(errmsg) Query : \(query)")
                sqlite3_finalize(statement)
                return (false, nil)
            }
        } else {
            // Handle SQL preparation error
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Failure @ SQL: \(errmsg) Query : \(query)")
            sqlite3_finalize(statement)
            return (false, nil)
        }
    }
    public func reset(line: Int = #line, file: String = #file) -> Bool{
        
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line + 1)
        let track = fileName + lineNumber

        var i: Int = 0
        for cv in dfsqt {
            if cv.tracker == track {
                dfsqt.remove(at: i)
                return true
            }
            else {
                i+=1
            }
        }
        return false
    }
    public func select(_ qry: String, file: String = #file, line: Int = #line, ErrorHandling: Bool = true) -> [String:String]?{
        let query = "select " + qry
        
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line)
        let track = fileName + lineNumber
        
        for sqlTracer in dfsqt{
            if sqlTracer.tracker == track{
                if sqlTracer.query == query{
                    if sqlTracer.tableData.indices.contains(sqlTracer.nextRow) {
                        let returnData =  sqlTracer.tableData[sqlTracer.nextRow]
                        sqlTracer.nextRow += 1
                        return returnData
                    } else {
                        return nil
                    }
                }
                else{
                    print("SQL Error thrown by Sqlize.select : tracker : \(track) reused for \(sqlTracer.query) and \(query)")
                    return nil
                }
            }
        }
        let eR = executeQuery(query)
        if eR.0 == true{
            if let temp = eR.1{
                dfsqt.insert(SqlTracker(tracker: String(track), tableData: temp, query: query), at: 0)
                guard temp.isEmpty else{
                    dfsqt[0].nextRow = 1
                    return temp[0]
                }
            }else{
                if ErrorHandling {
                    print("SQL Error thrown by Sqlize.select : No Data Returned by Database for Tracker : \(track) and Query : \(query)")
                }
                return nil
            }
        }
        else{
            print("SQL Error thrown by Sqlize.select : Execution Failed for Tracker : \(track) and Query : \(query)")
            return nil
        }
        
        print("SQL Error thrown by Sqlize.select : Unknown Problem for tracker : \(track) and query : \(query)")
        return nil
    }
    

}
public var NM = NeuralMemoryConnectionEstablisher()


public class AppleAlertsConnectionEstablisher {

    private var db: OpaquePointer? = nil
    private var path: String = ""

    public init() {

        do {

            #if os(visionOS) || os(iOS)

            let fileManager = FileManager.default

            let urls = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )

            let appSupportDirectory = urls[0]

            if !fileManager.fileExists(atPath: appSupportDirectory.path) {

                try fileManager.createDirectory(
                    at: appSupportDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }

            let fileURL = appSupportDirectory
                .appendingPathComponent("AppleAlerts.sqlite3")

            path = fileURL.path

            #endif

            #if os(macOS)

            let fileManager = FileManager.default

            let urls = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )

            let documentsDirectory = urls[0]

            let fileURL = documentsDirectory
                .appendingPathComponent("AppleAlerts.sqlite3")

            path = fileURL.path

            #endif

            // Open database
            if sqlite3_open(path, &db) != SQLITE_OK {

                print("Unable to open database : AppleAlerts")
                return
            }

            // SQLCipher key
            let key = "123"

            if sqlcipher_key(
                db,
                key,
                Int32(key.utf8.count)
            ) != SQLITE_OK {

                print("Unable to set key for database : AppleAlerts")

                sqlite3_close(db)
                db = nil

                return
            }

            // Create error_logs table
            _ = executeQuery("""
                CREATE TABLE IF NOT EXISTS error_logs (
                    fileName TEXT,
                    className TEXT,
                    function TEXT,
                    type TEXT,
                    line TEXT,
                    message TEXT,
                    doe TEXT,
                    toe TEXT
                );
                """)

        } catch {

            print("Unexpected error: \(error).")
        }
    }

    deinit {

        if let db = db {
            sqlite3_close(db)
        }
    }

    public func restart() {

        if let db = db {
            sqlite3_close(db)
        }

        self.db = nil

        do {

            #if os(visionOS) || os(iOS)

            let fileManager = FileManager.default

            let urls = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )

            let appSupportDirectory = urls[0]

            if !fileManager.fileExists(atPath: appSupportDirectory.path) {

                try fileManager.createDirectory(
                    at: appSupportDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }

            let fileURL = appSupportDirectory
                .appendingPathComponent("AppleAlerts.sqlite3")

            path = fileURL.path

            #endif

            #if os(macOS)

            let fileManager = FileManager.default

            let urls = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )

            let documentsDirectory = urls[0]

            let fileURL = documentsDirectory
                .appendingPathComponent("AppleAlerts.sqlite3")

            path = fileURL.path

            #endif

            if sqlite3_open(path, &db) != SQLITE_OK {

                print("Unable to re-open database : AppleAlerts")
                return
            }

            let key = "123"

            if sqlcipher_key(
                db,
                key,
                Int32(key.utf8.count)
            ) != SQLITE_OK {

                print("Unable to re-set key for database : AppleAlerts")

                sqlite3_close(db)
                db = nil

                return
            }

        } catch {

            print("Unexpected error: \(error).")
        }
    }

    public func executeQuery(
        _ query: String
    ) -> (Bool, [[String: String]]?) {

        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK {

            var result = sqlite3_step(statement)

            if result == SQLITE_ROW {

                var rows = [[String: String]]()

                repeat {

                    var row = [String: String]()

                    for i in 0..<sqlite3_column_count(statement) {

                        if let columnName = sqlite3_column_name(statement, i) {

                            let name = String(cString: columnName)

                            if let columnText = sqlite3_column_text(statement, i) {

                                let value = String(cString: columnText)

                                row[name] = value
                            }
                        }
                    }

                    rows.append(row)

                    result = sqlite3_step(statement)

                } while result == SQLITE_ROW

                sqlite3_finalize(statement)

                return (true, rows)

            } else if result == SQLITE_DONE {

                sqlite3_finalize(statement)

                return (true, nil)

            } else {

                let errmsg = String(
                    cString: sqlite3_errmsg(db)
                )

                print(
                    "Failure @ AppleAlerts SQL: \(errmsg) Query : \(query)"
                )

                sqlite3_finalize(statement)

                return (false, nil)
            }

        } else {

            let errmsg = String(
                cString: sqlite3_errmsg(db)
            )

            print(
                "Failure @ AppleAlerts SQL: \(errmsg) Query : \(query)"
            )

            sqlite3_finalize(statement)

            return (false, nil)
        }
    }
}

public var AppleAlerts = AppleAlertsConnectionEstablisher()
