//
//  Myprofile.swift
//  NeuralEngine
//
//  Created by Sabinash on 04/03/25.
//

#if os(iOS)

import Foundation
import SwiftUI

public struct MyProfile<P1: View, P2: View, P3: View, P4: View, P5: View, P6: View, P7: View, P8: View, P9: View, P10: View, WorkAround: View>: View {
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
    @State private var userName = ""
    @State private var rank = ""
    @State private var cp = ""
    @State private var delay_Date = ""
    @State private var place: [String] = ["🥇","🥈", "🥉"]
    @State private var selectedIndex = 0
    @Namespace private var animation
    @State private var working_Bool = true
    @State private var double_tap = false
    @State private var workaround_tap = false
    @State private var savedImagePath: String?
    @State private var image_url: [String?] = ["", "", ""]
    @State private var person_image: [String] = []
    @State private var person_Name: [String] = []
    @State private var Completed_Project: [String] = []
    @State private var start_rating: [String] = []
    @State private var project: [String] = []
    @State private var start_Line: [String] = []
    @State private var dead_Line: [String] = []
    @State private var level_type: [String] = []
    @State private var all_Project: [String] = []
    @State private var overallStar: Int?
    public func progre(_ dead_Line: String, _ start_Line: String)-> Double{
        return Double(calculateDaysRemaining(from: dead_Line)) / Double(calculateDaysRemaining(from: dead_Line, startDate: start_Line)) > 0 ? Double(calculateDaysRemaining(from: dead_Line)) / Double(calculateDaysRemaining(from: dead_Line, startDate: start_Line)) : 110
    }
    var progress: Double {
        (Completed_Project.count + project.count) > 0 ? Double(Completed_Project.count) / Double(Completed_Project.count + project.count) : 0
    }
    var percentageText: String {
        "\(Int(progress * 100))%"
    }
    public func fromet(_ sRat: String)-> Int{
        let formatter = NumberFormatter()
        guard let startRat = formatter.number(from: sRat) else { return 0 }
        return Int(startRat)
    }
    public func calculateDaysRemaining(from dateString: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current

        guard let targetDate = formatter.date(from: dateString) else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        let diff = calendar.dateComponents([.day], from: today, to: target).day ?? 0
        return diff == 0 ? 1 : diff > 0 ? diff+1 : diff
    }

