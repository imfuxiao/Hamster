// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HamsterKeyboardKit",
  defaultLocalization: "zh-Hans",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "HamsterKeyboardKit",
      targets: ["HamsterKeyboardKit"]),
  ],
  dependencies: [
    .package(path: "../HamsterKit"),
    .package(path: "../RimeKit"),
  ],
  targets: [
    .target(
      name: "HamsterKeyboardKit",
      dependencies: [
        "HamsterKit",
        "RimeKit",
      ],
      path: "Sources",
      resources: [.process("Resources")]),
    .testTarget(
      name: "HamsterKeyboardKitTests",
      dependencies: ["HamsterKeyboardKit"],
      path: "Tests"),
  ])
