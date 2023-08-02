//
//  UserDefaults.swift
//
//
//  Created by morse on 2023/7/3.
//

import Foundation
import HamsterModel
import RimeKit
import Yams

/// UserDefault 扩展
public extension UserDefaults {
  /// AppGroup 共享 UserDefaults
  static let hamster = UserDefaults(suiteName: HamsterConstants.appGroupName)!

  /// 应用首次运行
  var isFirstRunning: Bool {
    get {
      if object(forKey: Self.isFirstRunningOfKey) != nil {
        return bool(forKey: Self.isFirstRunningOfKey)
      }
      return true
    }
    set {
      setValue(newValue, forKey: Self.isFirstRunningOfKey)
      logger.debug("save isFirstRunning: \(newValue)")
    }
  }

  /// 是否覆盖 RIME 的用户数据目录
  var overrideRimeDirectory: Bool {
    get {
      if object(forKey: Self.overrideRimeDirectoryOfKey) != nil {
        return bool(forKey: Self.overrideRimeDirectoryOfKey)
      }
      return true
    }
    set {
      setValue(newValue, forKey: Self.overrideRimeDirectoryOfKey)
      logger.debug("save overrideRimeDirectory: \(newValue)")
    }
  }

  /// RIME: 输入方案列表
  var schemas: [RimeSchema] {
    get {
      // 对数组类型且为Struct值需要特殊处理
      if let data = data(forKey: Self.schemasForKey) {
        let array = try! PropertyListDecoder().decode([RimeSchema].self, from: data)
        return array
      } else {
        return []
      }
    }
    set {
      if let data = try? PropertyListEncoder().encode(newValue) {
        UserDefaults.hamster.set(data, forKey: Self.schemasForKey)
        logger.debug("save schemas: \(newValue)")
      }
    }
  }

  /// RIME: 用户选择输入方案列表
  var selectSchemas: [RimeSchema] {
    get {
      // 对数组类型且为Struct值需要特殊处理
      if let data = data(forKey: Self.selectSchemasForKey) {
        let array = try! PropertyListDecoder().decode([RimeSchema].self, from: data)
        return array
      } else {
        return []
      }
    }
    set {
      if let data = try? PropertyListEncoder().encode(newValue) {
        UserDefaults.hamster.set(data, forKey: Self.selectSchemasForKey)
        logger.debug("save selectSchemas: \(newValue)")
      }
    }
  }

  /// RIME: 当前输入方案Schema
  var currentSchema: RimeSchema? {
    get {
      // 对数组类型且为Struct值需要特殊处理
      if let data = data(forKey: Self.currentSchemaForKey) {
        return try! PropertyListDecoder().decode(RimeSchema.self, from: data)
      } else {
        return nil
      }
    }
    set {
      if let data = try? PropertyListEncoder().encode(newValue) {
        UserDefaults.hamster.set(data, forKey: Self.currentSchemaForKey)
        logger.debug("save currentSchema: \(data)")
      }
    }
  }

  /// RIME: 最近一次输入方案的Schema
  var latestSchema: RimeSchema? {
    get {
      // 对数组类型且为Struct值需要特殊处理
      if let data = data(forKey: Self.latestSchemaForKey) {
        return try! PropertyListDecoder().decode(RimeSchema.self, from: data)
      } else {
        return nil
      }
    }
    set {
      if let data = try? PropertyListEncoder().encode(newValue) {
        UserDefaults.hamster.set(data, forKey: Self.latestSchemaForKey)
        logger.debug("save latestSchema: \(data)")
      }
    }
  }
}

extension UserDefaults {
  private static let isFirstRunningOfKey = "com.ihsiao.apps.Hamster.UserDefaults.isFirstRunning"
  private static let overrideRimeDirectoryOfKey = "com.ihsiao.apps.Hamster.UserDefaults.overrideRimeDirectory"
  private static let schemasForKey = "com.ihsiao.apps.Hamster.UserDefault.keys.schemas"
  private static let selectSchemasForKey = "com.ihsiao.apps.Hamster.UserDefault.keys.selectSchemas"
  private static let currentSchemaForKey = "com.ihsiao.apps.Hamster.UserDefault.keys.currentSchema"
  private static let latestSchemaForKey = "com.ihsiao.apps.Hamster.UserDefault.keys.latestSchemaForKey"
}
