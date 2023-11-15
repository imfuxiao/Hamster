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
    .library(name: "HamsterKeyboardKit", targets: ["HamsterKeyboardKit"]),
  ],
  dependencies: [
    .package(path: "../HamsterKit"),
    .package(path: "../HamsterUIKit"),
    .package(path: "../RimeKit"),
    .package(url: "https://github.com/michaeleisel/ZippyJSON.git", exact: "1.2.10"),
  ],
  targets: [
    .target(
      name: "HamsterKeyboardKit",
      dependencies: [
        "HamsterKit",
        "HamsterUIKit",
        "ZippyJSON",
        "RimeKit",
      ],
      path: "Sources",
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "HamsterKeyboardKitTests",
      dependencies: ["HamsterKeyboardKit"],
      path: "Tests"
    ),
  ]
)
