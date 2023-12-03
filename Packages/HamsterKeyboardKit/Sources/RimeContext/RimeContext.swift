//
//  RimeContext.swift
//
//
//  Created by morse on 2023/6/30.
//

import Combine
import Foundation
import HamsterKit
import OSLog
import RimeKit

/// RIME 运行时上下文
public class RimeContext {
  /// 最大候选词数量
  public private(set) lazy var maximumNumberOfCandidateWords: Int = 100

  /// 是否使用 IRimeContext 中分页信息
  public private(set) lazy var useContextPaging = false

  /// rime 输入方案列表
  public private(set) lazy var schemas: [RimeSchema] = UserDefaults.hamster.schemas {
    didSet {
      UserDefaults.hamster.schemas = self.schemas
    }
  }

  /// rime 用户选择方案列表
  public lazy var selectSchemas: [RimeSchema] = UserDefaults.hamster.selectSchemas {
    didSet {
      UserDefaults.hamster.selectSchemas = self.selectSchemas.sorted()
    }
  }

  /// 当前输入方案
  public lazy var currentSchema: RimeSchema? = UserDefaults.hamster.currentSchema {
    didSet {
      // 注意：如果没有完全访问权限，UserDefaults.hamster 会保存失败
      UserDefaults.hamster.currentSchema = currentSchema
    }
  }

  /// 上次使用输入方案
  public lazy var latestSchema: RimeSchema? = UserDefaults.hamster.latestSchema {
    didSet {
      UserDefaults.hamster.currentSchema = currentSchema
    }
  }

  /// 用户输入键值
  public var userInputKey: String = "" {
    didSet {
      userInputKeySubject.send(userInputKey)
    }
  }

  private let userInputKeySubject = PassthroughSubject<String, Never>()
  public var userInputKeyPublished: AnyPublisher<String, Never> {
    userInputKeySubject.eraseToAnyPublisher()
  }

  /// 待上屏文字
  public private(set) lazy var commitText: String = ""

  /// T9拼音，将用户T9拼音输入还原为正常的拼音
  @MainActor
  public var t9UserInputKey: String {
    var preview = rimeContext?.composition.preedit ?? ""
    if let highlightIndex = rimeContext?.menu.highlightedCandidateIndex,
       let candidates = rimeContext?.menu.candidates,
       highlightIndex < candidates.count
    {
      let candidate = candidates[Int(highlightIndex)]
      preview = preview.t9pinyinToPinyin(comment: candidate.comment ?? "")
    }
    return preview.replaceT9pinyin
  }

  /// rime option 选项对应的值的缓存
  private var optionValueCache: [String: [Bool: String]] = [:]

  /// 用户选择的候选拼音
  /// 注意：只保存最近一次选择的拼音和拼音开始位置及长度
  public lazy var selectCandidatePinyin: (String, Int, Int)? = nil

  /// 字母模式
  @MainActor
  public lazy var asciiMode: Bool = false

  /// 候选字
  @MainActor @Published
  public var suggestions: [CandidateSuggestion] = []

  @MainActor @Published
  public var rimeContext: IRimeContext? = nil

  /// rime option
  @MainActor @Published
  public var optionState: String? = nil

  /// 划动分页模式下，当前页码，从 0 开始
  public lazy var pageIndex: Int = 0

  /// 根据页码计算首个候选文字索引
  public var candidateIndex: Int {
    pageIndex * maximumNumberOfCandidateWords
  }

  /// switcher hotkeys
  /// 默认值为 F4，但 RIME 重新部署时会根据当前配置加载此值
  public lazy var hotKeys = UserDefaults.hamster.hotKeys {
    didSet {
      UserDefaults.hamster.hotKeys = hotKeys
    }
  }

  public init() {}

  func setMaximumNumberOfCandidateWords(_ count: Int) {
    self.maximumNumberOfCandidateWords = count
  }

  func setUseContextPaging(_ state: Bool) {
    self.useContextPaging = state
  }
}

// MARK: methods

