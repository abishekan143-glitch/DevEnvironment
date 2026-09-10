//
//  SQLizers.swift
//  DevEnvironment
//
//  Created by Raghul S on 28/02/25.
//

public class SqlTracker {
    var tracker: String
    var nextRow: Int = 0
    var query: String
    var tableData: [[String: String]]
    
    init(tracker: String, tableData: [[String: String]], query: String) {
        self.tableData = tableData
        self.tracker = tracker
        self.query = query
    }
}

public class SQLize: DatabaseConnectionEstablisher{
    
    var sqt = [SqlTracker]()
    
    public func read(_ columnNames: String, _ tableName: String, _ whereCondition: String = "", _ others: String = "", file: String = #file, line: Int = #line) -> [String:String]?{
        
        var qry = ""
        if whereCondition == "" {
            qry = columnNames + " from " + tableName + " where todat='0000-00-00' and area = '"+user.getArea()+"' "+others+";"
        } else {
            qry = columnNames + " from " + tableName + " where " + whereCondition + " and todat='0000-00-00' and area = '"+user.getArea()+"' "+others+";"
        }
        
        return select(qry,file:file,line:line)
    }
    
    public func readRowByRow(_ columnNames: String, _ tableName: String, _ whereCondition: String = "", _ others: String = "", file: String = #file, line: Int = #line) -> [String:String]?{
        
        var qry = ""
        if whereCondition == "" {
            qry = columnNames + " from " + tableName + " where todat='0000-00-00' and area = '"+user.getArea()+"' "+others+";"
        } else {
            qry = columnNames + " from " + tableName + " where " + whereCondition + " and todat='0000-00-00' and area = '"+user.getArea()+"' "+others+";"
        }
        
        return select(qry,file:file,line:line)
    }
    
    public func debug(line: Int, tag:String = "SQL Debug", file: String = #file) -> SqlTracker?{
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line)
        let track = fileName + lineNumber
        
