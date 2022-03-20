// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaBrowser",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MediaBrowser",
            targets: ["MediaBrowser"])
    ],
    dependencies: [
        .package(name: "SDWebImage", url: "https://github.com/SDWebImage/SDWebImage.git", .branch("master")),
        .package(name: "UICircularProgressRing", url: "https://github.com/luispadron/UICircularProgressRing.git", from: "6.3.0")
    ],
    targets: [
        .target(
            name: "MediaBrowser",
            dependencies: ["SDWebImage", "UICircularProgressRing"],
            path: "MediaBrowser",
            resources: [
                .process("MediaBrowser/Info.plist")
            ]
        )
    ]
)
