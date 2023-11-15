//
//  UserDefaults.swift
//
//
//  Created by morse on 2023/7/3.
//

import Foundation
import OSLog
import Yams

/// UserDefault 扩展
public extension UserDefaults {
  /// AppGroup 共享 UserDefaults
  static let hamster = UserDefaults(suiteName: HamsterConstants.appGroupName)!

  // MARK: - 仓输入法 1.0 版本相关参数

  func _removeFirstRunningForV1() {
    removeObject(forKey: Self._appFirstLaunchForV1)
  }

  /// 应用首次运行检测（仓 1.0 版本）
  var _firstRunningForV1: Bool? {
    if object(forKey: Self._appFirstLaunchForV1) != nil {
      return bool(forKey: Self._appFirstLaunchForV1)
    }
    return nil
  }

  /// 是否开启划动（仓 1.0 版本）
  var _enableKeyboardSwipeGestureSymbol: Bool? {
    if object(forKey: Self._enableKeyboardSwipeGestureSymbol) != nil {
      return bool(forKey: Self._enableKeyboardSwipeGestureSymbol)
    }
    return nil
  }

  /// 划动配置参数（仓 1.0 版本）
  var _keyboardSwipeGestureSymbol: [String: String]? {
    if object(forKey: Self._keyboardSwipeGestureSymbol) != nil {
      return object(forKey: Self._keyboardSwipeGestureSymbol) as? [String: String]
    }
    return nil
  }

  /// 是否显示按键气泡（仓 1.0 版本）
  var _showKeyPressBubble: Bool? {
    if object(forKey: Self._showKeyPressBubble) != nil {
      return bool(forKey: Self._showKeyPressBubble)
    }
    return nil
  }

  /// 是否开启键盘声音（仓 1.0 版本）
  var _enableKeyboardFeedbackSound: Bool? {
    if object(forKey: Self._enableKeyboardFeedbackSound) != nil {
      return bool(forKey: Self._enableKeyboardFeedbackSound)
    }
    return nil
  }

  /// 是否开启键盘震动（仓 1.0 版本）
  var _enableKeyboardFeedbackHaptic: Bool? {
    if object(forKey: Self._enableKeyboardFeedbackHaptic) != nil {
      return bool(forKey: Self._enableKeyboardFeedbackHaptic)
    }
    return nil
  }

  /// 是否显示键盘收起按键（仓 1.0 版本）
  var _showKeyboardDismissButton: Bool? {
    if object(forKey: Self._showKeyboardDismissButton) != nil {
      return bool(forKey: Self._showKeyboardDismissButton)
    }
    return nil
  }

  /// 是否显示分号键（仓 1.0 版本）
  var _showSemicolonButton: Bool? {
    if object(forKey: Self._showSemicolonButton) != nil {
      return bool(forKey: Self._showSemicolonButton)
    }
    return nil
  }

  /// 是否显示空格左边按键（仓 1.0 版本）
  var _showSpaceLeftButton: Bool? {
    if object(forKey: Self._showSpaceLeftButton) != nil {
      return bool(forKey: Self._showSpaceLeftButton)
    }
    return nil
  }

  /// 空格左边按键键值（仓 1.0 版本）
  var _spaceLeftButtonValue: String? {
    if object(forKey: Self._spaceLeftButtonValue) != nil {
      return string(forKey: Self._spaceLeftButtonValue)
    }
    return nil
  }

  /// 是否显示空格右边按键（仓 1.0 版本）
  var _showSpaceRightButton: Bool? {
    if object(forKey: Self._showSpaceRightButton) != nil {
      return bool(forKey: Self._showSpaceRightButton)
    }
    return nil
  }

  /// 空格右边按键键值（仓 1.0 版本）
  var _spaceRightButtonValue: String? {
    if object(forKey: Self._spaceRightButtonValue) != nil {
      return string(forKey: Self._spaceRightButtonValue)
    }
    return nil
  }

  /// 是否显示空格右边中英文切换键（仓 1.0 版本）
  var _showSpaceRightSwitchLanguageButton: Bool? {
    if object(forKey: Self._showSpaceRightSwitchLanguageButton) != nil {
      return bool(forKey: Self._showSpaceRightSwitchLanguageButton)
    }
    return nil
  }

  /// 中英切换按键位于空格是否位于左侧（仓 1.0 版本）
  var _switchLanguageButtonInSpaceLeft: Bool? {
    if object(forKey: Self._switchLanguageButtonInSpaceLeft) != nil {
      return bool(forKey: Self._switchLanguageButtonInSpaceLeft)
    }
    return nil
  }

