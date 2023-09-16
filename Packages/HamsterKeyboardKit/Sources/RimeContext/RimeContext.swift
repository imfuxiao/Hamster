//
//  RimeContext.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation
import HamsterKit
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
  @Published @MainActor
  public var currentSchema: RimeSchema? = UserDefaults.standard.currentSchema {
    didSet {
      UserDefaults.standard.currentSchema = self.currentSchema
    }
  }

  /// 上次使用输入方案
  @Published @MainActor
  public var latestSchema: RimeSchema? = UserDefaults.standard.latestSchema {
    didSet {
      UserDefaults.standard.latestSchema = self.latestSchema
    }
  }

  /// 用户输入键值
  @Published @MainActor
  public var userInputKey: String = ""

  /// T9拼音，将用户T9拼音输入还原为正常的拼音
  @MainActor
  public var t9UserInputKey: String {
    guard !userInputKey.isEmpty else { return "" }
    guard let firstCandidate = suggestions.first else { return userInputKey }
    guard let comment = firstCandidate.subtitle else { return userInputKey }
    return userInputKey.t9ToPinyin(comment: comment)
  }

  /// 用户选择的候选拼音
  @MainActor
  public var selectPinyinList: [String] = []

  /// 字母模式
  @Published @MainActor
  public var asciiMode: Bool = false

  /// 候选字
  @Published @MainActor
  public var suggestions: [CandidateSuggestion] = []

  /// switcher hotkeys
  /// 默认值为 F4，但 RIME 启动时会根据当前配置加载此值
  public var hotKeys = ["f4"]

  public init() {}
}

// MARK: methods

public extension RimeContext {
  /// RIME Context 状态重置
  @MainActor
  func reset() {
    self.userInputKey = ""
    self.selectPinyinList.removeAll(keepingCapacity: false)
    self.suggestions.removeAll(keepingCapacity: false)
    Rime.shared.cleanComposition()
  }

  @MainActor
  func appendSelectSchema(_ schema: RimeSchema) async {
    self.selectSchemas.append(schema)
  }

  @MainActor
  func removeSelectSchema(_ schema: RimeSchema) async {
    self.selectSchemas.removeAll(where: { $0 == schema })
  }

  @MainActor
  func setCurrentSchema(_ schema: RimeSchema?) async {
    self.latestSchema = self.currentSchema
    self.currentSchema = schema
  }

  @MainActor
  func setAsciiMode(_ model: Bool) async {
    self.asciiMode = model
  }

