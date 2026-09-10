//
//  DevEnvironmentApp.swift
//  DevEnvironment
//
//  Created by Raghul S on 28/02/25.
//

import SwiftUI
import Network
@main
struct DevEnvironmentApp: App {
    var body: some Scene {
        WindowGroup {
            Workaround()
        }
    }
}
struct ContentView: View {
    var body: some View {
        DevEnvironment(p1: Project1(), p2: Project2(), p3: Project3(), p4: Project4(), p5: Project5(), p6: Project6(), p7: Project7(), p8: Project8(), p9: Project9(), p10: Project10(), workaround: Workaround())
    }
}
public var a: Int = 0
public struct DevEnvironment<P1: View, P2: View, P3: View, P4: View, P5: View, P6: View, P7: View, P8: View, P9: View, P10: View, WorkAround: View>: View {
    let p1: P1
    let p2: P2
    let p3: P3
    let p4: P4
    let p5: P5
    let p6: P6
    let p7: P7
    let p8: P8
    let p9: P9
    let p10: P10
    let workaround: WorkAround
    @State private var name: String = ""
    @State private var rno: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    public init(
        p1: P1, p2: P2, p3: P3, p4: P4, p5: P5,
        p6: P6, p7: P7, p8: P8, p9: P9, p10: P10,
        workaround: WorkAround
    ) {
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
        self.p4 = p4
        self.p5 = p5
        self.p6 = p6
        self.p7 = p7
        self.p8 = p8
        self.p9 = p9
        self.p10 = p10
        self.workaround = workaround
    }

    
    public var body: some View {
        ZStack{
            if OTPNeverVerified(){
                LoginWithOTP(p1: p1, p2: p2, p3: p3, p4: p4, p5: p5, p6: p6, p7: p7, p8: p8, p9: p9, p10: p10, workaround: workaround)
            } else if OTPNotVerifiedToday(){
                if reVerifyOTP() == "accessdenied" {
                    AccessDenied(){
                    }
                } else {
                    let lvp = LastVisitedPage()
                    
                    if lvp == nil {
#if os(iOS)

                        MyProfile(p1: p1, p2: p2, p3: p3, p4: p4, p5: p5, p6: p6, p7: p7, p8: p8, p9: p9, p10: p10, workaround: workaround)
#elseif os(macOS)
                        ContentViewWrapper()
#endif

                    } else {
                        if lvp == "1" {
                            p1
                        } else if lvp == "2" {
                            p2
                        } else if lvp == "3" {
                            p3
                        } else if lvp == "4" {
                            p4
                        } else if lvp == "5" {
                            p5
                        } else if lvp == "6" {
                            p6
                        } else if lvp == "7" {
                            p7
                        } else if lvp == "8" {
                            p8
                        } else if lvp == "9" {
                            p9
                        } else if lvp == "10" {
                            p10
                        }
                    }
                }
            } else {
                var lvp = LastVisitedPage()
                if lvp == nil {
#if os(iOS)
                    
                    MyProfile(p1: p1, p2: p2, p3: p3, p4: p4, p5: p5, p6: p6, p7: p7, p8: p8, p9: p9, p10: p10, workaround: workaround)
#elseif os(macOS)
                    ContentViewWrapper()
#endif
                } else {
                    if lvp == "1" {
                        p1
                    } else if lvp == "2" {
                        p2
                    } else if lvp == "3" {
                        p3
                    } else if lvp == "4" {
                        p4
                    } else if lvp == "5" {
                        p5
                    } else if lvp == "6" {
                        p6
                    } else if lvp == "7" {
                        p7
                    } else if lvp == "8" {
                        p8
                    } else if lvp == "9" {
                        p9
                    } else if lvp == "10" {
                        p10
                    }
                }
            }
        }
    }
}

public func OTPNeverVerified()->Bool{
    if let data = DF.select("otp from last_communication_with_server order by localcounti DESC") {
        if a == 0 {
            if validateOTP(data["otp"] ?? "").0{
                a += 1
                print("1" + "\(data)")
                return false
            } else {
                print(data)
                return true
            }
        } else {
            print(data)
            return false
        }
    } else {
        if a == 0 {
            return true
        } else {
            return false
        }
    }
}