public extension RimeContext {
  /// RIME Context 状态重置
  @MainActor
  func reset() {
    self.pageIndex = 0
    self.userInputKey = ""
    self.selectCandidatePinyin = nil
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

  @MainActor
  func setAsciiMode(_ model: Bool) {
    self.asciiMode = model
  }

  /// RIME 启动
  /// 注意：仅用于键盘扩展调用
  func start(hasFullAccess: Bool) async {
    Rime.shared.setNotificationDelegate(self)

    // 启动
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: FileManager.appGroupSharedSupportDirectoryURL.path,
      userDataDir: hasFullAccess ? FileManager.appGroupUserDataDirectoryURL.path : FileManager.sandboxUserDataDirectory.path
    ))

    // 设置初始输入方案
    setupRimeInputSchema()

    // 中英状态同步
    await setAsciiMode(Rime.shared.isAsciiMode())
  }

  /// RIME 关闭
  /// 注意：仅用于键盘扩展调用
  func shutdown() {
    Rime.shared.shutdown()
  }

  /// RIME 部署
  /// 注意：仅可用于主 App 调用
  func deployment(configuration: inout HamsterConfiguration) throws {
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

    if !isRunning {
      Rime.shared.start(Rime.createTraits(
        sharedSupportDir: FileManager.sandboxSharedSupportDirectory.path,
        userDataDir: FileManager.sandboxUserDataDirectory.path
      ), maintenance: true, fullCheck: true)
    }
    // 此 API 根据用户配置的 scheme_list 参数获取列表，当方案不提供 schema_list 参数时，获取为空
    var schemas = Rime.shared.getSchemas().sorted()
    if schemas.isEmpty {
      // 检测 default.custom.yaml 文件是否存在，后面解析 schema_list 需要存在此文件
      let defaultCustomFilePath = FileManager.sandboxUserDataDefaultCustomYaml.path
      var createDefaultCustomFileHandle = false
      if !FileManager.default.fileExists(atPath: defaultCustomFilePath) {
        let handled = FileManager.default.createFile(atPath: defaultCustomFilePath, contents: nil)
        Logger.statistics.debug("create file \(defaultCustomFilePath), handled: \(handled)")
        createDefaultCustomFileHandle = handled
      }

      // 此 API 可获取全部方案列表，不经过 schema_list 参数
      schemas = Rime.shared.getAvailableRimeSchemas().sorted()
      // 只有新建 default.custom.yaml 文件才会写 schema_list 参数，方案如果已存在则不写，因为复写文件会导致文件中的注释信息丢失。
      if createDefaultCustomFileHandle {
        let result = Rime.shared.selectRimeSchemas(schemas.map { $0.schemaId })
        if !result {
          Logger.statistics.warning("rime set select rime schemas false")
        } else {
          // 写完 schema_list 参数后需要重新编译方案词库文件
          Rime.shared.shutdown()
          Rime.shared.start(Rime.createTraits(
            sharedSupportDir: FileManager.sandboxSharedSupportDirectory.path,
            userDataDir: FileManager.sandboxUserDataDirectory.path
          ), maintenance: true, fullCheck: true)
        }
      }
    }

    // 提前在部署阶段加载 RimeSwitch hotKey, 此步骤放在键盘启动阶段会减慢启动速度
    // 加载Switcher切换键
    let hotKeys = Rime.shared.getHotkeys()
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
    if !hotKeys.isEmpty {
      self.hotKeys = hotKeys
    }
    Logger.statistics.info("rime switcher hotkeys: \(hotKeys)")

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

    self.schemas = schemas
    self.selectSchemas = selectSchemas
    resetCurrentSchema()
    resetLatestSchema()

    configuration = try HamsterConfigurationRepositories.shared.loadConfiguration()

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 保存配置至 build/hamster.yaml
    // try? HamsterConfigurationRepositories.shared.saveToYAML(config: configuration, path: FileManager.hamsterConfigFileOnBuild)
//    try? HamsterConfigurationRepositories.shared.saveToJSON(
//      config: configuration,
//      path: FileManager.sandboxUserDataDirectory.appendingPathComponent("/build/hamster.json")
//    )
    try? HamsterConfigurationRepositories.shared.saveToPropertyList(
      config: configuration,
      path: FileManager.sandboxUserDataDirectory.appendingPathComponent("/build/hamster.plist")
    )

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

    if !isRunning {
      Rime.shared.start(Rime.createTraits(
        sharedSupportDir: FileManager.sandboxSharedSupportDirectory.path,
        userDataDir: FileManager.sandboxUserDataDirectory.path
      ), maintenance: true, fullCheck: true)
    }
    let handled = Rime.shared.API().syncUserData()
    Logger.statistics.info("RIME sync userData handled: \(handled)")
    Rime.shared.shutdown()

    // 键盘重新同步文件标志
    UserDefaults.hamster.overrideRimeDirectory = true

    // 保存配置至 build/hamster.yaml
    // try? HamsterConfigurationRepositories.shared.saveToYAML(config: configuration, path: FileManager.hamsterConfigFileOnBuild)
//    try? HamsterConfigurationRepositories.shared.saveToJSON(
//      config: configuration,
//      path: FileManager.sandboxUserDataDirectory.appendingPathComponent("/build/hamster.json")
//    )
    try? HamsterConfigurationRepositories.shared.saveToPropertyList(
      config: configuration,
      path: FileManager.sandboxUserDataDirectory.appendingPathComponent("/build/hamster.plist")
    )

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
      try FileManager.initSandboxUserDataDirectory(override: true, unzip: true)
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
  @MainActor
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
  @MainActor
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
  @MainActor
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
    if value.isEmpty {
      // 首次加载保存简繁状态
      let handled = Rime.shared.API().customize(simplifiedModeKey, stringValue: String(simplifiedModeValue))
      Logger.statistics.info("syncTraditionalSimplifiedChineseMode() first save. key: \(simplifiedModeKey), value: \(simplifiedModeValue), handled: \(handled)")
    } else {
//      let handled = Rime.shared.setSimplifiedChineseMode(key: simplifiedModeKey, value: (value as NSString).boolValue)
//      Logger.statistics.info("syncTraditionalSimplifiedChineseMode() set runtime state. key: \(simplifiedModeKey), value: \(value), handled: \(handled)")
    }
  }

  /// rime 中文简繁状态切换
  func switchTraditionalSimplifiedChinese(_ simplifiedModeKey: String) {
    let simplifiedModeValue = Rime.shared.simplifiedChineseMode(key: simplifiedModeKey)

    // 设置运行时状态
    Rime.shared.setSimplifiedChineseMode(key: simplifiedModeKey, value: !simplifiedModeValue)
    Logger.statistics.info("switchTraditionalSimplifiedChinese key: \(simplifiedModeKey), value: \(!simplifiedModeValue)")

    // 保存运行时状态
    let handled = Rime.shared.API().customize(simplifiedModeKey, stringValue: String(!simplifiedModeValue))
    Logger.statistics.info("switchTraditionalSimplifiedChinese save file state. key: \(simplifiedModeKey), value: \(!simplifiedModeValue), handled: \(handled)")
  }

  /// 中英切换
  @MainActor
  func switchEnglishChinese() {
    self.reset()
    self.asciiMode.toggle()
    Rime.shared.asciiMode(asciiMode)
  }
}

