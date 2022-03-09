import PackageDescription

let package = Package(
    name: "MediaBrowser"
)


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
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "MediaBrowser",
            dependencies: [],
            path: "MediaBrowser",
        )
    ]
)
