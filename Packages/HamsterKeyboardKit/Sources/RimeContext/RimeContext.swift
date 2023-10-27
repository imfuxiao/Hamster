//
//  RimeContext.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation
import HamsterKit
import OSLog
import RimeKit

/// RIME 运行时上下文
public class RimeContext: ObservableObject {
  /// 最大候选词数量
  public private(set) var maximumNumberOfCandidateWords: Int = 100

  /// rime 输入方案列表
  @Published
  public private(set) var schemas: [RimeSchema] = UserDefaults.hamster.schemas {
    didSet {
      UserDefaults.hamster.schemas = self.schemas
    }
  }

  /// rime 用户选择方案列表
  @Published
  public private(set) var selectSchemas: [RimeSchema] = UserDefaults.hamster.selectSchemas {
    didSet {
      UserDefaults.hamster.selectSchemas = self.selectSchemas.sorted()
    }
  }

  /// 当前输入方案
  @Published
  public var currentSchema: RimeSchema? = UserDefaults.hamster.currentSchema {
    didSet {
      // 如果没有完全访问权限，UserDefaults.hamster 会保存失败
      UserDefaults.hamster.currentSchema = currentSchema
    }
  }

  /// 上次使用输入方案
  public var latestSchema: RimeSchema? = UserDefaults.hamster.latestSchema {
    didSet {
      UserDefaults.hamster.currentSchema = currentSchema
    }
  }

  /// 用户输入键值
  @Published
  public var userInputKey: String = ""

  /// 待上屏文字
  public private(set) var commitText: String = ""

  /// T9拼音，将用户T9拼音输入还原为正常的拼音
  public var t9UserInputKey: String {
    guard !userInputKey.isEmpty else { return "" }
    guard let firstCandidate = suggestions.first else { return userInputKey }
    guard let comment = firstCandidate.subtitle else { return userInputKey }
    return userInputKey.t9ToPinyin(comment: comment)
  }

  /// 用户选择的候选拼音
  public var selectPinyinList: [String] = []

  /// 字母模式
  @Published
  public var asciiMode: Bool = false

  /// 候选字
  @Published
  public var suggestions: [CandidateSuggestion] = []

  /// switcher hotkeys
  /// 默认值为 F4，但 RIME 启动时会根据当前配置加载此值
  public var hotKeys = ["f4"]

  public init() {}

  func setMaximumNumberOfCandidateWords(_ count: Int) {
    self.maximumNumberOfCandidateWords = count
  }
}

// MARK: methods

public extension RimeContext {
  /// RIME Context 状态重置
  func reset() {
    self.userInputKey = ""
    self.selectPinyinList.removeAll(keepingCapacity: false)
    self.suggestions.removeAll(keepingCapacity: false)
    Rime.shared.cleanComposition()
  }

  func resetCommitText() {
    self.commitText = ""
  }

  /// 选择输入方案后重置当前输入方案
  /// 注意：仅限内部调用
  private func resetCurrentSchema() {
    // 默认当前方案为输入方案中的第一个输入方案
    // 注意：当前方案可能为空，所以不能用 contains() 判断
    let firstInputSchema = selectSchemas.first { self.currentSchema == $0 }
    if firstInputSchema == nil, !selectSchemas.isEmpty {
      self.currentSchema = selectSchemas[0]
    }
    Logger.statistics.debug("current schema: \(self.currentSchema?.schemaId ?? "") \(self.currentSchema?.schemaName ?? "")")
  }

  /// 选择输入方案后重置
  /// 注意：仅限内部调用
  private func resetLatestSchema() {
    // 默认最近一个输入方案为方案输入列表中的第二位
    let schemas = selectSchemas
      .filter { $0.schemaId != self.currentSchema?.schemaId }

    if self.latestSchema == nil, !schemas.isEmpty {
      self.latestSchema = schemas[0]
    } else if let latestSchema = self.latestSchema, !schemas.contains(latestSchema) {
      self.latestSchema = schemas.isEmpty ? nil : schemas[0]
    }
    Logger.statistics.debug("latest schema: \(self.latestSchema?.schemaId ?? "") \(self.latestSchema?.schemaName ?? "")")
  }

  func appendSelectSchema(_ schema: RimeSchema) {
    self.selectSchemas.append(schema)
    self.selectSchemas.sort()
    resetCurrentSchema()
    resetLatestSchema()
  }

  func removeSelectSchema(_ schema: RimeSchema) {
    self.selectSchemas.removeAll(where: { $0 == schema })
    self.selectSchemas.sort()
    resetCurrentSchema()
    resetLatestSchema()
  }

  func setCurrentSchema(_ schema: RimeSchema?) {
    self.latestSchema = self.currentSchema
    self.currentSchema = schema
  }

  func setAsciiMode(_ model: Bool) {
    self.asciiMode = model
  }

