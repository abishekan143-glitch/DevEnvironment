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
