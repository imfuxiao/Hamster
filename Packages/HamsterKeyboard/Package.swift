// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HamsterKeyboard",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "HamsterKeyboard",
      targets: ["HamsterKeyboard"]),
  ],
  dependencies: [
    .package(url: "https://github.com/KeyboardKit/KeyboardKit.git", exact: "7.8.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "HamsterKeyboard",
      dependencies: [],
      path: "Sources"
    ),
    .testTarget(
      name: "HamsterKeyboardTests",
      dependencies: ["HamsterKeyboard"]),
  ])
