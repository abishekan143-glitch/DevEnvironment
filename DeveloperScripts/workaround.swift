import SwiftUI

public struct Workaround: View {

    public var body: some View {

        let student = Student(
            name: "Kaviya",
            age: 20,
            mark: 92.5
        )

        ZStack {
            Background()

            Text("Welcome to Project workaround!")
        }
        .onAppear {

            // =====================================================
            // EL TEST
            // =====================================================

            el(
                "EL Test",
                type: "EL String Test"
            )


            // =====================================================
            // CL TESTS
            // =====================================================

            cl()

            cl(45)

            cl(
                "sdfds",
                type: "String Test"
            )


            // =====================================================
            // PERSON OBJECT
            // =====================================================

            let lion = Person(
                name: "John",
                age: 25,
                scores: [10, 20, 30]
            )

            cl(
                lion,
                type: "Person Object Test"
            )


            // =====================================================
            // 2D ARRAY
            // =====================================================

            cl(
                [
                    [1, 2],
                    [1, 2, 3]
                ],
                type: "2D Integer Array Test"
            )

            cl(
                [
                    ["A", "B"],
                    ["C", "D"]
                ],
                type: "2D String Array Test"
            )


            // =====================================================
            // 3D ARRAY
            // =====================================================

            cl(
                [
                    [
                        [1, 2],
                        [3, 4]
                    ],
                    [
                        [5, 6],
                        [7, 8]
                    ]
                ],
                type: "3D Integer Array Test"
            )


            // =====================================================
            // MIXED ARRAY
            // =====================================================

            cl(
                [
                    10,
                    "hello",
                    20.5,
                    true,
                    [1, 2, 3]
                ] as [Any],
                type: "Mixed Array Test"
            )


            // =====================================================
            // ANIMAL OBJECT
            // =====================================================

            let tiger = Animal(
                legs: 4,
                sound: "roar",
                name: "puli"
            )

            cl(
                tiger,
                type: "Animal Object Test"
            )

            tiger.attack()


            // =====================================================
            // OBJECT + MESSAGE
            // =====================================================

            cl(
                lion,
                "sdfgrw",
                type: "Object Message Test"
            )


            // =====================================================
            // DATE
            // =====================================================

            cl(
                Date(),
                type: "Date Test"
            )


            // =====================================================
            // URL
            // =====================================================

            if let url = URL(string: "https://www.apple.com") {
                cl(
                    url,
                    type: "URL Test"
                )
            }


            // =====================================================
            // UUID
            // =====================================================

            cl(
                UUID(),
                type: "UUID Test"
            )


            // =====================================================
            // RANGE
            // =====================================================

            cl(
                1...10,
                type: "Closed Range Test"
            )

            cl(
                1..<10,
                type: "Half Open Range Test"
            )


            // =====================================================
            // OPTIONAL
            // =====================================================

            let intValue: Int? = 500

            cl(
                intValue,
                type: "Optional Int Test"
            )

            let doubleValue: Double? = 78.25

            cl(
                doubleValue,
                type: "Optional Double Test"
            )

            let boolValue: Bool? = true

            cl(
                boolValue,
                type: "Optional Bool Test"
            )

            cl(
                nil as String?,
                type: "Nil Optional Test"
            )


            // =====================================================
            // NESTED DICTIONARY
            // =====================================================

            cl(
                [
                    "student": [
                        "name": "Kaviya",
                        "age": "20"
                    ],
                    "course": [
                        "name": "Swift",
                        "duration": "6 Months"
                    ]
                ],
                type: "Nested Dictionary Test"
            )


            // =====================================================
            // ARRAY OF DICTIONARIES
            // =====================================================

            cl(
                [
                    [
                        "name": "Kaviya",
                        "age": "20"
                    ],
                    [
                        "name": "Arun",
                        "age": "22"
                    ],
                    [
                        "name": "Priya",
                        "age": "21"
                    ]
                ],
                type: "Array Dictionary Test"
            )


            // =====================================================
            // TUPLE
            // =====================================================

            cl(
                (
                    name: "Kaviya",
                    age: 20,
                    mark: 92.5
                ),
                type: "Named Tuple Test"
            )


            // =====================================================
            // TUPLE ARRAY
            // =====================================================

            cl(
                [
                    ("Kaviya", [90, 92, 95]),
                    ("Arun", [80, 85, 88])
                ],
                type: "Tuple Array Test"
            )


            // =====================================================
            // STRUCT
            // =====================================================

            let employee = Employee(
                name: "Kaviya",
                id: 101,
                salary: 45000
            )

            cl(
                employee,
                type: "Struct Test"
            )


            // =====================================================
            // ARRAY OF STRUCTS
            // =====================================================

            cl(
                [
                    Employee(
                        name: "Kaviya",
                        id: 101,
                        salary: 45000
                    ),
                    Employee(
                        name: "Arun",
                        id: 102,
                        salary: 42000
                    ),
                    Employee(
                        name: "Priya",
                        id: 103,
                        salary: 48000
                    )
                ],
                type: "Struct Array Test"
            )


            // =====================================================
            // SET
            // =====================================================

            cl(
                Set([10, 20, 30, 40]),
                type: "Integer Set Test"
            )


            // =====================================================
            // CHARACTER ARRAY
            // =====================================================

            cl(
                Array("KAVIYA"),
                type: "Character Array Test"
            )


            // =====================================================
            // [ANY]
            // =====================================================

            cl(
                [
                    "Kaviya",
                    20,
                    92.5,
                    true,
                    [1, 2, 3],
                    ["city": "Erode"],
                    ("Swift", 5)
                ] as [Any],
                type: "Deep Any Test"
            )


            // =====================================================
            // CLOSURE
            // =====================================================

            let testClosure: () -> String = {
                return "Closure Executed"
            }

            cl(
                testClosure,
                type: "Closure Test"
            )


            // =====================================================
            // FUNCTION REFERENCE
            // =====================================================

            cl(
                addNumbers,
                type: "Function Reference Test"
            )


            // =====================================================
            // SPECIAL STRINGS
            // =====================================================

            cl(
                "",
                type: "Empty String Test"
            )

            cl(
                "Hello\nWorld",
                type: "Multiline String Test"
            )

            cl(
                "Kaviya\tSwift",
                type: "Tab String Test"
            )


            cl(
                "தமிழ்",
                type: "Tamil Test"
            )

            cl(
                "こんにちは",
                type: "Japanese Test"
            )

            cl(
                "😀🚀🍎",
                type: "Emoji Test"
            )

            cl(
                student,
                type: "Student Object Test"
            )

            el(
                student,
                type: "Student EL Object Test"
            )
            
            
            cl(4+5)
            cl(7*6)
            
            
            let tableName = "t" + getDate()
                .replacingOccurrences(of: "-", with: "")

            let result = DevOps.executeQuery("""
                SELECT fileName,
                       className,
                       function,
                       type,
                       line,
                       message,
                       toe
                FROM \(tableName)
                ORDER BY rowid DESC
                LIMIT 5;
                """)

            print("CL Query success: \(result.0)")

            if let rows = result.1 {

                for row in rows {

                    print("\(row["fileName"] ?? "")\\\(row["className"] ?? "")\\\(row["function"] ?? "")")
                    print("\(row["type"] ?? "")\\\(row["line"] ?? "")\\\(row["message"] ?? "")")

                }

            } else {

                print("No CL logs found")
            }
        }
    }
}


class Person {

    var name: String
    var age: Int
    var scores: [Int]

    init(
        name: String,
        age: Int,
        scores: [Int]
    ) {
        self.name = name
        self.age = age
        self.scores = scores
    }
}

class Student {

    var name: String
    var age: Int
    var mark: Double

    init(
        name: String,
        age: Int,
        mark: Double
    ) {
        self.name = name
        self.age = age
        self.mark = mark
    }
}

class Animal {

    var legs: Int
    var sound: String
    var name: String

    init(
        legs: Int,
        sound: String,
        name: String
    ) {
        self.legs = legs
        self.sound = sound
        self.name = name
    }

    func attack() {

        cl(
            "Kadipen Da",
            type: "Animal Attack Test"
        )

        cl(
            "Kadipen Da",
            type: "Animal Attack Test"
        )
        
    }
}


struct Employee {

    var name: String
    var id: Int
    var salary: Double
}


func addNumbers(
    _ a: Int,
    _ b: Int
) -> Int {

    return a + b
}
