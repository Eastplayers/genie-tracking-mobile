// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MobileTracker",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MobileTracker",
            targets: ["MobileTracker"]
        )
    ],
    dependencies: [
        // SwiftCheck for property-based testing
        .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0")
    ],
    targets: [
        .target(
            name: "MobileTracker",
            dependencies: [],
            path: "MobileTracker"
        ),
        .testTarget(
            name: "MobileTrackerTests",
            dependencies: ["MobileTracker"],
            path: "Tests/MobileTrackerTests"
        ),
        .testTarget(
            name: "MobileTrackerPropertyTests",
            dependencies: [
                "MobileTracker",
                "SwiftCheck"
            ],
            path: "Tests/MobileTrackerPropertyTests"
        )
    ]
)
