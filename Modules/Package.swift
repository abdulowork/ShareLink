// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "Modules",
    products: [
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
        .target(
            name: "ShareLinkActions"
        ),
        .target(
            name: "SearchForMount"
        )
    ]
)