// MARK: implementation IRimeNotificationDelegate

extension RimeContext: IRimeNotificationDelegate {
  public func onDeployStart() {
    Logger.statistics.info("HamsterRimeNotification: onDeployStart")
  }

  public func onDeploySuccess() {
    Logger.statistics.info("HamsterRimeNotification: onDeploySuccess")
  }

  public func onDeployFailure() {
    Logger.statistics.info("HamsterRimeNotification: onDeployFailure")
  }

  @MainActor
  public func onChangeMode(_ option: String) {
    Logger.statistics.info("HamsterRimeNotification: onChangeMode, mode: \(option)")

    let optionState = !option.hasPrefix("!")
    let optionName = optionState ? option : String(option.dropFirst())

    if optionValueCache[optionName] == nil {
      optionValueCache[optionName] = [
        true: Rime.shared.getStateLabel(option: optionName, state: true, abbreviated: true),
        false: Rime.shared.getStateLabel(option: optionName, state: false, abbreviated: true),
      ]
    }

    // 中英模式
    if option.hasSuffix("ascii_mode") {
      self.setAsciiMode(optionState)
    }

    // 设置 rime option 对应的值
    self.optionState = optionValueCache[optionName]?[optionState]
  }

  @MainActor
  public func onLoadingSchema(_ loadSchema: String) {
    Logger.statistics.info("HamsterRimeNotification: onLoadingSchema, schema: \(loadSchema)")
    Task {
      let currentSchema = self.currentSchema
      let schemaID = loadSchema.split(separator: "/").map { String($0) }[0]
      guard !schemaID.isEmpty, currentSchema?.schemaId != schemaID else { return }
      // 从当前全部方案列表中获取
      guard let changeSchema = self.schemas.first(where: { $0.schemaId == schemaID }) else { return }
      self.setCurrentSchema(changeSchema)
      self.optionState = changeSchema.schemaName
      Logger.statistics.info("loading schema callback: currentSchema = \(changeSchema.schemaName), latestSchema = \(currentSchema?.schemaName)")
    }
  }
}

