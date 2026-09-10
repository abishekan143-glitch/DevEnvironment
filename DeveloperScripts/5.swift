//
//  Your Project Name
//  For Which Organaisation This Page is Developed
//
//  Last Modified by Your Name on Date.
//

import SwiftUI

public struct Project5: View {
    public var body: some View {
        ZStack {
            Background()
            Text("Welcome to Project 5!")
        }
        .onAppear{
            var student = ELTestClass()
            el(
                student,
                "Testing EL with class object"
            )
        }
    }
}

class ELTestClass {

    var name = "Kaviya"
    var age = 20
    var mark = 92.5

    func testEL() {

        // Create object of this class
        let student = ELTestClass()

        // Pass that object to el()
        el(
            student,
            "Testing EL with class object"
        )
    }
}
