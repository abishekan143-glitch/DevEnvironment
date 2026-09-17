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
            url: "https://github.com/abishekan143-glitch/DevEnvironment/releases/download/1.0.3/SQLCipher.xcframework.zip",
            checksum: "adfb3c7d129da4bd45f925ff8bd27f59dbe343e717b9e0e62c86f78c197b10a6"
        ),
        .binaryTarget(
            name: "Dev",
            url: "https://github.com/abishekan143-glitch/DevEnvironment/releases/download/1.1.5/Dev.xcframework.zip",
            checksum: "572b2aa9ff2d6a537b4d02a54aa7e598ffa9407709df95cf3d6a70cfb717b924"
        )
    ]
)
