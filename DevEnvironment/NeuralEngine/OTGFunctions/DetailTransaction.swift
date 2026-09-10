////
////  DetailTransaction.swift
////  DevEnvironment
////
////  Created by ravichandran raju on 21/03/25.
////
//#if os(iOS)
//import Foundation
//import SwiftUI
//import Razorpay
//import UIKit
//let razorpayHelper = RazorpayHelper(apiKey: "rzp_test_cahwIHllEPMzHc")
//public class RazorpayHelper: NSObject, RazorpayPaymentCompletionProtocol {
//    var razorpay: RazorpayCheckout?
//    
//    init(apiKey: String) {
//        super.init()
//        self.razorpay = RazorpayCheckout.initWithKey(apiKey, andDelegate: self)
//    }
//    public func onlinePayment() {
//        let options: [String: Any] = [
//            "amount": 1000,  // Amount in paise (₹10 = 1000 paise)
//            "currency": "INR",
//            "description": "Test Payment",
//            "image": "https://your_logo_url.com/logo.png",
//            "name": "Your App Name",
//            "prefill": [
//                "email": "test@example.com",
//                "contact": "9876543210"
//            ],
//            "theme": ["color": "#3399cc"]
//        ]
//        DispatchQueue.main.async {
//            if let topController = UIApplication.shared.windows.first?.rootViewController {
//                self.razorpay?.open(options, displayController: topController)
//            }
//        }
//    }
//    public func onPaymentSuccess(_ payment_id: String) {
//        print("✅ Payment Success: \(payment_id)")
//    }
//    public func onPaymentError(_ code: Int32, description: String) {
//        print("❌ Payment Failed: \(description)")
//    }
//}
//#endif