  /// rime 候选字最大数量（仓 1.0 版本）
  var _rimeMaxCandidateSize: Int? {
    if object(forKey: Self._rimeMaxCandidateSize) != nil {
      return integer(forKey: Self._rimeMaxCandidateSize)
    }
    return nil
  }

  /// rime 候选字Title字体大小（仓 1.0 版本）
  var _rimeCandidateTitleFontSize: Int? {
    if object(forKey: Self._rimeCandidateTitleFontSize) != nil {
      return integer(forKey: Self._rimeCandidateTitleFontSize)
    }
    return nil
  }

  /// rime 候选字 Comment 字体大小（仓 1.0 版本）
  var _rimeCandidateCommentFontSize: Int? {
    if object(forKey: Self._rimeCandidateCommentFontSize) != nil {
      return integer(forKey: Self._rimeCandidateCommentFontSize)
    }
    return nil
  }

  /// 候选栏高度（仓 1.0 版本）
  var _candidateBarHeight: Int? {
    if object(forKey: Self._candidateBarHeight) != nil {
      return integer(forKey: Self._candidateBarHeight)
    }
    return nil
  }

  /// RIME 简繁切换的key（仓 1.0 版本）
  var _rimeSimplifiedAndTraditionalSwitcherKey: String? {
    if object(forKey: Self._rimeSimplifiedAndTraditionalSwitcherKey) != nil {
      return string(forKey: Self._rimeSimplifiedAndTraditionalSwitcherKey)
    }
    return nil
  }

  /// 嵌入模式（仓 1.0 版本）
  var _enableInputEmbeddedMode: Bool? {
    if object(forKey: Self._enableInputEmbeddedMode) != nil {
      return bool(forKey: Self._enableInputEmbeddedMode)
    }
    return nil
  }

  /// 键盘是否自动小写（仓 1.0 版本）
  var _enableKeyboardAutomaticallyLowercase: Bool? {
    if object(forKey: Self._enableKeyboardAutomaticallyLowercase) != nil {
      return bool(forKey: Self._enableKeyboardAutomaticallyLowercase)
    }
    return nil
  }

  // MARK: - 仓输入法 2.0

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
      Logger.statistics.debug("save isFirstRunning: \(newValue)")
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
      Logger.statistics.debug("save overrideRimeDirectory: \(newValue)")
    }
  }

  /// RIME: 输入方案列表
  var schemas: [RimeSchema] {
    get {
      // 对数组类型且为Struct值需要特殊处理
      if let data = data(forKey: Self.schemasForKey), let array = try? JSONDecoder().decode([RimeSchema].self, from: data) {
        return array
      } else {
        return []
      }
    }
    set {
      if let data = try? JSONEncoder().encode(newValue) {
        UserDefaults.hamster.set(data, forKey: Self.schemasForKey)
        Logger.statistics.debug("save schemas: \(newValue)")
      }
    }
  }

  /// RIME: 用户选择输入方案列表
  var selectSchemas: [RimeSchema] {
    get {
      // 对数组类型且为Struct值需要特殊处理
      if let data = data(forKey: Self.selectSchemasForKey), let array = try? JSONDecoder().decode([RimeSchema].self, from: data) {
        return array
      } else {
        return []
      }
    }
    set {
      if let data = try? JSONEncoder().encode(newValue) {
        UserDefaults.hamster.set(data, forKey: Self.selectSchemasForKey)
        Logger.statistics.debug("save selectSchemas: \(newValue)")
      }
    }
  }

  /// RIME: 当前输入方案Schema
  var currentSchema: RimeSchema? {
    get {
      // 对数组类型且为Struct值需要特殊处理
      if let data = data(forKey: Self.currentSchemaForKey), let schema = try? JSONDecoder().decode(RimeSchema.self, from: data) {
        return schema
      } else {
        return nil
      }
    }
    set {
      if let data = try? JSONEncoder().encode(newValue) {
        UserDefaults.hamster.set(data, forKey: Self.currentSchemaForKey)
        Logger.statistics.debug("save currentSchema: \(data)")
      }
    }
  }

  /// RIME: 最近一次输入方案的Schema
  var latestSchema: RimeSchema? {
    get {
      // 对数组类型且为Struct值需要特殊处理
      if let data = data(forKey: Self.latestSchemaForKey), let schema = try? JSONDecoder().decode(RimeSchema.self, from: data) {
        return schema
      } else {
        return nil
      }
    }
    set {
      if let data = try? JSONEncoder().encode(newValue) {
        UserDefaults.hamster.set(data, forKey: Self.latestSchemaForKey)
        Logger.statistics.debug("save latestSchema: \(data)")
      }
    }
  }

  /// RIME Switch key
  var hotKeys: [String] {
    get {
      // 对数组类型且为Struct值需要特殊处理
      if let keys = array(forKey: Self.hotKeys) as? [String] {
        return keys
      } else {
        return ["f4"]
      }
    }
    set {
      set(newValue, forKey: Self.hotKeys)
    }
  }
}

