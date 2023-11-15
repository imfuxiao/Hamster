// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HamsterKit",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "HamsterKit",
      targets: ["HamsterKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", exact: "0.9.16"),
    .package(url: "https://github.com/jpsim/Yams.git", exact: "5.0.6"),
  ],
  targets: [
    .target(
      name: "HamsterKit",
      dependencies: [
        "ZIPFoundation",
        "Yams",
      ],
      path: "Sources"),
    .testTarget(
      name: "HamsterKitTests",
      dependencies: ["HamsterKit"],
      path: "Tests"),
  ])
