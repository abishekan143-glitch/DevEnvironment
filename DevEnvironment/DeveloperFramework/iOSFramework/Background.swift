
#if os(iOS)

import SwiftUI
import Foundation
import UIKit




public struct Background: View {

    public init() {}

    public var baseGradientColors: [Color] {
        [
            Color(
                red: 0 / 255,
                green: 20 / 255,
                blue: 100 / 255
            ),

            Color(
                red: 105 / 255,
                green: 0 / 255,
                blue: 200 / 255
            )
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

            let date =
                timeline.date.timeIntervalSinceReferenceDate

            ZStack {

                Color(
                    red: 28 / 255,
                    green: 16 / 255,
                    blue: 62 / 255
                )
                .ignoresSafeArea()

                if isIphone {

                    ForEach(0..<2, id: \.self) { index in

                        Circle()
                            .fill(baseGradientColors[index])
                            .frame(
                                width: 400,
                                height: 400
                            )
                            .blur(radius: 150)
                            .offset(
                                x: CGFloat(
                                    sin(
                                        date /
                                        (5 + Double(index))
                                    ) * 150
                                ),

                                y: CGFloat(
                                    cos(
                                        date /
                                        (6 + Double(index))
                                    ) * 150
                                )
                            )
                    }

                } else {

                    ForEach(0..<2, id: \.self) { index in

                        Circle()
                            .fill(baseGradientColors[index])
                            .frame(
                                width: 900,
                                height: 900
                            )
                            .blur(radius: 150)
                            .offset(
                                x: CGFloat(
                                    sin(
                                        date /
                                        (5 + Double(index))
                                    ) * 150
                                ),

                                y: CGFloat(
                                    cos(
                                        date /
                                        (6 + Double(index))
                                    ) * 150
                                )
                            )
                    }
                }

                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.5),
                            Color.clear
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .center
                )
            }
            .compositingGroup()
            .ignoresSafeArea()
        }
    }
}


public func reVerifyOTP() -> String {

    var projCode: [String] = []

    _ = DF.reset()

    if let data: [String: String] =
        DF.select("otp from last_communication_with_server order by localcounti") {

        let otp = validateOTP(data["otp"] ?? "").1

        guard let url = URL(
            string: "https://www.skynetbee.com/skynetbee/api/developer-environment/login-with-otp.php?otp=\(otp)"
        ) else {
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

            guard let responseString = String(
                data: data,
                encoding: .utf8
            ) else {
                return
            }

            DispatchQueue.main.async {

                print("Data received")

                response_Query = []

                print(response_Query)

                if response_Query.isEmpty ||
                    response_Query[0] == "noaccess" {

                    AccessDenied {
                        print("Access denied")
                    }

                } else {

                    _ = DF.executeQuery(
                        "DELETE FROM all_system_leaderboard;"
                    )

                    _ = DF.executeQuery(
                        "DELETE FROM all_system_projects_assigned_to_developers;"
                    )

                    _ = DF.executeQuery(
                        "DELETE FROM all_system_developer_details;"
                    )

                    _ = DF.executeQuery(
                        "DELETE FROM last_communication_with_server;"
                    )

                    var a = 0

                    while a < response_Query.count - 1 {

                        _ = DF.executeQuery(
                            response_Query[a]
                        )

                        a += 1
                    }

                    _ = DF.executeQuery(
                        """
                        insert into last_communication_with_server
                        (otp,currentdoe,currenttoe)
                        values
                        ('\(otp)','\(getDate())','\(getTime())');
                        """
                    )

                    _ = DF.reset()

                    while let projcode = DF.select(
                        "projectcode FROM all_system_projects_assigned_to_developers where completedat = '0000-00-00'"
                    ) {

                        if let word = projcode["projectcode"] {
                            projCode.append(word)
                        }
                    }

                    a = 0

                    while a < projCode.count {

//                        fetchTables(projCode[a])

                        a += 1
                    }

                    print("___________________________")
                }
            }

        }.resume()

        return ""

    } else {

        cl(
            "Unknown Error : OTP not derivable but OTPNeverVerified returned false"
        )

        return "accessdenied"
    }
}

#endif
