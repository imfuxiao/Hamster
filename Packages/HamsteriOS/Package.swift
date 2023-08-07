// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HamsteriOS",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "HamsteriOS",
      targets: ["HamsteriOS"]),
  ],
  dependencies: [
    .package(url: "https://github.com/relatedcode/ProgressHUD.git", exact: "13.7.1"),
    .package(url: "https://github.com/simonbs/Runestone.git", exact: "0.3.0"),
    .package(url: "https://github.com/simonbs/TreeSitterLanguages.git", exact: "0.1.7"),
    .package(url: "https://github.com/imfuxiao/iFilemanager.git", exact: "0.7.16"),
    .package(path: "../HamsterUIKit"),
    .package(path: "../HamsterKit"),
    .package(path: "../RimeKit"),
    .package(path: "../HamsterKeyboard"),
  ],
  targets: [
    .target(
      name: "HamsteriOS",
      dependencies: [
        "iFilemanager",
        "Runestone",
        .product(name: "TreeSitterLua", package: "TreeSitterLanguages"),
        .product(name: "TreeSitterLuaQueries", package: "TreeSitterLanguages"),
        .product(name: "TreeSitterLuaRunestone", package: "TreeSitterLanguages"),
        .product(name: "TreeSitterYAML", package: "TreeSitterLanguages"),
        .product(name: "TreeSitterYAMLQueries", package: "TreeSitterLanguages"),
        .product(name: "TreeSitterYAMLRunestone", package: "TreeSitterLanguages"),
        "ProgressHUD",
        "HamsterUIKit",
        "HamsterKit",
        "HamsterKeyboard",
        "RimeKit",
      ],
      path: "Sources"),
    .testTarget(
      name: "HamsteriOSTests",
      dependencies: ["HamsteriOS"],
      path: "Tests"),
  ])
