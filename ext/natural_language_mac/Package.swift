// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "NaturalLanguageMac",
    platforms: [.macOS(.v27)],
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