  /// RIME 启动
  /// 注意：仅用于键盘扩展调用
  func start(hasFullAccess: Bool) async {
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: FileManager.appGroupSharedSupportDirectoryURL.path,
      userDataDir: hasFullAccess ? FileManager.appGroupUserDataDirectoryURL.path : FileManager.sandboxUserDataDirectory.path
    ))

    await setupRimeInputSchema()

    // 中英状态同步
    await setAsciiMode(Rime.shared.isAsciiMode())

    // 加载Switcher切换键
    let hotKeys = Rime.shared.getHotkeys()
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
    if !hotKeys.isEmpty {
      self.hotKeys = hotKeys
    }
    Logger.statistics.info("rime switcher hotkeys: \(hotKeys)")

    // RIME 输入方案切换状态同步
    Rime.shared.setLoadingSchemaCallback(callback: { [weak self] loadSchema in
      guard let self = self else { return }
      Task {
        let currentSchema = await self.currentSchema
        let schemaID = loadSchema.split(separator: "/").map { String($0) }[0]
        guard !schemaID.isEmpty, currentSchema?.schemaId != schemaID else { return }
        guard let changeSchema = await self.selectSchemas.first(where: { $0.schemaId == schemaID }) else { return }
        await self.setCurrentSchema(changeSchema)
        Logger.statistics.info("loading schema callback: currentSchema = \(changeSchema.schemaName), latestSchema = \(currentSchema?.schemaName)")
      }
    })

    // RIME 中英文状态切换同步
    Rime.shared.setChangeModeCallback(callback: { [weak self] mode in
      guard let self = self else { return }
      guard mode.hasSuffix("ascii_mode") else { return }
      Task {
        let mode = !mode.hasPrefix("!")
        await self.setAsciiMode(mode)
        Logger.statistics.info("rime setChangeModeCallback() asciiMode = \(mode)")
      }
    })
  }

  /// RIME 部署
  /// 注意：仅可用于主 App 调用
  func deployment(configuration: HamsterConfiguration) async throws {
    // 如果开启 iCloud，则先将 iCloud 下文件增量复制到 Sandbox
    if let enableAppleCloud = configuration.general?.enableAppleCloud, enableAppleCloud == true {
      let regex = configuration.general?.regexOnCopyFile ?? []
      do {
        try FileManager.copyAppleCloudSharedSupportDirectoryToSandbox(regex)
        try FileManager.copyAppleCloudUserDataDirectoryToSandbox(regex)
      } catch {
        Logger.statistics.error("RIME deploy error \(error.localizedDescription)")
        throw error
      }
    }

    // 判断是否需要覆盖键盘词库文件，如果为否，则先copy键盘词库文件至应用目录
    if let overrideDictFiles = configuration.rime?.overrideDictFiles, overrideDictFiles == true {
      let regex = configuration.rime?.regexOnOverrideDictFiles ?? []
      do {
        try FileManager.copyAppGroupUserDict(regex)
      } catch {
        Logger.statistics.error("RIME deploy error \(error.localizedDescription)")
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

      // 默认当前方案为输入方案中的第一个输入方案
      let firstInputSchema = selectSchemas.first { self.currentSchema == $0 }
      if firstInputSchema == nil, selectSchemas.isEmpty {
        self.currentSchema = selectSchemas[0]
      }

      // 默认最近一个输入方案为方案输入列表中的第二位
      self.latestSchema = selectSchemas.first { self.latestSchema == $0 }
      if self.latestSchema == nil, selectSchemas.count > 1 {
        self.latestSchema = selectSchemas[1]
      }
    }

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 将 Sandbox 目录下方案复制到AppGroup下
    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)
    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)
  }

  /// RIME 同步
  /// 注意：仅可用于主 App 调用
  func syncRime() async throws {
    Rime.shared.shutdown()
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: FileManager.sandboxSharedSupportDirectory.path,
      userDataDir: FileManager.sandboxUserDataDirectory.path
    ), maintenance: true, fullCheck: true)

    let handled = Rime.shared.API().syncUserData()
    Logger.statistics.info("RIME sync userData handled: \(handled)")
    Rime.shared.shutdown()

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 将 Sandbox 目录下方案复制到AppGroup下
    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)
    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)
  }

  /// RIME 重置
  /// 注意：仅可用于主 App 调用
  func restRime() async throws {
    // 重置输入方案目录
    do {
      try FileManager.initSandboxSharedSupportDirectory(override: true)
      try FileManager.initSandboxUserDataDirectory(override: true)
    } catch {
      Logger.statistics.error("rime init file directory error: \(error.localizedDescription)")
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

      // 默认当前方案为输入方案中的第一个输入方案
      let firstInputSchema = selectSchemas.first { self.currentSchema == $0 }
      if firstInputSchema == nil, selectSchemas.isEmpty {
        self.currentSchema = selectSchemas[0]
      }

      // 默认最近一个输入方案为方案输入列表中的第二位
      self.latestSchema = selectSchemas.first { self.latestSchema == $0 }
      if self.latestSchema == nil, selectSchemas.count > 1 {
        self.latestSchema = selectSchemas[1]
      }
    }

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 部署后将方案copy至AppGroup下供keyboard使用
    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)
    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)
  }
}

// MARK: - RIME 引擎相关操作

public extension RimeContext {
  /// 设置用户输入方案
  @MainActor
  func setupRimeInputSchema() async {
    let schema: RimeSchema
    if let currentSchema = currentSchema {
      schema = currentSchema
    } else {
      let selectSchemas = selectSchemas
      guard !selectSchemas.isEmpty else {
        Logger.statistics.error("rime select schemas is empty.")
        return
      }
      schema = selectSchemas.sorted().first!
      currentSchema = schema
    }
    let handle = Rime.shared.setSchema(schema.schemaId)
    Logger.statistics.info("self.rimeEngine set schema: \(schema.schemaName), handle = \(handle)")
  }

