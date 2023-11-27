//
//  File.swift
//
//
//  Created by morse on 2023/7/3.
//

import Foundation
import os
import XCTest
// import ZippyJSON

@testable import HamsterKeyboardKit

final class HamsterConfigurationRepositoriesTest: XCTestCase {
  override func setUpWithError() throws {
    let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent("Hamster.yaml")
    if let data = HamsterConfiguration.sampleString.data(using: .utf8) {
      FileManager.default.createFile(atPath: tempYamlPath.path, contents: data)
    }
    let configuration = try HamsterConfigurationRepositories.shared.loadFromYAML(tempYamlPath)
    try HamsterConfigurationRepositories.shared.saveToUserDefaults(configuration)
  }

  func testPerformanceOfLoadConfigurationFromUserDefaults() throws {
    // self.measure(metrics: [XCTClockMetric()]) {
    measure {
      for _ in 0 ..< 1000 {
        do {
          let _ = try HamsterConfigurationRepositories.shared.loadFromUserDefaults()
        } catch {
          fatalError("load error")
        }
      }
    }
  }

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
    try configRepositories.saveToYAML(config: config, path: tempYamlPath)
    let tempConfig = try configRepositories.loadFromYAML(tempYamlPath)
    XCTAssertEqual(tempConfig, config)
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
