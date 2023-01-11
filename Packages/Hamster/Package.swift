// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Hamster",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "Hamster",
      targets: ["Hamster"]),
  ],
  dependencies: [
    .package(url: "https://github.com/KeyboardKit/KeyboardKit.git", from: "6.8.1"),
    .package(url: "https://github.com/imfuxiao/Plist.git", from: "0.3.0"),
    .package(path: "../LibrimeKit")
  ],
  targets: [
    .target(
      name: "Hamster",
      dependencies: [
        "KeyboardKit",
        "Plist",
        "LibrimeKit"
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "HamsterTests",
      dependencies: ["Hamster"]),
  ])
