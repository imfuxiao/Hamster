// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HamsterKeyboard",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "HamsterKeyboard",
      targets: ["HamsterKeyboard"]),
  ],
  dependencies: [
    // .package(url: "https://github.com/KeyboardKit/KeyboardKit.git", exact: "7.8.0"),
  ],
  targets: [
    .target(
      name: "HamsterKeyboard",
      dependencies: [],
      path: "Sources",
      resources: [.process("Resources")]),
    .testTarget(
      name: "HamsterKeyboardTests",
      dependencies: ["HamsterKeyboard"],
      path: "Tests"),
  ])
