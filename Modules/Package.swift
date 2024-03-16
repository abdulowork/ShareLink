// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "MenuUI",
            targets: ["MenuUI"]
        ),
        .library(
            name: "ShareLinkActions",
            targets: ["ShareLinkActions"]
        ),
        .library(
            name: "SearchForMount",
            targets: ["SearchForMount"]
        ),
    ],
    targets: [
        .target(name: "MenuUI"),
        .target(name: "ShareLinkActions"),
        .target(name: "SearchForMount"),
    ]
)
