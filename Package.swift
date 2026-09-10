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
            targets: ["Dev"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "Dev",
            url: "https://github.com/abishekan143-glitch/DevEnvironment/releases/download/1.0.0/Dev.xcframework.zip",
            checksum: "724005912b395cf4c822d6d093b1d6ec9c9bbd7e5fd2673522ee2dfa08739647"
        )
    ]
)