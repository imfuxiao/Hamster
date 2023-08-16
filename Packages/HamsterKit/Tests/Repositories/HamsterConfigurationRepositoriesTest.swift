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

@testable import HamsterKit
@testable import HamsterModel

final class HamsterConfigurationRepositoriesTest: XCTestCase {

  func testTransform() throws {
    let str = "\\u4f60\\u597d"
    let target = try HamsterConfigurationRepositories.transform(str)
    XCTAssertNotEqual(str, "你好")
    XCTAssertEqual(target, "你好")
  }

  /// 测试 yaml 文件到导入和导入
  func testLoadAndSaveYaml() async throws {
    let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent("Hamster.yaml")
    Logger.statistics.debug("tempYamlPath: \(tempYamlPath.path)")
    let config = HamsterConfiguration.preview
    let configRepositories = HamsterConfigurationRepositories.shared
    try await configRepositories.saveToYAML(config: config, yamlPath: tempYamlPath)
    let tempConfig = try await configRepositories.loadFromYAML(yamlPath: tempYamlPath)
    XCTAssertEqual(tempConfig, config)
  }

  func testLoadPatchYaml() async throws {
    let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent("Hamster.custom.yaml")
    Logger.statistics.debug("tempYamlPath: \(tempYamlPath.path)")

    // 生成配置文件
    try HamsterConfigurationRepositories.transform(
      YAMLEncoder().encode(HamsterPatchConfiguration.preview)
    )
    .write(toFile: tempYamlPath.path, atomically: true, encoding: .utf8)

    // 读取配置文件
    let configRepositories = HamsterConfigurationRepositories.shared
    let patchConfig = try await configRepositories.loadPatchFromYAML(yamlPath: tempYamlPath)
    Logger.statistics.debug("patchConfig: \(patchConfig)")

    guard let patch = patchConfig.patch else { throw "patch can not found." }

    let mergeConfiguration = try HamsterConfiguration.preview.merge(with: patch, uniquingKeysWith: { $1 })
    Logger.statistics.debug("merge: \(mergeConfiguration)")
  }

  /// 测试保存至 UserDefaults
  func testLoadAndSaveUserDefault() async throws {
    let config = HamsterConfiguration.preview
    let configRepositories = HamsterConfigurationRepositories.shared
    configRepositories.removeFromUserDefaults()
    try await configRepositories.saveToUserDefaults(config)
    let tempConfig = try configRepositories.loadFromUserDefaults()
    XCTAssertEqual(tempConfig, config)
  }
}
