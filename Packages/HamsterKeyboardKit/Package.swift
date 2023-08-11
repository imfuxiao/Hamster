// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HamsterKeyboardKit",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "HamsterKeyboardKit",
      targets: ["HamsterKeyboardKit"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "HamsterKeyboardKit",
      dependencies: [
      ],
      path: "Sources",
      resources: [.process("Resources")]),
    .testTarget(
      name: "HamsterKeyboardKitTests",
      dependencies: ["HamsterKeyboardKit"],
      path: "Tests"),
  ])