public func OTPNotVerifiedToday()->Bool{
    if DF.executeQuery("select otp from last_communication_with_server where currentdoe='"+getDate()+"'").1 != nil {
        print(DF.executeQuery("select otp from last_communication_with_server where currentdoe='"+getDate()+"'"))
        return false
    } else {
        return true
    }
}

public func reVerifyOTP()->String{
    var projCode:[String] = []
    _ = DF.reset()
    if let data: [String:String] = DF.select("otp from last_communication_with_server order by localcounti") {
        let otp = validateOTP(data["otp"] ?? "").1
        guard let url = URL(string: "https://www.skynetbee.com/skynetbee/api/developer-environment/login-with-otp.php?otp=\(otp)") else {
            print("Invalid URL")
            return ""
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    print("Data received")
                    response_Query = separateSQLQueries(from: responseString)
                    print(response_Query)
                    if  response_Query.isEmpty || response_Query[0] == "noaccess" {
                        AccessDenied(){
                            print("hi")
                        }
                    } else {
                        _=DF.executeQuery("DELETE FROM all_system_leaderboard;")
                        _=DF.executeQuery("DELETE FROM all_system_projects_assigned_to_developers;")
                        _=DF.executeQuery("DELETE FROM all_system_developer_details;")
                        _=DF.executeQuery("DELETE FROM last_communication_with_server;")
                        var a = 0
                        while a < response_Query.count-1 {
                            _=DF.executeQuery(response_Query[a])
                            a += 1
                        }
                        _=DF.executeQuery("insert into last_communication_with_server (otp,currentdoe,currenttoe) values ('\(otp)','\(getDate())','\(getTime())');")
                        _ = DF.reset()
                        while let projcode = DF.select("projectcode FROM all_system_projects_assigned_to_developers where completedat = '0000-00-00'") {
                            let word = (projcode["projectcode"])!
                            projCode.append(word)
                        }
                        a = 0
                        while a < projCode.count {
                            fetchTables(projCode[a])
                            a += 1
                        }
                        print("___________________________")
                    }
                }
            }
        }.resume()
        return ""
    } else {
        cl("Unknown Error : OTP not derivable but OTPNeverVerified returned false")
        return "accessdenied"
    }
}

