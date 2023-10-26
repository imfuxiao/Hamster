//
//  File.swift
//
//
//  Created by morse on 2023/7/3.
//

import Foundation
import os
import XCTest
import Yams

@testable import HamsterKeyboardKit

final class HamsterConfigurationRepositoriesTest: XCTestCase {
  func testTransform() throws {
    let str = "\\u4f60\\u597d"
    let target = try HamsterConfigurationRepositories.transform(str)
    XCTAssertNotEqual(str, "你好")
    XCTAssertEqual(target, "你好")
  }

  /// 测试 yaml 文件到导入和导入
  func testLoadAndSaveYaml() throws {
    let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent("Hamster.yaml")
    Logger.statistics.debug("tempYamlPath: \(tempYamlPath.path)")
    let config = HamsterConfiguration.preview
    let configRepositories = HamsterConfigurationRepositories.shared
    try configRepositories.saveToYAML(config: config, yamlPath: tempYamlPath)
    let tempConfig = try configRepositories.loadFromYAML(tempYamlPath)
    XCTAssertEqual(tempConfig, config)
  }

  func testLoadPatchYaml() throws {
    let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent("hamster.custom.yaml")
    Logger.statistics.debug("tempYamlPath: \(tempYamlPath.path)")

    // 生成配置文件
    try HamsterConfigurationRepositories.transform(
      YAMLEncoder().encode(HamsterPatchConfiguration.preview)
    )
    .write(toFile: tempYamlPath.path, atomically: true, encoding: .utf8)

    // 读取配置文件
    let configRepositories = HamsterConfigurationRepositories.shared
    let patchConfig = try configRepositories.loadPatchFromYAML(yamlPath: tempYamlPath)
    Logger.statistics.debug("patchConfig: \(patchConfig)")

    guard let patch = patchConfig.patch else { throw "patch can not found." }

    let mergeConfiguration = try HamsterConfiguration.preview.merge(with: patch, uniquingKeysWith: { $1 })
    Logger.statistics.debug("merge: \(mergeConfiguration)")
  }

  /// 测试保存至 UserDefaults
  func testLoadAndSaveUserDefault() throws {
    let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent("Hamster.yaml")
    Logger.statistics.debug("tempYamlPath: \(tempYamlPath.path)")
    if let data = HamsterConfiguration.sampleString.data(using: .utf8) {
      FileManager.default.createFile(atPath: tempYamlPath.path, contents: data)
    } else {
      fatalError("can not generator hamster.yaml")
    }

    let configRepositories = HamsterConfigurationRepositories.shared
    configRepositories.removeFromUserDefaults()

    let tempConfig = try configRepositories.loadFromYAML(tempYamlPath)
    try configRepositories.saveToUserDefaults(tempConfig)
    let config = try configRepositories.loadFromUserDefaults()
    XCTAssertNotNil(config.swipe?.keyboardSwipe)
  }

  func testLoadConfigYaml() throws {
    let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent("Hamster.yaml")
    Logger.statistics.debug("tempYamlPath: \(tempYamlPath.path)")
    if let data = HamsterConfiguration.sampleString.data(using: .utf8) {
      FileManager.default.createFile(atPath: tempYamlPath.path, contents: data)
    } else {
      fatalError("can not generator hamster.yaml")
    }
    let configRepositories = HamsterConfigurationRepositories.shared
    let tempConfig = try configRepositories.loadFromYAML(tempYamlPath)
    print(tempConfig)
  }
}