// MARK: - 文字输入处理

public extension RimeContext {
  /**
   RIME引擎尝试处理输入文字
   */
  @MainActor
  func tryHandleInputText(_ text: String) -> Bool {
    // 由rime处理全部符号
    let handled = Rime.shared.inputKey(text)

    // 处理失败则返回 inputText
    guard handled else { return false }

    self.syncContext()

    return true
  }

  @MainActor
  func tryHandleReplaceInputTexts(_ text: String, startPos: Int, count: Int) -> Bool {
    guard Rime.shared.replaceInputKeys(text, startPos: startPos, count: count) else { return false }
    self.selectCandidatePinyin = (text, startPos, count)
    self.syncContext()
    return true
  }

  func getInputKeys() -> String {
    Rime.shared.getInputKeys()
  }

  /**
   RIME引擎尝试处理输入编码
   */
  @MainActor
  func tryHandleInputCode(_ code: Int32, modifier: Int32 = 0) -> Bool {
    // 由rime处理全部符号
    let handled = Rime.shared.inputKeyCode(code, modifier: modifier)
    // 处理失败则返回 inputText
    guard handled else { return false }

    self.syncContext()

    return true
  }

  /// 同步context: 主要是获取当前引擎提供的候选文字, 同时更新rime published属性 userInputKey
  @MainActor
  func syncContext() {
    self.pageIndex = 0
    self.rimeContext = Rime.shared.context()
    let userInputText = rimeContext?.composition?.preedit ?? ""
    let commitText = Rime.shared.getCommitText()
    var candidates = [CandidateSuggestion]()
    if !useContextPaging {
      var highlightIndex = 0
      if let menu = rimeContext?.menu {
        highlightIndex = Int(menu.pageSize * menu.pageNo + menu.highlightedCandidateIndex)
      }
      candidates = self.candidateListLimit(index: candidateIndex, highlightIndex: highlightIndex, count: maximumNumberOfCandidateWords)
    }

    // Logger.statistics.debug("syncContext: userInputText = \(userInputText), commitText = \(commitText)")

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

    // 注意赋值顺序
    self.userInputKey = userInputText
    self.commitText = commitText
    self.suggestions = candidates
  }

  /// 分页：下一页
  @MainActor
  func nextPage() {
    self.pageIndex += 1
    var highlightIndex = 0
    if let menu = rimeContext?.menu {
      highlightIndex = Int(menu.pageSize * menu.pageNo + menu.highlightedCandidateIndex)
    }
    let candidates = self.candidateListLimit(index: candidateIndex, highlightIndex: highlightIndex, count: maximumNumberOfCandidateWords)
    if !candidates.isEmpty {
      self.suggestions.append(contentsOf: candidates)
    } else {
      self.pageIndex -= 1
    }
  }

