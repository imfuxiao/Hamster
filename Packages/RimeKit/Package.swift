// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RimeKit",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "RimeKit",
      targets: ["RimeKit"]),
  ],
  dependencies: [
  ],
  targets: [
    .binaryTarget(
      name: "librime",
      path: "Frameworks/librime.xcframework"),
    .binaryTarget(
      name: "boost_atomic",
      path: "Frameworks/boost_atomic.xcframework"),
    .binaryTarget(
      name: "boost_filesystem",
      path: "Frameworks/boost_filesystem.xcframework"),
    .binaryTarget(
      name: "boost_regex",
      path: "Frameworks/boost_regex.xcframework"),
    .binaryTarget(
      name: "boost_system",
      path: "Frameworks/boost_system.xcframework"),
    .binaryTarget(
      name: "libglog",
      path: "Frameworks/libglog.xcframework"),
    .binaryTarget(
      name: "libleveldb",
      path: "Frameworks/libleveldb.xcframework"),
    .binaryTarget(
      name: "libmarisa",
      path: "Frameworks/libmarisa.xcframework"),
    .binaryTarget(
      name: "libopencc",
      path: "Frameworks/libopencc.xcframework"),
    .binaryTarget(
      name: "libyaml-cpp",
      path: "Frameworks/libyaml-cpp.xcframework"),
    .target(
      name: "RimeKitObjC",
      dependencies: [
        "librime",
        "boost_atomic",
        "boost_filesystem",
        "boost_regex",
        "boost_system",
        "libglog",
        "libleveldb",
        "libmarisa",
        "libopencc",
        "libyaml-cpp",
      ],
      path: "Sources/ObjC",
      cSettings: [
        .headerSearchPath("Sources/C"),
      ],
      cxxSettings: [
        .headerSearchPath("Sources/C"),
      ],
      linkerSettings: [
        .linkedLibrary("c++"),
        .linkedFramework("CoreFoundation"),
      ]),
    .target(
      name: "RimeKit",
      dependencies: [
        "RimeKitObjC",
      ],
      path: "Sources/Swift"),
    .testTarget(
      name: "RimeKitTests",
      dependencies: ["RimeKit"]),
  ])
