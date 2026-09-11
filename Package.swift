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
            url: "https://github.com/abishekan143-glitch/DevEnvironment/releases/download/1.0.7/Dev.xcframework.zip",
            checksum: "adfb3c7d129da4bd45f925ff8bd27f59dbe343e717b9e0e62c86f78c197b10a6"
        ),
        .binaryTarget(
            name: "Dev",
            url: "https://github.com/abishekan143-glitch/DevEnvironment/releases/download/1.0.6/Dev.xcframework.zip",
            checksum: "747ad916b7a7c3ac0c7bc8d52fa701f894c37f517278d23f1a62d79d12ed6d7c"
        )
    ]
)
