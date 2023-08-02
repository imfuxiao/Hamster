//
//  RimeContext.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation
import HamsterModel
import os
import RimeKit

/// RIME 运行时上下文
public actor RimeContext: ObservableObject {
  /// rime 输入方案列表
  @Published @MainActor
  public private(set) var schemas: [RimeSchema] = UserDefaults.hamster.schemas {
    didSet {
      UserDefaults.hamster.schemas = self.schemas
    }
  }

  /// rime 用户选择方案列表
  @Published @MainActor
  public private(set) var selectSchemas: [RimeSchema] = UserDefaults.hamster.selectSchemas {
    didSet {
      UserDefaults.hamster.selectSchemas = self.selectSchemas
    }
  }

  /// 当前输入方案
  @Published
  public var currentSchema: RimeSchema? = UserDefaults.hamster.currentSchema {
    didSet {
      UserDefaults.hamster.currentSchema = self.currentSchema
    }
  }

  /// 上次使用输入方案
  @Published
  public var latestSchema: RimeSchema? = UserDefaults.hamster.latestSchema {
    didSet {
      UserDefaults.hamster.latestSchema = self.latestSchema
    }
  }

  /// 用户输入键值
  @Published
  var userInputKey: String = ""

  /// 字母模式
  @Published
  var asciiMode: Bool = false

  /// 候选字
  @Published
  var suggestions: [CandidateSuggestion] = []

  /// switcher hotkeys
//  var hotKeys = ["f4"]

  public init() {}
}

// MARK: methods

public extension RimeContext {
  /// RIME Context 状态重置
  func reset() {
    self.userInputKey = ""
    self.suggestions = []
    Rime.shared.cleanComposition()
  }

  func candidateList(count: Int) -> [CandidateSuggestion] {
    let candidates = Rime.shared.getCandidate(index: 0, count: count)
    var result: [CandidateSuggestion] = []
    for (index, candidate) in candidates.enumerated() {
      var suggestion = CandidateSuggestion(
        text: candidate.text
      )
      suggestion.index = index
      suggestion.comment = candidate.comment
      suggestion.isAutocomplete = index == 0
      result.append(suggestion)
    }
    return result
  }

  func appendSelectSchema(_ schema: RimeSchema) async {
    await MainActor.run {
      self.selectSchemas.append(schema)
    }
  }

  func removeSelectSchema(_ schema: RimeSchema) async {
    await MainActor.run {
      self.selectSchemas.removeAll(where: { $0 == schema })
    }
  }

