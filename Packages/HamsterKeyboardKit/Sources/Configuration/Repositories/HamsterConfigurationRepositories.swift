//
//  HamsterConfigurationRepositories.swift
//
//
//  Created by morse on 2023/7/3.
//

import Foundation
import os
import Yams
// import ZippyJSON

/// Hamster 配置存储
/// 单例
/// * 支持从 Yaml 文件读取配置
/// * 支持将配置序列化为 Yaml
/// * 支持从 UserDefault 读取配置
/// * 支持将配置存储到 UserDefault 中
public class HamsterConfigurationRepositories {
  public static let shared = HamsterConfigurationRepositories()

  private init() {}

  /// 加载 hamster.yaml 配置文件
  public func loadFromYAML(_ path: URL) throws -> HamsterConfiguration {
    let data = try Data(contentsOf: path, options: [])
    return try YAMLDecoder().decode(HamsterConfiguration.self, from: data)
  }

  /// 加载 hamster.custom.yaml 文件
  public func loadPatchFromYAML(yamlPath path: URL) throws -> HamsterPatchConfiguration {
    let data = try Data(contentsOf: path, options: [])
    return try YAMLDecoder().decode(HamsterPatchConfiguration.self, from: data)
  }

  /// 加载自定义键盘 yaml 配置文件
  public func loadCustomizerKeyboardLayoutYAML(_ path: URL) throws -> Keyboards {
    let data = try Data(contentsOf: path, options: [])
    return try YAMLDecoder().decode(Keyboards.self, from: data)
  }

  /// 保存配置至 yaml 文件中
  public func saveToYAML(config: HamsterConfiguration, path: URL) throws {
    let str = try Self.transform(YAMLEncoder().encode(config))
    try str.write(to: path, atomically: true, encoding: .utf8)
  }

  public func saveToPropertyList(config: HamsterConfiguration, path: URL) throws {
    let data = try PropertyListEncoder().encode(config)
    try? FileManager.default.removeItem(at: path)
    FileManager.default.createFile(atPath: path.path, contents: data)
  }

  public func saveToJSON(config: HamsterConfiguration, path: URL) throws {
    let data = try JSONEncoder().encode(config)
    try? FileManager.default.removeItem(at: path)
    FileManager.default.createFile(atPath: path.path, contents: data)
  }

  /// 保存配置补丁文件
  public func savePatchToYAML(config: HamsterConfiguration, yamlPath path: URL) throws {
    let patch = HamsterPatchConfiguration(patch: config)
    let str = try Self.transform(YAMLEncoder().encode(patch))
    try str.write(to: path, atomically: true, encoding: .utf8)
  }

  /// 在 UserDefaults 中保存应用配置
  public func saveToUserDefaults(_ config: HamsterConfiguration) throws {
    try saveToUserDefaults(config, key: Self.hamsterConfigurationKey)
  }

  /// 在 UserDefaults 中保存应用配置
  /// 注意: 这里的保存项是作为应用的默认配置，用于还原用户修改配置项
  public func saveToUserDefaultsOnDefault(_ config: HamsterConfiguration) throws {
    try saveToUserDefaults(config, key: Self.defaultHamsterConfigurationKey)
  }

  /// 在 UserDefaults 中保存 UI 界面中操作的配置
  public func saveAppConfigurationToUserDefaults(_ config: HamsterConfiguration) throws {
    try saveToUserDefaults(config, key: Self.hamsterAppConfigurationKey)
  }

  private func saveToUserDefaults(_ config: HamsterConfiguration, key: String) throws {
    let data = try JSONEncoder().encode(config)
    UserDefaults.hamster.setValue(data, forKey: key)
  }

  private func loadConfigFromUserDefaults(key: String) throws -> HamsterConfiguration {
    guard let data = UserDefaults.hamster.data(forKey: key) else { throw "load HamsterConfiguration from UserDefault is empty." }
    return try JSONDecoder().decode(HamsterConfiguration.self, from: data)
    // return try ZippyJSONDecoder().decode(HamsterConfiguration.self, from: data)
  }

  public func loadAppConfigurationFromUserDefaults() throws -> HamsterConfiguration {
    try loadConfigFromUserDefaults(key: Self.hamsterAppConfigurationKey)
  }

