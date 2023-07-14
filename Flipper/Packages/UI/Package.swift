// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "UI",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "UI",
            targets: ["UI"])
    ],
    dependencies: [
        .package(
            name: "Core",
            path: "../Core"),
        .package(
            name: "Analytics",
            path: "../Analytics"),
        .package(
            url: "https://github.com/airbnb/lottie-ios.git",
            from: "3.3.0"),
        .package(
            url: "https://github.com/gonzalezreal/swift-markdown-ui",
            from: "1.1.0"),
        .package(
            url: "https://github.com/SVGKit/SVGKit.git",
            from: "3.0.0")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: [
                "Core",
                "Analytics",
                .product(name: "SVGKit", package: "SVGKit"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ],
            path: "Sources"),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"],
            path: "Tests")
    ]
)
