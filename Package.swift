// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGameUtils",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "SwiftGameUtils",
            targets: ["SwiftGameUtils"]),
    ],
    targets: [
        .target(
            name: "SwiftGameUtils"),
        .testTarget(
            name: "SwiftGameUtilsTests",
            dependencies: ["SwiftGameUtils"]),
    ]
)
