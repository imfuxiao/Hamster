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
    .package(url: "https://github.com/JacobHearst/GCDWebServer.git", exact: "3.5.5"),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", exact: "0.9.16"),
  ],
  targets: [
    .target(
      name: "HamsterFileServer",
      dependencies: [
        .product(name: "GCDWebServers", package: "GCDWebServer"),
        .product(name: "ZIPFoundation", package: "ZIPFoundation"),
      ],
      path: "Sources",
      resources: [
        .copy("Resources/FileServer.bundle"),
      ]),
    .testTarget(
      name: "HamsterFileServerTests",
      dependencies: ["HamsterFileServer"]),
  ])
