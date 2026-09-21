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
            url: "https://github.com/abishekan143-glitch/DevEnvironment/releases/download/1.1.8/Dev.xcframework.zip",
            checksum: "9e4424c3c08ca07c0c2c3174671fd0609bdf22dbe0f8147f59ac90873ef40848"
        )
    ]
)
