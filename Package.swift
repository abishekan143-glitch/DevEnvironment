// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DevEnvironment",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DevEnvironment",
            targets: ["Dev", "SQLCipher"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "SQLCipher",
            url: "https://github.com/abishekan143-glitch/DevEnvironment/releases/download/1.0.2/SQLCipher.xcframework.zip",
            checksum: "f9df8485f623baf89a220d6f1a0d174b36c9ff8434defc897822b6283a83e9f5"
        ),
        .binaryTarget(
            name: "Dev",
            url: "https://github.com/abishekan143-glitch/DevEnvironment/releases/download/1.0.2/Dev.xcframework.zip",
            checksum: "4dac1314804f7d5a0637f99af85e1f749d4a1b78d73c366e19711739f800b097"
        )
    ]
)