  /// 从 UserDefaults 中获取应用配置
  /// 注意：这里的配置项是应用当前最新的配置选项，可能会在用户变更某些配置时被修改
  /// 如果需要使用配置项的默认值，需要调用 loadFromUserDefaultsOnDefault() 方法
  public func loadFromUserDefaults() throws -> HamsterConfiguration {
    try loadConfigFromUserDefaults(key: Self.hamsterConfigurationKey)
  }

  /// 从 UserDefaults 中获取应用默认配置
  /// 注意：这里是配置文件的原始值，用于还原某些已经被修改的配置项
  public func loadFromUserDefaultsOnDefault() throws -> HamsterConfiguration {
    try loadConfigFromUserDefaults(key: Self.defaultHamsterConfigurationKey)
  }

  /// 从 UserDefaults 中删除应用配置
  public func removeFromUserDefaults() {
    UserDefaults.hamster.removeObject(forKey: Self.hamsterConfigurationKey)
  }

  /// 按优先级读取配置文件
  public func loadConfiguration() throws -> HamsterConfiguration {
    var configuration = HamsterConfiguration()

    // 读取 SharedSupport/hamster.yaml 配置文件，如果存在
    if FileManager.default.fileExists(atPath: FileManager.hamsterConfigFileOnSandboxSharedSupport.path) {
      configuration = try HamsterConfigurationRepositories.shared.loadFromYAML(FileManager.hamsterConfigFileOnSandboxSharedSupport)
    }

    // 读取 Rime/hamster.yaml 配置文件，如果存在，则 merge 不同属性，已 Rime/hamster.yaml 内容为主
    if FileManager.default.fileExists(atPath: FileManager.hamsterConfigFileOnUserData.path) {
      let hamsterConfiguration = try HamsterConfigurationRepositories.shared.loadFromYAML(FileManager.hamsterConfigFileOnUserData)
      configuration = try configuration.merge(with: hamsterConfiguration, uniquingKeysWith: { _, configValue in configValue })
    }

    // 读取 Rime/hamster.custom.yaml 配置文件，如果存在，并对相异的配置做 merge 合并，已 Rime/hamster.custom.yaml 文件为主
    if FileManager.default.fileExists(atPath: FileManager.hamsterPatchConfigFileOnUserData.path) {
      let patchConfiguration = try HamsterConfigurationRepositories.shared.loadPatchFromYAML(yamlPath: FileManager.hamsterPatchConfigFileOnUserData)
      if let patch = patchConfiguration.patch {
        configuration = try configuration.merge(with: patch, uniquingKeysWith: { _, patchValue in patchValue })
      }
    }

    // 读取 UI 操作产生的配置（存储在 UserDefaults 中, 如果存在，并对相异的配置做 merge 合并。
    if let appConfig = try? HamsterConfigurationRepositories.shared.loadAppConfigurationFromUserDefaults() {
      configuration = try configuration.merge(with: appConfig, uniquingKeysWith: { _, buildValue in buildValue })
    }

    return configuration
  }

  /// 清空 UI 交互生成的配置
  public func resetAppConfiguration() {
    UserDefaults.hamster.removeObject(forKey: Self.hamsterAppConfigurationKey)
  }

  /// 清空应用配置（包含默认的应用配置）
  public func resetConfiguration() {
    UserDefaults.hamster.removeObject(forKey: Self.hamsterAppConfigurationKey)
    UserDefaults.hamster.removeObject(forKey: Self.hamsterConfigurationKey)
    UserDefaults.hamster.removeObject(forKey: Self.defaultHamsterConfigurationKey)
  }
}

public extension HamsterConfigurationRepositories {
  /// UI操作生成的配置
  static let hamsterAppConfigurationKey = "com.ihsiao.apps.Hamster.configuration.keys.hamsterAppConfig"
  /// 应用配置key
  static let hamsterConfigurationKey = "com.ihsiao.apps.Hamster.configuration.keys.hamsterConfig"
  /// 默认应用配置key
  static let defaultHamsterConfigurationKey = "com.ihsiao.apps.Hamster.configuration.keys.defaultHamsterConfig"

  /// 将 str 中的中文 unicode 编码 \uXXXX 转化为人类可读的
  static func transform(_ str: String) throws -> String {
    guard let transformStr = str.applyingTransform(StringTransform(rawValue: "Any-Hex/Java"), reverse: true) else {
      throw "String transform error."
    }
    return transformStr
  }
}