        for cv in sqt {
            if cv.tracker == track {
                return cv
            }
        }
        print(tag+" in \(track) : Tracker Not Found")
        return nil
    }
    
    public func update(tableName: String, _ kvp: [String:String], localcounti: String) -> (counti:Int,success:Bool,selectQuery:String){

        let selquery = "select * from \(tableName) WHERE localcounti='\(localcounti)';"

        var eR = executeQuery(selquery)
        if eR.0 {
            if let temp = eR.1{
                
                var ourkvp: [String: String] = [:]
                
                let invalidKeys: Set<String> = [
                  "area","counti","doe","toe","mcounti","localcounti","syncstatus",
                  "syncrejectionreason","fromdat","ftodat","ftotim","ftovernam","ftover",
                  "ftopid","todat","totim","tovernam","tover","topid","deviceanduserinfo",
                  "basesite","owncomcode","ipmac","testeridentity","testcontrol","adderpid",
                  "addernam","adder"
                ]
                
                temp.first?.forEach { (key, value) in
                    if !invalidKeys.contains(key) {
                        ourkvp[key] = kvp[key] ?? value
                    }
                }
                
                let i = insert(tableName,ourkvp)
                _ = delete(tableName, "localcounti='\(localcounti)'")
                
                return (i.counti, true, selquery)
            } else {
                return(-1, false, selquery)
            }
        } else {
            return(-1, false, selquery)
        }
    }
    
    
    public func reset(line: Int = #line, file: String = #file) -> Bool{
        
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line + 1)
        let track = fileName + lineNumber

        var i: Int = 0
        for cv in sqt {
            if cv.tracker == track {
                sqt.remove(at: i)
                return true
            }
            else {
                i+=1
            }
        }
        return false
    }
    
    public func insert(_ tableName: String, _ kvp: [String:String], fileName: String = #file, line: Int = #line)-> (counti:Int,success:Bool,newlyinserted:Bool,query:String){
        
        let query = generateSelectQuery(tableName: tableName, data: kvp) + " and todat = '0000-00-00' and area='"+user.getArea()+"'"
        
        _ = reset(line: line-1, file: fileName)
        if let result = select(query,file: fileName, line: line, ErrorHandling: false) {
            var rci:Int = 0
            rci = Int(result["localcounti"] ?? "-1") ?? -1
            return(rci,true,false,query)
        } else {
            let freeInsertResult = freeInsert(tableName, kvp, fileName: fileName)
            return (freeInsertResult.counti, freeInsertResult.success, true, freeInsertResult.query)

        }
        
    }
    
    public func select(_ qry: String, file: String = #file, line: Int = #line, ErrorHandling: Bool = true) -> [String:String]?{
        let query = "select " + qry
        
        let fileName = file.split(separator: "/").last ?? "No File Name"
        let lineNumber = " @ " + String(line)
        let track = fileName + lineNumber
        
        for sqlTracer in sqt{
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
                sqt.insert(SqlTracker(tracker: String(track), tableData: temp, query: query), at: 0)
                guard temp.isEmpty else{
                    sqt[0].nextRow = 1
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
    
    public func freeInsert(_ tableName: String, _ kvp: [String:String], fileName: String = #file) -> (counti:Int,success:Bool,query:String){

        
        var columns: [String] = []
        var values: [String] = []

        // Splitting each key-value pair and appending them to respective arrays
        for (key,value) in kvp {
                columns.append(enqry(key))
                values.append(ivc(value)) // Adding quotes around values
        }
        
        columns.append("area")
        values.append(ivc("skytest"))
        
        
        columns.append("testcontrol")
        let randomstr = generateRandomAlphaNumeric(length: 7)
        values.append(ivc(randomstr))
        
        
        columns.append("ipmac")
        values.append(ivc("DevEnvironment"))
        
        columns.append("deviceanduserainfo")
        values.append(ivc("Developer Environment"))
        
        columns.append("basesite")
        values.append(ivc("DevEnv"))
    
        columns.append("owncomcode")
        values.append(ivc("developer"))
        
        columns.append("adderpid")
        values.append(ivc(getPid(filename: fileName)))
        
        columns.append("addername")
        values.append(ivc(user.getName()))
        
        columns.append("adder")
        values.append(ivc(user.getId()))
        
        columns.append("doe")
        values.append(ivc(getDate()))
        
        columns.append("toe")
        values.append(ivc(getTime()))
        
        // Joining columns and values to form a part of SQL query
        let columnsString = columns.joined(separator: ", ")
        let valuesString = values.joined(separator: ", ")

        // Constructing the full SQL insert query
        let insertQuery = "INSERT INTO \(tableName)(\(columnsString)) VALUES(\(valuesString))"
        
        if executeQuery(insertQuery).0 == true {
            let ctn = executeQuery("select localcounti from \(tableName) where testcontrol = '\(randomstr)'")

            if let countString = ctn.1?.first?["localcounti"], let count = Int(countString) {
                _ = executeQuery("update \(tableName) set testcontrol='' where localcounti = \(count) and testcontrol='\(randomstr)' ")
                return (count, true, insertQuery)
            } else {
                return (-1, false, insertQuery)
            }
        }
        else{
            return (-1, false, insertQuery)
        }
    }
    
    public func delete(_ tableName: String, _ whereCondition: String, fileName:String = #file) -> (count:Int,success:Bool,query:String){
        
        let selquery = "select count(*) from \(tableName) WHERE \(whereCondition) and area = '"+user.getArea()+"' and todat='0000-00-00';"
        
        let eQ = executeQuery(selquery).1?.first?["count(*)"]
        let affectedRows: Int = Int(eQ ?? "0") ?? 0
        
        let query = "UPDATE \(tableName) SET todat='\(getDate())', totime='\(getTime())', tover='"+user.getId()+"', tovernam='"+user.getName()+"', topid='"+getPid(filename: fileName)+"' WHERE \(whereCondition) and area = '"+user.getArea()+"' and todat='0000-00-00';"
        if executeQuery(query).0 == true{
            return (affectedRows, true, query)
        }
        else{
            return (0, false, query)
        }
    }
    
    public func end(_ tableName: String, _ whereCondition: String, fileName:String = #file) -> (count:Int,success:Bool,query:String){
        
        let selquery = "select count(*) from \(tableName) WHERE \(whereCondition) and area = '"+user.getArea()+"' and ftodat='0000-00-00';"
        
        let eQ = executeQuery(selquery).1?.first?["count(*)"]
        let affectedRows: Int = Int(eQ ?? "0") ?? 0
        
        let query = "UPDATE \(tableName) SET ftodat='\(getDate())', ftotime='\(getTime())', ftover='"+user.getId()+"', ftovernam='"+user.getName()+"', ftopid='"+getPid(filename: fileName)+"' WHERE \(whereCondition) and area = '"+user.getArea()+"' and ftodat='0000-00-00';"
        if executeQuery(query).0 == true{
            return (affectedRows, true, query)
        }
        else{
            return (0, false, query)
        }
    }
    
    public func ivc(_ param: String) -> String {
        return "'" + enqry(param) + "'"
    }
    
    public func getPid(filename: String)->String{
        return String(filename.split(separator: "/").last ?? "No File Name")
    }
    
    public func segregateAndPrintCounti(_ output: (Bool, Any?)) -> Int {
        // Ensure the output is valid
        guard let (_, queries) = output as? (Bool, [[String: String]]), !queries.isEmpty else {
            return -1
        }
        
        // Extract the first counti value
        if let countiStr = queries.first?["localcounti"], let counti = Int(countiStr) {
            return counti
        } else {
            return -1
        }
    }
    
    public func generateSelectQuery(tableName: String, data: [String: Any]) -> String {
        var conditions: [String] = []
        
        for (key, value) in data {
            // Append each condition
            conditions.append("\(key)='\(value)'")
        }
        
        // Join all conditions with AND and create the final query
        let query = "localcounti FROM \(tableName) WHERE " + conditions.joined(separator: " AND ")
        
        return query
    }

}

public var sql = SQLize()