  /// 切换最近一次输入方案
  @MainActor
  func switchLatestInputSchema() async {
    let latestSchema: RimeSchema
    if let schema = self.latestSchema {
      latestSchema = schema
    } else {
      let selectSchemas = selectSchemas
      guard selectSchemas.count > 1 else {
        Logger.statistics.error("rime select schemas count less than 1.")
        return
      }
      latestSchema = selectSchemas.sorted()[1]
    }
    let handle = Rime.shared.setSchema(latestSchema.schemaId)
    Logger.statistics.info("self.rimeEngine set latest schema: \(latestSchema.schemaName), handle = \(handle)")
    if handle {
      self.latestSchema = self.currentSchema
      self.currentSchema = latestSchema
    }
    self.reset()
  }

  /// 触发 RIME 的 switcher
  func switcher() async {
    guard !hotKeys.isEmpty else { return }
    let hotkey = hotKeys[0] // 取第一个
    let hotKeyCode = RimeContext.hotKeyCodeMapping[hotkey, default: XK_F4]
    let hotKeyModifier = RimeContext.hotKeyCodeModifiersMapping[hotkey, default: Int32(0)]
    Logger.statistics.info("rimeSwitcher hotkey = \(hotkey), hotkeyCode = \(hotKeyCode), modifier = \(hotKeyModifier)")
    let handled = Rime.shared.inputKeyCode(hotKeyCode, modifier: hotKeyModifier)
    _ = await updateRimeEngine(handled)
  }

  /// 根据索引选择候选字
  func selectCandidate(index: Int) async -> String? {
    let handled = Rime.shared.selectCandidate(index: index)
    if let commitText = await updateRimeEngine(handled) {
      return commitText
    }
    return nil
  }

  // 同步中文简繁状态
  func syncTraditionalSimplifiedChineseMode(simplifiedModeKey: String) async {
    // 获取运行时状态
    let simplifiedModeValue = Rime.shared.simplifiedChineseMode(key: simplifiedModeKey)

    // 获取文件中保存状态
    let value = Rime.shared.API().getCustomize("patch/\(simplifiedModeKey)") ?? ""
    if !value.isEmpty {
      let handled = Rime.shared.setSimplifiedChineseMode(key: simplifiedModeKey, value: (value as NSString).boolValue)
      Logger.statistics.info("syncTraditionalSimplifiedChineseMode() set runtime state. key: \(simplifiedModeKey), value: \(value), handled: \(handled)")
    } else {
      // 首次加载保存简繁状态
      let handled = Rime.shared.API().customize(simplifiedModeKey, stringValue: String(simplifiedModeValue))
      Logger.statistics.info("syncTraditionalSimplifiedChineseMode() first save. key: \(simplifiedModeKey), value: \(simplifiedModeValue), handled: \(handled)")
    }
  }

  /// rime 中文简繁状态切换
  func switchTraditionalSimplifiedChinese(_ simplifiedModeKey: String) {
    let simplifiedModeValue = Rime.shared.simplifiedChineseMode(key: simplifiedModeKey)

    // 设置运行时状态
    var handled = Rime.shared.setSimplifiedChineseMode(key: simplifiedModeKey, value: !simplifiedModeValue)
    Logger.statistics.info("switchTraditionalSimplifiedChinese key: \(simplifiedModeKey), value: \(!simplifiedModeValue), handled: \(handled)")

    // 保存运行时状态
    handled = Rime.shared.API().customize(simplifiedModeKey, stringValue: String(!simplifiedModeValue))
    Logger.statistics.info("switchTraditionalSimplifiedChinese save file state. key: \(simplifiedModeKey), value: \(!simplifiedModeValue), handled: \(handled)")
  }

  /// 中英切换
  @MainActor
  func switchEnglishChinese() async {
    self.reset()
    self.asciiMode.toggle()
    let handled = Rime.shared.asciiMode(self.asciiMode)
    Logger.statistics.info("rime set ascii_mode handled \(handled)")
  }
}

// MARK: - 文字输入处理

public extension RimeContext {
  /**
   RIME引擎尝试处理输入文字
   */
  @MainActor
  func tryHandleInputText(_ text: String) async -> String? {
    // 由rime处理全部符号
    let handled = Rime.shared.inputKey(text)
    // 处理失败则返回 inputText
    guard handled else { return text }

    // 唯一码直接上屏
    let commitText = Rime.shared.getCommitText()
    guard commitText.isEmpty else {
      self.reset()
      return commitText
    }

    // 查看输入法状态
    let status = Rime.shared.status()
    // 如不存在候选字,则重置输入法
    if !status.isComposing {
      self.reset()
    }
    await self.syncContext()
    return nil
  }

