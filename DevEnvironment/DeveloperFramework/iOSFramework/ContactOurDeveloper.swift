//
//  File.swift
//  DevEnvironment
//
//  Created by Sabinash on 24/03/25.
//
#if os(iOS)
import Foundation
import SwiftUI
public struct ContactOurDeveloper: View {
    @State private var developerName: [String] = ["Shalini","Kajol J","Gayathri Mam","Sri Yazhini Sk","Kavipriya","Sabinash R"]
    @State private var developerWork: [String] = ["UI and UX Designer","Frontend Developer","Director","Full Stack Developer","Software Architect","Backend Developer"]
    @State private var developerImage: [String] = ["Shalini","kajol","mam","sri","kavipriya","Sabinash"]
    @State private var developerContact: [String] = ["6381004601","8124862611","7373733020","7010961391","7845481477","9894106889"]
    @State private var developerWhatsapp: [String] = ["6381004601","8124862611","7373733020","7010961391","7845481477","9894106889"]
    @State private var developerMail: [String] = ["skynetshalinisivakumar@gmail.com","skynet.kajol@gmail.com","Info@rdcollege.in","skynetyalu@gmail.com","skynetkavipriya016@gmail.com","skynetsabinashr@gmail.com"]
    @State private var developerInsta: [String] = ["shalinisiva03","_._._kajol__","rdnationalcollegeerode","yazh_._2307","skynetbee","sabinash._.ravichandran"]
    @Environment(\.colorScheme) var colorScheme
    public func openWhatsApp(_ phoneNumber: String) {
        let urlString = "https://wa.me/" + phoneNumber
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open WhatsApp")
        }
    }
    public func makeCall(_ phoneNumber: String) {
        let urlString = "tel://" + phoneNumber
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot make a call")
        }
    }
    public func sendEmail(_ emailAddress: String) {
        let urlString = "mailto:" + emailAddress
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot send email")
        }
    }
    public func openInstagram(_ instagramUsername:String) {
        let urlString = "https://www.instagram.com/" + instagramUsername
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open Instagram")
        }
    }
    public var body: some View {
        ZStack {
            if colorScheme == .dark {
            Image("darkmodeBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        } else {
            RadialGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white]),
                center: .top, startRadius: 50, endRadius: 500
            )
            .ignoresSafeArea()
        }
        VStack {
            ScrollView {
                ForEach(0..<developerName.count, id: \.self) { index in
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                            .backgroundCard()
                            .frame(height: 200)
                            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 5, y: 5)
                            .padding()
                        VStack {
                            HStack {
                                Image(developerImage[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .padding(.leading, 50)
                                Spacer()
                                VStack {
                                    Text("\(developerName[index])")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                    Text("\(developerWork[index])")
                                        .font(.system(size: 20))
                                    
                                }
                                Spacer()
                                Spacer()
                                Spacer()
                            }
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width-100, height: 1)
                            HStack(spacing: 20) {
                                Button(action: {
                                    makeCall(developerContact[index])
                                }) {
                                    Image("Phone")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 55, height: 55)
                                }
                                Button(action: {
                                    openWhatsApp(developerWhatsapp[index])
                                }) {
                                    Image("Whatsapp")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                }
                                Button(action: {
                                    sendEmail(developerMail[index])
                                }) {
                                    Image("mail")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                }
                                Button(action: {
                                    openInstagram(developerInsta[index])
                                }) {
                                    Image("Instagram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
        }
        }
    }
}
#endif
