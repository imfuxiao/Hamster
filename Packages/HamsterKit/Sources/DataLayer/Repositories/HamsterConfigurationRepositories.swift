//
//  HamsterConfigurationRepositories.swift
//
//
//  Created by morse on 2023/7/3.
//

import Foundation
import HamsterModel
import os
import Yams

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
  public func loadFromYAML(yamlPath path: URL) async throws -> HamsterConfiguration {
//    let str = try String(contentsOf: path, encoding: .utf8)
//    return try YAMLDecoder().decode(HamsterConfiguration.self, from: Data(str.utf8))
    let data = try Data(contentsOf: path)
    return try YAMLDecoder().decode(HamsterConfiguration.self, from: data)
  }

  /// 加载 hamster.custom.yaml 文件
  public func loadPatchFromYAML(yamlPath path: URL) async throws -> HamsterPatchConfiguration {
//    let str = try String(contentsOf: path, encoding: .utf8)
//    return try YAMLDecoder().decode(HamsterPatchConfiguration.self, from: Data(str.utf8))
    let data = try Data(contentsOf: path)
    return try YAMLDecoder().decode(HamsterPatchConfiguration.self, from: data)
  }

  /// 保存配置至 yaml 文件中
  public func saveToYAML(config: HamsterConfiguration, yamlPath path: URL) async throws {
    let str = try Self.transform(YAMLEncoder().encode(config))
    try str.write(to: path, atomically: true, encoding: .utf8)
  }

  /// 在 UserDefaults 中保存应用配置
  public func saveToUserDefaults(_ config: HamsterConfiguration) async throws {
    try await saveToUserDefaults(config, key: Self.hamsterConfigurationKey)
  }

  /// 在 UserDefaults 中保存应用配置
  /// 注意这里的保存项是作为应用的默认配置，用于还原用户修改配置项
  public func saveToUserDefaultsOnDefault(_ config: HamsterConfiguration) async throws {
    try await saveToUserDefaults(config, key: Self.defaultHamsterConfigurationKey)
  }

  private func saveToUserDefaults(_ config: HamsterConfiguration, key: String) async throws {
    let data = try HamsterConfigurationRepositories.transform(YAMLEncoder().encode(config)).data(using: .utf8)
    UserDefaults.hamster.setValue(data, forKey: key)
  }

  /// 从 UserDefaults 中获取应用配置
  /// 注意：这里的配置项是应用当前最新的配置选项，可能会在用户变更某些配置时被修改
  /// 如果需要使用配置项的默认值，需要调用 loadFromUserDefaultsOnDefault() 方法
  public func loadFromUserDefaults() throws -> HamsterConfiguration {
    guard let data = UserDefaults.hamster.data(forKey: Self.hamsterConfigurationKey) else { throw "load HamsterConfiguration from UserDefault is empty." }
    return try YAMLDecoder().decode(HamsterConfiguration.self, from: data)
  }

  /// 从 UserDefaults 中获取应用默认配置
  /// 注意：这里是配置文件的原始值，用于还原某些已经被修改的配置项
  public func loadFromUserDefaultsOnDefault() throws -> HamsterConfiguration {
    guard let data = UserDefaults.hamster.data(forKey: Self.defaultHamsterConfigurationKey) else { throw "load default HamsterConfiguration from UserDefault is empty." }
    return try YAMLDecoder().decode(HamsterConfiguration.self, from: data)
  }

  /// 从 UserDefaults 中删除应用配置
  public func removeFromUserDefaults() {
    UserDefaults.hamster.removeObject(forKey: Self.hamsterConfigurationKey)
  }
}

extension HamsterConfigurationRepositories {
  /// 应用配置key
  private static let hamsterConfigurationKey = "com.ihsiao.apps.Hamster.configuration.keys.hamsterConfig"
  /// 默认应用配置key
  private static let defaultHamsterConfigurationKey = "com.ihsiao.apps.Hamster.configuration.keys.defaultHamsterConfig"

  /// 将 str 中的中文 unicode 编码 \uXXXX 转化为人类可读的
  static func transform(_ str: String) throws -> String {
    guard let transformStr = str.applyingTransform(StringTransform(rawValue: "Any-Hex/Java"), reverse: true) else {
      throw "String transform error."
    }
    return transformStr
  }
}
