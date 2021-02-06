// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Shimmer",
    platforms: [
        .iOS(.v9),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "Shimmer",
            targets: ["Shimmer"]
        )
    ],
    targets: [
        .target(
            name: "Shimmer",
            path: "FBShimmering",
            exclude: [
                "FBShimmering-Prefix.pch"
            ],
            publicHeadersPath: "../FBShimmering"
        )
    ]
)
