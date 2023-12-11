// swift-tools-version: 5.8
import PackageDescription

let package = Package(
  name: "Tools",
  dependencies: [
    .package(url: "https://github.com/SwiftGen/SwiftGen.git", from: "6.6.2")
  ],
  targets: [.target(name: "Tools", path: "")]
)