  /// 获取候选列表
  func candidateListLimit(index: Int, highlightIndex: Int, count: Int) -> [CandidateSuggestion] {
    // TODO: 最大候选文字数量
    let candidates = Rime.shared.candidateListWithIndex(index: index, andCount: count)
    var result: [CandidateSuggestion] = []
    // 候选文字首个索引
    let candidateIndex = self.candidateIndex
    for (index, candidate) in candidates.enumerated() {
      let index = candidateIndex + index
      let suggestion = CandidateSuggestion(
        index: index,
        label: "\(index + 1)",
        text: candidate.text,
        title: candidate.text,
        isAutocomplete: index == highlightIndex,
        subtitle: candidate.comment
      )
      result.append(suggestion)
    }
    return result
  }

  @MainActor
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

  static let keyCodeMapping: [String: Int32] = [
    "0": XK_0,
    "1": XK_1,
    "2": XK_2,
    "3": XK_3,
    "4": XK_4,
    "5": XK_5,
    "6": XK_6,
    "7": XK_7,
    "8": XK_8,
    "9": XK_9,

    "A": XK_A,
    "B": XK_B,
    "C": XK_C,
    "D": XK_D,
    "E": XK_E,
    "F": XK_F,
    "J": XK_J,
    "H": XK_H,
    "I": XK_I,
    "G": XK_G,
    "K": XK_K,
    "L": XK_L,
    "M": XK_M,
    "N": XK_N,
    "O": XK_O,
    "P": XK_P,
    "Q": XK_Q,
    "R": XK_R,
    "S": XK_S,
    "T": XK_T,
    "U": XK_U,
    "V": XK_V,
    "W": XK_W,
    "X": XK_X,
    "Y": XK_Y,
    "Z": XK_Z,

    "a": XK_a,
    "b": XK_b,
    "c": XK_c,
    "d": XK_d,
    "e": XK_e,
    "f": XK_f,
    "j": XK_j,
    "h": XK_h,
    "i": XK_i,
    "g": XK_g,
    "k": XK_k,
    "l": XK_l,
    "m": XK_m,
    "n": XK_n,
    "o": XK_o,
    "p": XK_p,
    "q": XK_q,
    "r": XK_r,
    "s": XK_s,
    "t": XK_t,
    "u": XK_u,
    "v": XK_v,
    "w": XK_w,
    "x": XK_x,
    "y": XK_y,
    "z": XK_z,

    "f1": XK_F1,
    "F1": XK_F1,
    "f2": XK_F2,
    "F2": XK_F2,
    "f3": XK_F3,
    "F3": XK_F3,
    "f4": XK_F4,
    "F4": XK_F4,
    "f5": XK_F5,
    "F5": XK_F5,
    "f6": XK_F6,
    "F6": XK_F6,
    "f7": XK_F7,
    "F7": XK_F7,
    "f8": XK_F8,
    "F8": XK_F8,
    "f9": XK_F9,
    "F9": XK_F9,
    "f10": XK_F10,
    "F10": XK_F10,
    "f11": XK_F11,
    "F11": XK_F11,
    "f12": XK_F12,
    "F12": XK_F12,
    "f13": XK_F13,
    "F13": XK_F13,
    "f14": XK_F14,
    "F14": XK_F14,

    "home": XK_Home,
    "Home": XK_Home,
    "pageup": XK_Page_Up,
    "page_up": XK_Page_Up,
    "pagedown": XK_Page_Down,
    "page_down": XK_Page_Down,
    "begin": XK_Begin,
    "Begin": XK_Begin,
    "end": XK_End,
    "End": XK_End,
    "left": XK_Left,
    "Left": XK_Left,
    "right": XK_Right,
    "Right": XK_Right,
    "Prior": XK_Prior,
    "prior": XK_Prior,
    "Next": XK_Next,
    "next": XK_Next,
    "up": XK_Up,
    "Up": XK_Up,
    "down": XK_Down,
    "Down": XK_Down,
    "tab": XK_Tab,
    "Tab": XK_Tab,
    "space": XK_space,
    "Space": XK_space,
    "return": XK_Return,
    "Return": XK_Return,
    "delete": XK_Delete,
    "Delete": XK_Delete,
    "backspace": XK_BackSpace,
    "Backspace": XK_BackSpace,
    "esc": XK_Escape,
    "Esc": XK_Escape,
    "ESC": XK_Escape,
    "shift_l": XK_Shift_L,
    "shift_r": XK_Shift_R,
    // "enter": XK_KP_Enter, // 小键盘的 enter 键
    "minus": XK_minus, // 减号 -
    "-": XK_minus, // 减号 -
    "equal": XK_equal, // 等号 =
    "=": XK_equal, // 等号 =
    "comma": XK_comma, // 逗号 ,
    ",": XK_comma, // 逗号 ,
    "period": XK_period, // 句号 .
    ".": XK_period, // 句号 .
    "semicolon": XK_semicolon, // 分号 ;
    ";": XK_semicolon,

    "grave": XK_grave, // 反引号 backtick quotes
    "`": XK_grave,

    "backslash": XK_backslash, // \
    "\\": XK_backslash,

    "bracketleft": XK_bracketleft, // [
    "[": XK_bracketleft,

    "bracketright": XK_bracketright, // ]
    "]": XK_bracketright,

    "apostrophe": XK_apostrophe, // ' 所有格符号, 单词内部的省略
    "'": XK_apostrophe,
  ]

