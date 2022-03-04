// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "KMLKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [
        .library(
            name: "KMLKit",
            targets: ["KMLKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0"),
        .package(url: "https://github.com/chbeer/XMLDocument.git", .upToNextMajor(from: "1.1.0"))
        ],
    targets: [
        .target(
            name: "KMLKit",
            dependencies: [
                "ZIPFoundation",
                "XMLDocument"
            ],
            path: "KMLKit",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "KMLKitTests",
            dependencies: ["KMLKit"],
            path: "KMLKitTests",
            
            exclude: [
                "Info.plist",
                "libkml",
                "Sample Data",
                "schema"
            ]
        ),
    ]
)