  /// RIME 启动
  /// 注意：仅用于键盘扩展调用
  func start(hasFullAccess: Bool) {
    // RIME 输入方案切换后同步状态
    Rime.shared.setLoadingSchemaCallback(callback: { [weak self] loadSchema in
      guard let self = self else { return }
      Task {
        let currentSchema = self.currentSchema
        let schemaID = loadSchema.split(separator: "/").map { String($0) }[0]
        guard !schemaID.isEmpty, currentSchema?.schemaId != schemaID else { return }
        // 从当前全部方案列表中获取
        guard let changeSchema = self.schemas.first(where: { $0.schemaId == schemaID }) else { return }
        self.setCurrentSchema(changeSchema)
        Logger.statistics.info("loading schema callback: currentSchema = \(changeSchema.schemaName), latestSchema = \(currentSchema?.schemaName)")
      }
    })

    // RIME 中英文状态切换同步
    Rime.shared.setChangeModeCallback(callback: { [weak self] mode in
      guard let self = self else { return }
      guard mode.hasSuffix("ascii_mode") else { return }
      Task {
        let mode = !mode.hasPrefix("!")
        self.setAsciiMode(mode)
        Logger.statistics.info("rime setChangeModeCallback() asciiMode = \(mode)")
      }
    })

    // 启动
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: FileManager.appGroupSharedSupportDirectoryURL.path,
      userDataDir: hasFullAccess ? FileManager.appGroupUserDataDirectoryURL.path : FileManager.sandboxUserDataDirectory.path
    ))

    // 设置初始输入方案
    setupRimeInputSchema()

    // 中英状态同步
    setAsciiMode(Rime.shared.isAsciiMode())

    // TODO: Rime.shared.getHotkeys() 读取 yaml 影响加载
    // 加载Switcher切换键
    // let hotKeys = Rime.shared.getHotkeys()
    //   .split(separator: ",")
    //   .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
    // if !hotKeys.isEmpty {
    //   self.hotKeys = hotKeys
    // }
    // Logger.statistics.info("rime switcher hotkeys: \(hotKeys)")
  }

  /// RIME 关闭
  /// 注意：仅用于键盘扩展调用
  func shutdown() {
    Rime.shared.shutdown()
  }

  /// RIME 部署
  /// 注意：仅可用于主 App 调用
  func deployment(configuration: HamsterConfiguration) throws {
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
    if let overrideDictFiles = configuration.rime?.overrideDictFiles, overrideDictFiles == false {
      let regex = configuration.rime?.regexOnOverrideDictFiles ?? []
      do {
        try FileManager.copyAppGroupUserDict(regex)
      } catch {
        Logger.statistics.error("RIME deploy error \(error.localizedDescription)")
        throw error
      }
    }

    // 检测文件目录是否存在不存在，新建
    try FileManager.createDirectory(override: false, dst: FileManager.sandboxSharedSupportDirectory)
    try FileManager.createDirectory(override: false, dst: FileManager.sandboxUserDataDirectory)

    Rime.shared.shutdown()
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: FileManager.sandboxSharedSupportDirectory.path,
      userDataDir: FileManager.sandboxUserDataDirectory.path
    ), maintenance: true, fullCheck: true)

    let schemas = Rime.shared.getSchemas().sorted()

    Rime.shared.shutdown()

    // 当用户选择输入方案如果不为空时，则取与输入方案列表的交集
    var selectSchemas = self.selectSchemas
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
    self.schemas = schemas
    self.selectSchemas = selectSchemas
    resetCurrentSchema()
    resetLatestSchema()

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 将 Sandbox 目录下方案复制到AppGroup下
    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)
    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)
  }

  /// RIME 同步
  /// 注意：仅可用于主 App 调用
  func syncRime(configuration: HamsterConfiguration) throws {
    // 检测文件目录是否存在不存在，新建
    try FileManager.createDirectory(override: false, dst: FileManager.sandboxSharedSupportDirectory)
    try FileManager.createDirectory(override: false, dst: FileManager.sandboxUserDataDirectory)

    // 判断是否需要覆盖键盘词库文件，如果为否，则先copy键盘词库文件至应用目录
    if let overrideDictFiles = configuration.rime?.overrideDictFiles, overrideDictFiles == false {
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
  func restRime() throws {
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
    var selectSchemas = self.selectSchemas
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
    if !schemas.isEmpty {
      self.schemas = schemas
      self.selectSchemas = selectSchemas
      resetCurrentSchema()
      resetLatestSchema()
    }

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 部署后将方案copy至AppGroup下供keyboard使用
    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)
    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)
  }

  var isRunning: Bool {
    Rime.shared.isRunning()
  }
}

// MARK: - RIME 引擎相关操作