  @MainActor
  func tryHandleInputCode(_ code: Int32) async throws -> String? {
    // 由rime处理全部符号
    let handled = Rime.shared.inputKeyCode(code)
    // 处理失败则返回 inputText
    guard handled else { throw "code = \(code), rimeEngine handle failed." }

    // 唯一码直接上屏
    let commitText = Rime.shared.getCommitText()
    guard commitText.isEmpty else {
      self.reset()
      return commitText
    }

    // 查看输入法状态
    let status = Rime.shared.status()
    // 如不存在候选字,则重置输入法
    if !status.isComposing {
      self.reset()
    }
    await self.syncContext()
    return nil
  }

  /// 同步context: 主要是获取当前引擎提供的候选文字, 同时更新rime published属性 userInputKey
  @MainActor
  func syncContext() async {
    let context = Rime.shared.context()

    if context.composition != nil {
      self.userInputKey = context.composition.preedit ?? ""
    }

    // 获取候选字
    self.suggestions = self.candidateListLimit()
  }

  @MainActor
  func candidateListLimit(_ count: Int = 100) -> [CandidateSuggestion] {
    // TODO: 最大候选文字数量
    let candidates = Rime.shared.getCandidate(index: 0, count: count)
    var result: [CandidateSuggestion] = []
    for (index, candidate) in candidates.enumerated() {
      var suggestion = CandidateSuggestion(
        text: candidate.text,
        title: candidate.text,
        isAutocomplete: index == 0,
        subtitle: candidate.comment
      )
      suggestion.index = index
      result.append(suggestion)
    }
    return result
  }

  @MainActor
  func deleteBackward() async {
    _ = Rime.shared.inputKeyCode(XK_BackSpace)
    await self.syncContext()
  }

  @MainActor
  func deleteBackwardNotSync() {
    _ = Rime.shared.inputKeyCode(XK_BackSpace)
  }

  @MainActor
  func inputKeyNotSync(_ text: String) -> Bool {
    Rime.shared.inputKey(text)
  }

  /// 更新 RIME 引擎
  func updateRimeEngine(_ handled: Bool) async -> String? {
    // 唯一码直接上屏
    let commitText = Rime.shared.getCommitText()
    if !commitText.isEmpty {
      return commitText
    }

    // 查看输入法状态
    let status = Rime.shared.status()

    // 如不存在候选字,则重置输入法
    if !status.isComposing {
      await self.reset()
      return nil
    }

    if handled {
      await self.syncContext()
      return nil
    }

    return nil
  }
}

// MARK: - static properties

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

// MARK: - T9 拼音处理

public extension RimeContext {
  /// 获取拼音候选列表
  @MainActor
  func getPinyinCandidates(userInputKey: String, selectPinyin: [String]) -> [String] {
    guard !userInputKey.isEmpty else { return [] }

    // 删除中文前缀和空格
    let chinesePrefix = String(userInputKey.filter { !$0.isASCII })
    var userInputKey = userInputKey
      .replacingOccurrences(of: chinesePrefix, with: "")
      .replacingOccurrences(of: " ", with: "")

    // 删除已选拼音
    selectPinyin.forEach {
      userInputKey = userInputKey.replacingOccurrences(of: $0, with: "")
    }

    guard !userInputKey.isEmpty else { return [] }
    var pinyinCandidates = [String]()

    // 因中文拼音最大长度为6，如：chuang，所以这里最大取用户输入的前6个字符
    for maxLength in 1 ... userInputKey.count {
      if maxLength > 6 {
        break
      }

      let prefixString = String(userInputKey.prefix(maxLength))
      if let t9Pinyins = t9ToPinyinMapping[prefixString] {
        pinyinCandidates += t9Pinyins
      }
    }

    // 按长度及字母排序
    return pinyinCandidates.sorted(by: {
      if $0.count > $1.count {
        return true
      }

      if $0.count == $1.count {
        if let _ = Int($0) {
          return false
        }

        if let _ = Int($1) {
          return false
        }

        return $0 < $1
      }

      return false
    })
  }
}