public func separateSQLQueries(from input: String) -> [String] {
    let markers = ["[n~p]", "[s~s]", "[s~~t]"]
    var queries: [String] = []
    var tempQuery = ""
    let components = input.components(separatedBy: CharacterSet(charactersIn: "[];"))
    for component in components {
        if markers.contains("[\(component)]") || component == ";" {
            if !tempQuery.isEmpty {
                queries.append(tempQuery.trimmingCharacters(in: .whitespacesAndNewlines))
                tempQuery = ""
            }
        } else {
            tempQuery += component
        }
    }
    if !tempQuery.isEmpty {
        queries.append(tempQuery.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    return queries
}

public func fetchTables(_ code:String) {
    var response_Query2:[String] = []
    guard let url = URL(string: "https://www.skynetbee.com/skynetbee/api/developer-environment/get-tables-with-project-code.php?projectcode=\(code)") else {
        print("Invalid URL")
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error:", error)
            return
        }

        guard let data = data else {
            print("No data received")
            return
        }

        // Print raw response
        if let rawString = String(data: data, encoding: .utf8) {
            response_Query2 = separateSQLQueries(from: rawString)
            print(response_Query2)
            var table:[String] = []
            var a = 0
            _ = sql.reset()
            let thereistable = sql.select("""
            GROUP_CONCAT('DROP TABLE ' || name, '; ') || ';' AS drop_statements
            FROM sqlite_master
            WHERE type = 'table';
            """)
            print("thereistable \(thereistable)")
            if thereistable != [:] && thereistable != nil {
                while let tableName = sql.select("""
                GROUP_CONCAT('DROP TABLE ' || name, '; ') || ';' AS drop_statements
                FROM sqlite_master
                WHERE type = 'table';
                """) {
                    print("_____")
                    print(tableName)
                    let word = (tableName["drop_statements"])!
                    table = word
                            .components(separatedBy: ";")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                }
                let filteredArray = table.filter { !$0.contains("sqlite_sequence") }
                print(filteredArray)
                while a < filteredArray.count {
                    _ = sql.executeQuery(filteredArray[a])
                    a += 1
                }
            }
            a = 0
            while a < response_Query2.count {
                _ = convertMySQLToSQLite(response_Query2[a])
                a += 1
            }
        } else {
            print("Unable to decode response as UTF-8 string")
        }
    }.resume()
}

public func convertMySQLToSQLite(_ query: String) {
    var sqliteQuery = query

    // Replace escaped \n with actual newlines
    sqliteQuery = sqliteQuery.replacingOccurrences(of: "\\n", with: "\n")

    // Remove backticks `
    sqliteQuery = sqliteQuery.replacingOccurrences(of: "`", with: "")

    // Remove CHARACTER SET and COLLATE
    let patternsToRemove = [
        #"CHARACTER SET\s+\w+"#,
        #"COLLATE\s+\w+"#
    ]
    for pattern in patternsToRemove {
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            sqliteQuery = regex.stringByReplacingMatches(in: sqliteQuery, range: NSRange(sqliteQuery.startIndex..., in: sqliteQuery), withTemplate: "")
        }
    }

    // Replace common MySQL types with SQLite-compatible types
    let replacements: [(String, String)] = [
        (" varchar(", " TEXT("),
        (" longtext", " TEXT"),
        (" int ", " INTEGER "),
        (" date ", " TEXT "),
        (" time ", " TEXT "),
        (" NOT NULL AUTO_INCREMENT", " PRIMARY KEY AUTOINCREMENT")
    ]
    for (mysqlType, sqliteType) in replacements {
        sqliteQuery = sqliteQuery.replacingOccurrences(of: mysqlType, with: sqliteType)
    }

    // Remove all but the first PRIMARY KEY
    var primaryKeyFound = false
    let lines = sqliteQuery.components(separatedBy: .newlines)
    var filteredLines: [String] = []

    for line in lines {
        if line.contains("PRIMARY KEY") {
            if primaryKeyFound {
                continue
            }
            primaryKeyFound = true
        }
        filteredLines.append(line)
    }

    // Join back the cleaned lines
    sqliteQuery = filteredLines.joined(separator: "\n")

    // Remove trailing comma before closing parenthesis
    sqliteQuery = sqliteQuery.replacingOccurrences(of: ",\n)", with: "\n)")
    let trimmedQuery = removeAfterLastParenthesis(from: sqliteQuery)
    _ = sql.executeQuery(trimmedQuery)
}

public func removeAfterLastParenthesis(from input: String) -> String {
    if let range = input.range(of: ")", options: .backwards) {
        return String(input[..<range.upperBound])
    }
    return input
}

public func LastVisitedPage()->String?{
    if let page = DF.select("pagename from last_page_worked_on order by localcounti desc") {
        if page["page"] as? String == ""{
            return nil
        } else {
            return page["page"]
        }
    } else {
        return nil
    }
}

public struct Background: View {
    public init(){}
    public var baseGradientColors: [Color] {
        [
            Color(red: 0/255, green: 20/255, blue: 100/255),Color(red: 105/255, green: 0/255, blue: 200/255)    // Dark Aubergine
        ]
    }
    public var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    public var isIphone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            let date = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                // Background base
                Color(red: 28/255, green: 16/255, blue: 62/255).ignoresSafeArea()
                // BUBBLE 1 - Purple
                if isIphone {
                    ForEach(0..<2, id: \.self) { index in
                        Circle()
                            .fill(baseGradientColors[index])
                            .frame(width: 400, height: 400)
                            .blur(radius: 150)
                            .offset(
                                x: CGFloat(sin(date / (5 + Double(index))) * 150),
                                y: CGFloat(cos(date / (6 + Double(index))) * 150)
                            )
                    }
                } else {
                    ForEach(0..<2, id: \.self) { index in
                        Circle()
                            .fill(baseGradientColors[index])
                            .frame(width: 900, height: 900)
                            .blur(radius: 150)
                            .offset(
                                x: CGFloat(sin(date / (5 + Double(index))) * 150),
                                y: CGFloat(cos(date / (6 + Double(index))) * 150)
                            )
                    }
                }
                // Black gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.8),
                        Color.black.opacity(0.5),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .center
                )
            }
            .compositingGroup()
            .ignoresSafeArea() 
        }
    }
}