public extension RimeContext {
  /// 设置用户输入方案
  func setupRimeInputSchema() {
    let schema: RimeSchema
    if let currentSchema = currentSchema {
      schema = currentSchema
    } else {
      guard let currentSchema = selectSchemas.first else {
        Logger.statistics.error("rime select schemas is empty.")
        return
      }
      schema = currentSchema
    }
    let handle = Rime.shared.setSchema(schema.schemaId)
    Logger.statistics.info("self.rimeEngine set schema: \(schema.schemaName), handle = \(handle)")
  }

  /// 切换最近一次输入方案
  func switchLatestInputSchema() {
    let latestSchema: RimeSchema
    if let schema = self.latestSchema {
      latestSchema = schema
    } else {
      // 过滤掉当前输入方案，取第一个方案为上个方案
      let selectSchemas = selectSchemas.filter { $0.schemaId != self.currentSchema?.schemaId }
      guard selectSchemas.count > 0 else {
        Logger.statistics.error("rime select schemas count less than 1.")
        return
      }
      latestSchema = selectSchemas[0]
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
  func switcher() {
    guard !hotKeys.isEmpty else { return }
    let hotkey = hotKeys[0] // 取第一个
    let hotKeyCode = RimeContext.hotKeyCodeMapping[hotkey, default: XK_F4]
    let hotKeyModifier = RimeContext.hotKeyCodeModifiersMapping[hotkey, default: Int32(0)]
    Logger.statistics.info("rimeSwitcher hotkey = \(hotkey), hotkeyCode = \(hotKeyCode), modifier = \(hotKeyModifier)")
    _ = Rime.shared.inputKeyCode(hotKeyCode, modifier: hotKeyModifier)
    syncContext()
  }

  /// 根据索引选择候选字
  func selectCandidate(index: Int) {
    _ = Rime.shared.selectCandidate(index: index)
    syncContext()
  }

  // 同步中文简繁状态
  func syncTraditionalSimplifiedChineseMode(simplifiedModeKey: String) {
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
  func switchEnglishChinese() {
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
  func tryHandleInputText(_ text: String) -> Bool {
    // 由rime处理全部符号
    let handled = Rime.shared.inputKey(text)

    // 处理失败则返回 inputText
    guard handled else { return false }

    self.syncContext()

    return true
  }

  /**
   RIME引擎尝试处理输入编码
   */
  func tryHandleInputCode(_ code: Int32) -> Bool {
    // 由rime处理全部符号
    let handled = Rime.shared.inputKeyCode(code)
    // 处理失败则返回 inputText
    guard handled else { return false }

    self.syncContext()

    return true
  }

  /// 同步context: 主要是获取当前引擎提供的候选文字, 同时更新rime published属性 userInputKey
  func syncContext() {
    let context = Rime.shared.context()
    let userInputText = context.composition?.preedit ?? ""
    let commitText = Rime.shared.getCommitText()
    let candidates = self.candidateListLimit(maximumNumberOfCandidateWords)

    Logger.statistics.debug("syncContext: userInputText = \(userInputText), commitText = \(commitText)")

    // 查看输入法状态
    let status = Rime.shared.status()

    // 注意：commitText 值的修改需要在修改 userInputKey 之前，
    // 因为 userInputKey 是 @Published，观测其值时会用到 commitText，所以如果 commitText 值修改滞后，会造成读取 commitText 不正确

    // 如果输入状态不是待组字阶段, 则重置输入法
    if !status.isComposing {
      self.commitText = commitText
      self.reset()
      return
    }

    self.commitText = commitText
    self.userInputKey = userInputText
    self.suggestions = candidates
  }

  func candidateListLimit(_ count: Int = 100) -> [CandidateSuggestion] {
    // TODO: 最大候选文字数量
    let candidates = Rime.shared.getCandidate(index: 0, count: count)
    var result: [CandidateSuggestion] = []
    for (index, candidate) in candidates.enumerated() {
      let suggestion = CandidateSuggestion(
        index: index,
        text: candidate.text,
        title: candidate.text,
        isAutocomplete: index == 0,
        subtitle: candidate.comment
      )
      result.append(suggestion)
    }
    return result
  }

  func deleteBackward() {
    _ = Rime.shared.inputKeyCode(XK_BackSpace)
    self.syncContext()
  }

  /// 删除用户输入，且不需要同步 RIME 上下文
  /// 注意：此方法是 T9 拼音用来做删除操作的
  @MainActor
  func deleteBackwardNotSync() {
    _ = Rime.shared.inputKeyCode(XK_BackSpace)
  }

  @MainActor
  func inputKeyNotSync(_ text: String) -> Bool {
    Rime.shared.inputKey(text)
  }

  @MainActor
  func getCaretPosition() -> Int {
    Rime.shared.getCaretPosition()
  }

  @MainActor
  func setCaretPosition(_ position: Int) {
    Rime.shared.setCaretPosition(position)
  }

  @MainActor
  func getContext() -> IRimeContext {
    Rime.shared.context()
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
