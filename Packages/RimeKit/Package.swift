// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RimeKit",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(name: "RimeKit", targets: ["RimeKit"]),
  ],
  dependencies: [
    .package(path: "../HamsterKit"),
  ],
  targets: [
    .target(
      name: "RimeKitObjC",
      dependencies: [],
      path: "Sources/ObjC",
      linkerSettings: [
        .linkedLibrary("c++"),
      ]
    ),
    .target(
      name: "RimeKit",
      dependencies: ["RimeKitObjC", "HamsterKit"],
      path: "Sources/Swift"
    ),
    .testTarget(name: "RimeKitTests", dependencies: ["RimeKit"]),
  ]
)
