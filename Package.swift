// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MediaBrowser",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "MediaBrowser", targets: ["MediaBrowser"])
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.0.0"),
        // Pin to the last UIKit release: 7.0.0+ is a SwiftUI rewrite whose SPM
        // target no longer ships the UIKit `UICircularProgressRing` view this
        // library uses. (CocoaPods keeps the UIKit class in a Legacy folder.)
        .package(url: "https://github.com/luispadron/UICircularProgressRing.git", .upToNextMinor(from: "6.5.0"))
    ],
    targets: [
        .target(
            name: "MediaBrowser",
            dependencies: [
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "UICircularProgressRing", package: "UICircularProgressRing")
            ],
            path: "MediaBrowser",
            exclude: [
                "MediaBrowser.h",
                "Info.plist"
            ],
            resources: [
                .process("MediaBrowser.xcassets")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "MediaBrowserTests",
            dependencies: ["MediaBrowser"],
            path: "Tests/MediaBrowserTests",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
