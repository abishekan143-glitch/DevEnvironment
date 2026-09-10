//
//  LoginWithOTP_iOS.swift
//  DevEnvironment
//
//  Created by Shalini on 04/03/25.
//

#if os(iOS)
import SwiftUI
public var response_Query: [String] = []
public struct LoginWithOTP<P1: View, P2: View, P3: View, P4: View, P5: View, P6: View, P7: View, P8: View, P9: View, P10: View, WorkAround: View>: View {
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
    
    @Environment(\.colorScheme) var colorScheme
    @State private var otpCode = ["", "", "", "", "", ""]
    @State private var currentIndex = 0
    @State private var isOTPIncorrect = false
    @State private var showAlert = false
    @State private var verify = false
    @FocusState private var focusedField: Int?
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Background()
                VStack {
                    Image("skynetbee", bundle: .devEnvironmentResources)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    Text("SkyneT Bee")
                        .font(.custom("DancingScript-bold", size: 35))
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow,
                                    Color.orange,
                                    Color.yellow
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                Text("SkyneT Bee")
                                    .font(.custom("DancingScript-bold", size: 35))
                            )
                        )
                        .shadow(color: Color.black.opacity(0.6), radius: 10, x: 4, y: 4)
                        .rotationEffect(.degrees(-2)) // Light rotation to make the text stand out
                    
                    if verify {
                        ProgressView("")
                        
                    }
                    // OTP input fields
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            OTPTextField(
                                text: $otpCode[index],
                                index: index,
                                otpCode: $otpCode,
                                focusedField: $focusedField
                            )
                            .disabled(verify)
                        }
                    }
                    .padding()
                    
                    // Check OTP Button
                    SmartBlackButton(label: "Verify") {
                        if otpCode.last! != "" {
                            verifyOTP()
                            verify = true
                            isOTPIncorrect = false
                        } else {
                            isOTPIncorrect = true
                            verify = false
                        }
                    }
                    .disabled(verify)
                    .padding(.top, 40)
                    
                    if isOTPIncorrect {
                        Text("Incorrect OTP")
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                            .onAppear(){
                                verify = false
                            }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        focusedField = 0
                    }
                }
                .padding()
                .liquidGlass(cardWidth: 380)
                .padding(.top, 250)
                .padding(.bottom, 200)
                NavigationLink(destination: DevEnvironment(p1: p1, p2: p2, p3: p3, p4: p4, p5: p5, p6: p6, p7: p7, p8: p8, p9: p9, p10: p10, workaround: workaround), isActive: $showAlert) {
                    EmptyView()
                }
            }
        }
    }
    
    public func verifyOTP() {
        print("Start verifying OTP")
        var projCode:[String] = []
        guard let url = URL(string: "https://www.skynetbee.com/skynetbee/api/developer-environment/login-with-otp.php?otp=\(otpCode.joined())") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                isOTPIncorrect = true
                verify = false
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
                    print("Response \(responseString)")
                    if response_Query.isEmpty || response_Query[0] == "noaccess" {
                        isOTPIncorrect = true
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
                        _=DF.executeQuery("insert into last_communication_with_server (otp,currentdoe,currenttoe) values ('\(otpCode.joined())','\(getDate())','\(getTime())');")
                        while let projcode = DF.select("projectcode FROM all_system_projects_assigned_to_developers where completedat = '0000-00-00'") {
                            let word = (projcode["projectcode"])!
                            projCode.append(word)
                        }
                        a = 0
                        while a < projCode.count {
                            fetchTables(projCode[a])
                            a += 1
                        }
                        showAlert = true
                        verify = false
                    }
                }
            }
        }.resume()
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
                let thereistable = sql.select("""
                GROUP_CONCAT('DROP TABLE ' || name, '; ') || ';' AS drop_statements
                FROM sqlite_master
                WHERE type = 'table';
                """)
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
        print(trimmedQuery)
    }
    public func removeAfterLastParenthesis(from input: String) -> String {
        if let range = input.range(of: ")", options: .backwards) {
            return String(input[..<range.upperBound])
        }
        return input
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
}

public struct OTPTextField: View {
    @Binding var text: String
    var index: Int
    @Binding var otpCode: [String]
    @FocusState.Binding var focusedField: Int?

    public var body: some View {
        TextField("", text: $text)
            .textContentType(.oneTimeCode)
            .keyboardType(.numberPad)
            .foregroundColor(Color.silverGray)
            .multilineTextAlignment(.center)
            .font(.title2.weight(.bold))
            .frame(width: 45, height: 45)
            .textFieldStyle(PlainTextFieldStyle())
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.goldYellow, lineWidth: 2)
            )
            .focused($focusedField, equals: index)
            .onChange(of: text) { newValue in
                handleInput(newValue)
            }
    }

    public func handleInput(_ newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        if filtered.isEmpty {
            text = ""
            if index > 0 {
                focusedField = index - 1
            }
        } else {
            text = String(filtered.prefix(1))
            if index < otpCode.count - 1 {
                focusedField = index + 1
            }
        }
    }
}

public class DevEnvironmentResourceLocator: NSObject {}

public extension Bundle {
    static var devEnvironmentResources: Bundle {
        return Bundle(for: DevEnvironmentResourceLocator.self)
    }
}


#endif