extension UserDefaults {
  // MARK: - 1.0 版本

  private static let _appFirstLaunchForV1 = "app.launch.isFirst"
  // 是否显示按键气泡
  private static let _showKeyPressBubble = "view.keyboard.showKeyPressBubble"
  // 是否开启键盘声音
  private static let _enableKeyboardFeedbackSound = "app.keyboard.feedback.sound"
  // 是否开启键盘震动
  private static let _enableKeyboardFeedbackHaptic = "app.keyboard.feedback.haptic"
  // 是否显示键盘收起按键
  private static let _showKeyboardDismissButton = "app.keyboard.showDismissButton"
  // 是否显示分号键
  private static let _showSemicolonButton = "app.keyboard.showSemicolonButton"
  // 是否显示空格左边按键
  private static let _showSpaceLeftButton = "app.keyboard.showSpaceLeftButton"
  // 空格左边按键键值
  private static let _spaceLeftButtonValue = "app.keyboard.spaceLeftButtonValue"
  // 是否显示空格右边按键
  private static let _showSpaceRightButton = "app.keyboard.showSpaceRightButton"
  // 空格右边按键键值
  private static let _spaceRightButtonValue = "app.keyboard.spaceRightButtonValue"
  // 是否显示空格右边中英文切换键
  private static let _showSpaceRightSwitchLanguageButton = "app.keyboard.showSpaceRightSwitchLanguageButton"
  // 中英切换按键位于空格是否位于左侧
  private static let _switchLanguageButtonInSpaceLeft = "app.keyboard.switchLanguageButtonInSpaceLeft"
  // rime 候选字最大数量
  private static let _rimeMaxCandidateSize = "rime.maxCandidateSize"
  // rime 候选字Title字体大小
  private static let _rimeCandidateTitleFontSize = "rime.candidateTitleFontSize"
  private static let _rimeCandidateCommentFontSize = "rime.candidateCommentFontSize"
  // 候选栏高度
  private static let _candidateBarHeight = "app.keyboard.candidateBarHeight"
  // 是否开启划动手势
  private static let _enableKeyboardSwipeGestureSymbol = "keyboard.enableSwipeGestureSymbol"
  // 划动输入符号
  private static let _keyboardSwipeGestureSymbol = "keyboard.swipeGestureSymbol"
  // 简繁切换的值
  private static let _rimeSimplifiedAndTraditionalSwitcherKey = "rime.rimeSimplifiedAndTraditionalSwitcherKey"
  // 嵌入模式
  private static let _enableInputEmbeddedMode = "keyboard.enableInputEmbeddedMode"
  // Shift是否锁定
  private static let _enableKeyboardAutomaticallyLowercase = "keyboard.enableKeyboardAutomaticallyLowercase"

  // MARK: - 2.0 版本

  public static let isFirstRunningOfKey = "com.ihsiao.apps.Hamster.UserDefaults.isFirstRunning"
  private static let overrideRimeDirectoryOfKey = "com.ihsiao.apps.Hamster.UserDefaults.overrideRimeDirectory"
  private static let schemasForKey = "com.ihsiao.apps.Hamster.UserDefault.keys.schemas"
  private static let selectSchemasForKey = "com.ihsiao.apps.Hamster.UserDefault.keys.selectSchemas"
  private static let currentSchemaForKey = "com.ihsiao.apps.Hamster.UserDefault.keys.currentSchema"
  private static let latestSchemaForKey = "com.ihsiao.apps.Hamster.UserDefault.keys.latestSchemaForKey"
  private static let hotKeys = "com.ihsiao.apps.Hamster.UserDefault.keys.hotKeys"

  // MARK: - 补丁

  public static let patch_2_65 = "com.ihsiao.apps.Hamster.patchState.2.0.0-65"
}