    public func calculateDaysRemaining(from dateString: String, startDate: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let targetDate = formatter.date(from: dateString) else { return 0 }
        guard let startedDate = formatter.date(from: startDate) else { return 0 }
        
        let calendar = Calendar.current
        let remainingDays = calendar.dateComponents([.day], from: startedDate, to: targetDate).day ?? 0
        return remainingDays // Ensure non-negative value
    }
    public func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
    public func downloadImage(_ filename: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        // Check if the file already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            DispatchQueue.main.async {
                savedImagePath = fileURL.path
            }
            return
        }
    }
    public func downloadImage(_ filename: String, _ a: Int) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        // Check if the file already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            DispatchQueue.main.async {
                image_url[a] = fileURL.path
            }
            return
        }
    }
    public func downloadAndSaveImage(_ imageurl: String) {
        let filename = getCurrentTimestamp() + ".jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        // Check if the file already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            DispatchQueue.main.async {
                savedImagePath = fileURL.path
            }
            return
        }
        guard let imageU = URL(string: imageurl) else { return }

        URLSession.shared.dataTask(with: imageU) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                try FileManager.default.createDirectory(at: getDocumentsDirectory(), withIntermediateDirectories: true)
                try data.write(to: fileURL)

                DispatchQueue.main.async {
                    savedImagePath = fileURL.path
                    _ = DF.executeQuery("UPDATE all_system_developer_details SET offphoto = '\(filename)'")
                }
            } catch {
                print("Error saving image:", error)
            }
        }.resume()
    }
    public func downloadAndSaveImage(_ imageurl: String, _ a: Int) {
        let filename = getCurrentTimestamp() + generateRandomString(length: 7) + ".jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        // Check if the file already exists
        guard let imageU = URL(string: imageurl) else { return }

        URLSession.shared.dataTask(with: imageU) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                try FileManager.default.createDirectory(at: getDocumentsDirectory(), withIntermediateDirectories: true)
                try data.write(to: fileURL)

                DispatchQueue.main.async {
                    image_url[a] = fileURL.path
                    if a == 0{
                        _ = DF.executeQuery("UPDATE all_system_leaderboard SET fphoto = '\(filename)'")
                    } else if a == 1{
                        _ = DF.executeQuery("UPDATE all_system_leaderboard SET sphoto = '\(filename)'")
                    } else {
                        _ = DF.executeQuery("UPDATE all_system_leaderboard SET tphoto = '\(filename)'")
                    }
                }
            } catch {
                print("Error saving image:", error)
            }
        }.resume()
    }
    public func getCurrentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter.string(from: Date())
    }

    public func generateRandomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    public func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MMM-yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    let tabs = ["Working", "Completed"]
    @ViewBuilder
    public func destinationView(_ inputText: String) -> some View {
        let index = project.firstIndex(of: inputText)
        switch index {
        case 0:
            p1
        case 1:
            p2
        case 2:
            p3
        case 3:
            p4
        case 4:
            p5
        case 5:
            p6
        case 6:
            p7
        case 7:
            p8
        case 8:
            p9
        case 9:
            p10
        default:
            workaround
        }
    }
    public var body: some View {
        NavigationStack {
            ZStack{
                Background()
                    .ignoresSafeArea()
                VStack {
                    if !response_Query.isEmpty {
                        Text("")
                            .onAppear {
                                downloadAndSaveImage(response_Query.last!)
                            }
                    }
                    HStack(spacing: 30) {
                        ForEach(0..<person_Name.count, id: \.self) { index in
                            VStack {
                                Circle()
                                    .stroke(Color.gray, lineWidth: 3)
                                    .frame(width: 80, height: 80)
                                    .overlay {
                                        if let path = image_url[index], let uiImage = UIImage(contentsOfFile: path) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .frame(width: 70, height: 70)
                                                .clipShape(Circle())
                                        } else {
                                            Image("ironman")
                                                .resizable()
                                                .frame(width: 70, height: 70)
                                                .clipShape(Circle())
                                        }
                                    }
                                Text(person_Name[index].prefix(8) + (person_Name[index].count > 8 ? "..." : ""))
                                    .foregroundColor(Color.silverGray)
                                    .font(.headline)
                                    .textCase(.uppercase)
                                Text(place[index])
                                    .font(.system(size: 40))
                            }
                        }
                    }
                    HStack {
                        VStack {
                            Text("YOUR")
                                .foregroundColor(Color.goldenrodBrown)
                                .font(.custom("Baskervville", size: 15))
                            Text(rank)
                                .foregroundColor(Color.silverGray)
                                .font(.custom("BaskervvilleRegular", size: 35))
                                .fontWeight(.bold)
                            Text("RANK")
                                .foregroundColor(Color.goldenrodBrown)
                                .font(.custom("Baskervville", size: 15))
                        }
                        Circle()
                            .stroke(Color.gray, lineWidth: 3)
                            .frame(width: 80, height: 80)
                            .overlay {
                                if let path = savedImagePath, let uiImage = UIImage(contentsOfFile: path) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                } else {
                                    Image("ironman")
                                        .resizable()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                }
                            }
                            .onTapGesture(count: 2) {
                                workaround_tap = true
                            }
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                            Circle()
                                .trim(from: 0.0, to: progress)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .rotationEffect(.degrees(-90)) // Start from top
                            Text("\(Completed_Project.count) / \(Completed_Project.count + project.count)")
                                .foregroundColor(Color.silverGray)
                                .font(.system(size: 15))
                                .fontWeight(.bold)
                        }
                        .frame(width: 70, height: 70)
                        .padding()
                        VStack {
                            Text("CREDIT")
                                .foregroundColor(Color.goldenrodBrown)
                                .font(.custom("Baskervville", size: 15))
                            Text(cp)
                                .foregroundColor(Color.silverGray)
                                .fontWeight(.bold)
                            Text("POINTS")
                                .foregroundColor(Color.goldenrodBrown)
                                .font(.custom("Baskervville", size: 15))
                        }
                    }
                    Text(userName)
                        .foregroundColor(Color.goldenrodBrown)
                        .textCase(.uppercase)
                        .font(.headline)
                    FixedStars(rating: overallStar ?? 0)
                        .frame(width: 200, height: 40)
                        .onTapGesture(count: 2) {
                            _ = reVerifyOTP()
                            double_tap = true
                        }
                    Text(delay_Date)
                        .foregroundColor(Color.silverGray)
                        .fontWeight(.bold)
                    HStack(spacing: 50) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    selectedIndex = index
                                    if index == 1 {
                                        working_Bool = false
                                    } else {
                                        working_Bool = true
                                    }
                                }
                            }) {
                                VStack {
                                    if index == 1 {
                                        HStack {
                                            Image(systemName: "checkmark.seal.fill") // For complete
                                            Text("Complete")
                                                .foregroundColor(selectedIndex == index ? Color.goldenrodBrown : Color.silverGray)
                                                .fontWeight(.semibold)
                                        }
                                    } else {
                                        HStack {
                                            Image(systemName: "hammer.fill") // For working
                                            Text("Working")
                                                .foregroundColor(selectedIndex == index ? Color.goldenrodBrown : Color.silverGray)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    ScrollView {
                        if working_Bool {
                            ForEach(0..<project.count, id: \.self) { index in
                                NavigationLink(destination: destinationView(project[index])) {
                                    VStack {
                                        HStack {
                                            Text("☠️")
                                                .font(.system(size: 50))
                                                .padding(.leading, 10)
                                            VStack {
                                                Text("\(index+1). " + project[index].prefix(7) + (project[index].count > 7 ? "..." : ""))
                                                    .foregroundColor(level_type[index] == "hardest" ? .brown : level_type[index] == "hard" ? .red : level_type[index] == "medium" ? .orange : level_type[index] == "easy" ? .green : .green.opacity(0.5))
                                                    .font(.system(size: 20))
                                                    .textCase(.uppercase)
                                                Text(formatDate(dead_Line[index]))
                                                    .font(.system(size: 20))
                                                    .foregroundColor(Color.silverGray)
                                            }
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                                Circle()
                                                    .trim(from: 0.0, to: progre(dead_Line[index], start_Line[index]))
                                                    .stroke(progre(dead_Line[index], start_Line[index])*100 >= 75 && progre(dead_Line[index], start_Line[index])*100 <= 100 ? Color.blue :progre(dead_Line[index], start_Line[index])*100 >= 50 && progre(dead_Line[index], start_Line[index])*100 <= 100 ? Color.yellow :progre(dead_Line[index], start_Line[index])*100 >= 25 && progre(dead_Line[index], start_Line[index])*100 <= 100 ? Color.orange : Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                                    .rotationEffect(.degrees(-90)) // Start from top
                                                Text("\(calculateDaysRemaining(from: dead_Line[index]))")
                                                    .foregroundColor(Color.silverGray)
                                                    .font(.system(size: 20))
                                                    .fontWeight(.bold)
                                            }
                                            .frame(width: 70, height: 70)
                                            .padding(.trailing, 20)
                                        }
                                    }
                                    .padding()
                                    .liquidGlass(cardWidth: 380)
                                }
                            }
                        } else {
                            ForEach(0..<Completed_Project.count, id: \.self) { index in
                                HStack {
                                    Text(Completed_Project[index].prefix(17) + (Completed_Project[index].count > 17 ? "..." : ""))
                                        .foregroundColor(Color.goldenrodBrown)
                                        .padding(.leading, 10)
                                        .padding(.top, 10)
                                        .textCase(.uppercase)
                                    Spacer()
                                    FixedStars(rating: fromet(start_rating[index]))
                                    .frame(width: 200, height: 30)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .gesture(DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 {
                            withAnimation(.easeInOut) {
                                selectedIndex = min(selectedIndex + 1, tabs.count - 1)
                                working_Bool = false
                            }
                        } else if value.translation.width > 50 {
                            withAnimation(.easeInOut) {
                                selectedIndex = max(selectedIndex - 1, 0)
                                working_Bool = true
                            }
                        }
                    }
                )
                .onAppear {
                    person_image.removeAll()
                    person_Name.removeAll()
                    Completed_Project.removeAll()
                    start_rating.removeAll()
                    project.removeAll()
                    start_Line.removeAll()
                    dead_Line.removeAll()
                    level_type.removeAll()
                    all_Project.removeAll()
                    _ = DF.reset()
                    if let offiname = DF.select("offinam FROM all_system_developer_details where todat = '0000-00-00'") {
                        let name = offiname["offinam"]!
                        userName = name
                    }
                    _ = DF.reset()
                    if let rankK = DF.select("rank FROM all_system_developer_details where todat = '0000-00-00'") {
                        let value = rankK["rank"]!
                        rank = value
                    }
                    _ = DF.reset()
                    if let CP = DF.select("cp FROM all_system_developer_details where todat = '0000-00-00'") {
                        let value = CP["cp"]!
                        cp = value
                    }
                    _ = DF.reset()
                    if let delayed_days = DF.select("delayed_days FROM all_system_developer_details where todat = '0000-00-00'") {
                        let value = delayed_days["delayed_days"]!
                        delay_Date = value
                    }
                    _ = DF.reset()
                    while let projName = DF.select("pronam FROM all_system_projects_assigned_to_developers where completedat != '0000-00-00'") {
                        let word = (projName["pronam"])!
                        Completed_Project.append(word)
                    }
                    _ = DF.reset()
                    while let projName = DF.select("pronam FROM all_system_projects_assigned_to_developers") {
                        let word = (projName["pronam"])!
                        all_Project.append(word)
                    }
                    _ = DF.reset()
                    while let rating = DF.select("rating FROM all_system_projects_assigned_to_developers where completedat != '0000-00-00'") {
                        let word = (rating["rating"])!
                        start_rating.append(word)
                    }
                    _ = DF.reset()
                    while let projName = DF.select("pronam FROM all_system_projects_assigned_to_developers where completedat = '0000-00-00' ORDER BY deadlinedat ASC") {
                        let word = (projName["pronam"])!
                        project.append(word)
                    }
                    _ = DF.reset()
                    while let projLevel = DF.select("hardnesslevel FROM all_system_projects_assigned_to_developers where completedat = '0000-00-00' ORDER BY deadlinedat ASC") {
                        let word = (projLevel["hardnesslevel"])!
                        level_type.append(word)
                    }
                    _ = DF.reset()
                    while let projStart = DF.select("dat FROM all_system_projects_assigned_to_developers where completedat = '0000-00-00' ORDER BY deadlinedat ASC") {
                        let word = (projStart["dat"])!
                        start_Line.append(word)
                    }
                    _ = DF.reset()
                    while let projDead = DF.select("deadlinedat FROM all_system_projects_assigned_to_developers where completedat = '0000-00-00' ORDER BY deadlinedat ASC") {
                        let word = (projDead["deadlinedat"])!
                        dead_Line.append(word)
                    }
                    _ = DF.reset()
                    if let firstName = DF.select("fname FROM all_system_leaderboard") {
                        let word = (firstName["fname"])!
                        person_Name.append(word)
                    }
                    _ = DF.reset()
                    if let secondtName = DF.select("sname FROM all_system_leaderboard") {
                        let word = (secondtName["sname"])!
                        person_Name.append(word)
                    }
                    _ = DF.reset()
                    if let thirdName = DF.select("tname FROM all_system_leaderboard") {
                        let word = (thirdName["tname"])!
                        person_Name.append(word)
                    }
                    _ = DF.reset()
                    if let firstPhoto = DF.select("fphoto FROM all_system_leaderboard") {
                        let word = (firstPhoto["fphoto"])!
                        person_image.append(word)
                    }
                    _ = DF.reset()
                    if let secondtPhoto = DF.select("sphoto FROM all_system_leaderboard") {
                        let word = (secondtPhoto["sphoto"])!
                        person_image.append(word)
                    }
                    _ = DF.reset()
                    if let thirdPhoto = DF.select("tphoto FROM all_system_leaderboard") {
                        let word = (thirdPhoto["tphoto"])!
                        person_image.append(word)
                    }
                    _ = DF.reset()
                    let overallstarRating = DF.select("overallstars FROM all_system_developer_details")
                    if let overall = overallstarRating?["overallstars"] as? String {
                        overallStar = Int(overall)
                    } else {
                        overallStar = 0
                    }
                    var a = 0
//                    if person_image[0].count > 1 {
//                        while a < person_image.count {
//                            downloadAndSaveImage(person_image[a], a)
//                            a += 1
//                        }
//                    } else {
//                        while a < person_image.count {
//                            downloadImage(person_image[a], a)
//                            a += 1
//                        }
//                    }
                    _ = DF.reset()
                    let offiPhoto = DF.select("offphoto FROM all_system_developer_details")
                    if let ofphoto = offiPhoto?["offphoto"] as? String {
                        downloadImage(ofphoto)
                    }
                }
                NavigationLink(destination: MyProfile(p1: p1, p2: p2, p3: p3, p4: p4, p5: p5, p6: p6, p7: p7, p8: p8, p9: p9, p10: p10, workaround: workaround), isActive: $double_tap) {
                    EmptyView()
                }
                NavigationLink(destination: workaround, isActive: $workaround_tap) {
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

public struct SomethingWorng: View {
    public var body: some View {
        Text("Something Wrong\nOr\nYou have more than 10 project.")
            .multilineTextAlignment(.center)
    }
}
#endif
