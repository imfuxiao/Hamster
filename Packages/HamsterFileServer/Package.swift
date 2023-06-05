// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HamsterFileServer",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "HamsterFileServer",
      targets: ["HamsterFileServer"]),
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", exact: "4.81.0"),
    .package(url: "https://github.com/vapor/leaf.git", exact: "4.2.4"),
//    .package(url: "https://github.com/apple/swift-nio.git", exact: "2.57.0"),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", exact: "0.9.16"),
  ],
  targets: [
    .target(
      name: "HamsterFileServer",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Leaf", package: "leaf"),
        .product(name: "ZIPFoundation", package: "ZIPFoundation"),
      ],
      path: "Sources",
      resources: [
        .copy("Resources/static"),
      ]),
    .testTarget(
      name: "HamsterFileServerTests",
      dependencies: ["HamsterFileServer"]),
  ])
