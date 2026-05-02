// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "NaturalLanguageMac",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "NaturalLanguageMac",
            type: .dynamic,
            targets: ["NaturalLanguageMac"]
        ),
    ],
    targets: [
        .target(
            name: "NaturalLanguageMac"
        ),
    ]
)
