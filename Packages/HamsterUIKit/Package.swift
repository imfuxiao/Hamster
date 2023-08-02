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
    .package(path: "../HamsterKit"),
  ],
  targets: [
    .target(
      name: "HamsterUIKit",
      dependencies: ["HamsterKit"],
      path: "Sources"),
    .testTarget(
      name: "HamsterUIKitTests",
      dependencies: ["HamsterUIKit"],
      path: "Tests"),
  ])
