// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HamsterUIKit",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "HamsterUIKit",
      targets: ["HamsterUIKit"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "HamsterUIKit",
      dependencies: [],
      path: "Sources"),
    .testTarget(
      name: "HamsterUIKitTests",
      dependencies: ["HamsterUIKit"],
      path: "Tests"),
  ])
