// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaBrowser",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "MediaBrowser",
            targets: ["MediaBrowser"])
    ],
    dependencies: [
        .package(name: "SDWebImage", url: "https://github.com/SDWebImage/SDWebImage.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "MediaBrowser",
            dependencies: [],
            path: "MediaBrowser"
        )
    ]
)