  /// RIME 部署
  func deployment(configuration: HamsterConfiguration) async throws {
    // 如果开启 iCloud，则先将 iCloud 下文件增量复制到 Sandbox
    if let enableAppleCloud = configuration.general?.enableAppleCloud, enableAppleCloud == true {
      let regex = configuration.general?.regexOnCopyFile ?? []
      do {
        try FileManager.copyAppleCloudSharedSupportDirectoryToSandbox(regex)
        try FileManager.copyAppleCloudUserDataDirectoryToSandbox(regex)
      } catch {
        logger.error("RIME deploy error \(error.localizedDescription)")
        throw error
      }
    }

    // 判断是否需要覆盖键盘词库文件，如果为否，则先copy键盘词库文件至应用目录
    if let overrideDictFiles = configuration.rime?.overrideDictFiles, overrideDictFiles == true {
      let regex = configuration.rime?.regexOnOverrideDictFiles ?? []
      do {
        try FileManager.copyAppGroupUserDict(regex)
      } catch {
        logger.error("RIME deploy error \(error.localizedDescription)")
        throw error
      }
    }

    Rime.shared.shutdown()
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: FileManager.sandboxSharedSupportDirectory.path,
      userDataDir: FileManager.sandboxUserDataDirectory.path
    ), maintenance: true, fullCheck: true)

    let schemas = Rime.shared.getSchemas().sorted()

    Rime.shared.shutdown()

    // 当用户选择输入方案如果不为空时，则取与输入方案列表的交集
    var selectSchemas = await self.selectSchemas
    if !selectSchemas.isEmpty {
      // 取交集
      let intersection = Set(schemas).intersection(selectSchemas)
      if !intersection.isEmpty {
        selectSchemas = Array(intersection).sorted()
      } else {
        if !schemas.isEmpty {
          selectSchemas = [schemas[0]]
        }
      }
    } else {
      if !schemas.isEmpty {
        selectSchemas = [schemas[0]]
      }
    }

    /// 切换 Main 线程 修改 @MainActor 标记的属性值
    await MainActor.run { [selectSchemas] in
      self.schemas = schemas
      self.selectSchemas = selectSchemas
    }

    // 默认当前方案为输入方案中的第一个输入方案
    let firstInputSchema = schemas.first { self.currentSchema == $0 }
    if firstInputSchema == nil, schemas.isEmpty {
      self.currentSchema = schemas[0]
    }

    // 默认最近一个输入方案为方案输入列表中的第二位
    self.latestSchema = schemas.first { self.latestSchema == $0 }
    if self.latestSchema == nil, schemas.count > 1 {
      self.latestSchema = schemas[1]
    }

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 将 Sandbox 目录下方案复制到AppGroup下
    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)
    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)
  }

  /// RIME 同步
  func syncRime() throws {
    Rime.shared.shutdown()
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: FileManager.sandboxSharedSupportDirectory.path,
      userDataDir: FileManager.sandboxUserDataDirectory.path
    ), maintenance: true, fullCheck: true)

    let handled = Rime.shared.API().syncUserData()
    logger.info("RIME sync userData handled: \(handled)")
    Rime.shared.shutdown()

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 将 Sandbox 目录下方案复制到AppGroup下
    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)
    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)
  }

  /// RIME 重置
  func restRime() async throws {
    // 重置输入方案目录
    do {
      try FileManager.initSandboxSharedSupportDirectory(override: true)
      try FileManager.initSandboxUserDataDirectory(override: true)
    } catch {
      logger.error("rime init file directory error: \(error.localizedDescription)")
      throw error
    }

    Rime.shared.shutdown()
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: FileManager.sandboxSharedSupportDirectory.path,
      userDataDir: FileManager.sandboxUserDataDirectory.path
    ), maintenance: true, fullCheck: true)

    let schemas = Rime.shared.getSchemas().sorted()

    Rime.shared.shutdown()

    // 当用户选择输入方案如果不为空时，则取与输入方案列表的交集
    var selectSchemas = await self.selectSchemas
    if !selectSchemas.isEmpty {
      // 取交集
      let intersection = Set(schemas).intersection(selectSchemas)
      if !intersection.isEmpty {
        selectSchemas = Array(intersection).sorted()
      } else {
        if !schemas.isEmpty {
          selectSchemas = [schemas[0]]
        }
      }
    } else {
      if !schemas.isEmpty {
        selectSchemas = [schemas[0]]
      }
    }

    /// 切换 Main 线程 修改 @MainActor 标记的属性值
    await MainActor.run { [selectSchemas] in
      self.schemas = schemas
      self.selectSchemas = selectSchemas
    }

    // 默认当前方案为输入方案中的第一个输入方案
    let firstInputSchema = schemas.first { self.currentSchema == $0 }
    if firstInputSchema == nil, schemas.isEmpty {
      self.currentSchema = schemas[0]
    }

    // 默认最近一个输入方案为方案输入列表中的第二位
    self.latestSchema = schemas.first { self.latestSchema == $0 }
    if self.latestSchema == nil, schemas.count > 1 {
      self.latestSchema = schemas[1]
    }

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 部署后将方案copy至AppGroup下供keyboard使用
    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)
    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)
  }
}

// MARK: static properties

public extension RimeContext {
  /// switcher hotkeys 键值映射
  static let hotKeyCodeMapping = [
    "f4": XK_F4,
    "control+grave": Int32("`".utf8.first!),
    "control+shift+grave": Int32("`".utf8.first!),
  ]

  static let hotKeyCodeModifiersMapping = [
    "f4": Int32(0),
    "control+grave": RimeModifier.kControlMask,
    "control+shift+grave": RimeModifier.kControlMask | RimeModifier.kShiftMask,
  ]
}