  static let modifierMapping: [String: Int32] = [
    "shift": RimeModifier.kShiftMask,
    "Shift": RimeModifier.kShiftMask,
    "Control": RimeModifier.kControlMask,
    "control": RimeModifier.kControlMask,
    "ctrl": RimeModifier.kControlMask,
    "alt": RimeModifier.kAltMask,
    "Alt": RimeModifier.kAltMask,
    "command": RimeModifier.kSuperMask,
    "cmd": RimeModifier.kSuperMask,
    "capslock": RimeModifier.kLockMask,
    "cap": RimeModifier.kLockMask,
  ]
}

// MARK: - T9 拼音处理

public extension RimeContext {
  /// 获取拼音候选列表
  @MainActor
  func getPinyinCandidates() -> [String] {
    var pinyinList = [String]()
    guard let preedit = rimeContext?.composition.preedit, !preedit.isEmpty else { return pinyinList }

    // 删除音节
    var prePinypin = preedit.replacingOccurrences(of: " ", with: "")
    guard !prePinypin.isEmpty else { return pinyinList }

    // 删除开头非数字字符
    while !prePinypin.isEmpty {
      if let firstCharacter = prePinypin.first, firstCharacter.isNumber {
        break
      }
      prePinypin.removeFirst()
    }

    // 拼写区非数字情况，取最后一个音节的拼音列表
    if prePinypin.isEmpty {
      // 如果不包含 t9 拼音，则使用最后一个拼音音节
      if var lastPinyin = preedit.split(separator: " ").last {
        // 音节可能会丢失，这里需要删除非字母的字符
        // 注意: 小心死循环
        while !lastPinyin.isEmpty {
          if let first = lastPinyin.first, first.isLowercase {
            break
          }
          _ = lastPinyin.removeFirst()
        }

        if var firstT9Pinyin = pinyinToT9Mapping[String(lastPinyin)] {
          /// 遍历包含的全部拼音子串
          while !firstT9Pinyin.isEmpty {
            if let list = t9ToPinyinMapping[firstT9Pinyin] {
              pinyinList.append(contentsOf: list)
            }
            _ = firstT9Pinyin.popLast()
          }
        }
      }
    } else {
      // 使用 trie 结构判断 pre 的字符
      for count in 1 ... prePinypin.count {
        let sub = String(prePinypin.prefix(count))
        if !t9PinyinTrie.contains(sub) {
          break
        }
        if let subList = t9ToPinyinMapping[sub] {
          pinyinList.append(contentsOf: subList)
        }
      }
    }

    return pinyinList.sorted(by: {
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
