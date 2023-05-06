//
//  Rime.swift
//  Hamster
//
//  Created by morse on 14/5/2023.
//

import Foundation
import LibrimeKit

/// 对librime的二次封装
class Rime: IRimeNotificationDelegate {
  typealias DeployCallbackFunction = () -> Void
  typealias ChangeCallbackFunction = (String) -> Void

  /// 单例
  public static let shared: Rime = .init()

  private init() {}

  private var isFirstRun = true

  private var traits: IRimeTraits?

  /// rime session
  private var session: RimeSessionId = 0
  private var currentInputSchema: String = ""
  private let rimeAPI = IRimeAPI()

  private var deployStartCallback: DeployCallbackFunction?
  private var deploySuccessCallback: DeployCallbackFunction?
  private var deployFailureCallback: DeployCallbackFunction?
  private var changeModeCallback: ChangeCallbackFunction?
  private var loadingSchemaCallback: ChangeCallbackFunction?

  func API() -> IRimeAPI {
    return rimeAPI
  }

  static func createTraits(sharedSupportDir: String, userDataDir: String, models: [String] = []) -> IRimeTraits {
    let traits = IRimeTraits()
    traits.sharedDataDir = sharedSupportDir
    traits.userDataDir = userDataDir
    traits.distributionCodeName = "Hamster"
    traits.distributionName = "Hamster"
    traits.distributionVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    // appName设置名字后, 在重复调用rimeAPI.setup()方法时会产生异常
    // utilities.cc:365] Check failed: !IsGoogleLoggingInitialized() You called InitGoogleLogging() twice!
    // 所以需要判断是否首次运行
    traits.appName = "rime.Hamster"
    if !models.isEmpty {
      traits.modules = models
//    traits.modules = ["core", "dict", "gears", "levers", "lua"]
//    traits.modules = ["core", "dict", "gears", "lua"]
    }
    return traits
  }

  private func setNotificationDelegate(_ delegate: IRimeNotificationDelegate) {
    rimeAPI.setNotificationDelegate(delegate)
  }

  func setupRime(sharedSupportDir: String, userDataDir: String) {
    setupRime(Self.createTraits(sharedSupportDir: sharedSupportDir, userDataDir: userDataDir))
  }

  func setupRime(_ traits: IRimeTraits) {
    if isFirstRun {
      setNotificationDelegate(self)
      rimeAPI.setup(traits)
      isFirstRun = false
    }
  }

  func initialize(_ traits: IRimeTraits? = nil) {
    rimeAPI.initialize(traits)
  }

  func start(_ traits: IRimeTraits? = nil, maintenance: Bool = false, fullCheck: Bool = false) {
    if let traits = traits {
      setupRime(traits)
    }

    self.traits = traits

    initialize(traits)

    if maintenance {
      rimeAPI.startMaintenance(fullCheck)
    }

    session = rimeAPI.createSession()
  }

  func deploy(_ traits: IRimeTraits? = nil) -> Bool {
    rimeAPI.deployerInitialize(traits)
    return rimeAPI.deploy()
  }

  func isRunning() -> Bool {
    return session != 0
  }

  func shutdown() {
    rimeAPI.destroySession(session)
    session = 0
    rimeAPI.finalize()
  }

  func getSession() -> RimeSessionId {
    return session
  }

  func createSession() {
    if !isRunning() {
      initialize(traits)
      session = rimeAPI.createSession()
      if !currentInputSchema.isEmpty {
        _ = setSchema(currentInputSchema)
      }
    }
  }

  func restSession() {
    rimeAPI.destroySession(session)
    session = rimeAPI.createSession()
  }

  func openSchema(schema: String) -> IRimeConfig {
    rimeAPI.openSchema(schema)
  }

  func isSimplifiedMode() -> Bool {
    createSession()
    return !rimeAPI.getOption(session, andOption: simplifiedChineseKey)
  }

  func simplifiedChineseMode(_ value: Bool) -> Bool {
    createSession()
    return rimeAPI.setOption(session, andOption: simplifiedChineseKey, andValue: !value)
  }

  func inputKey(_ key: String) -> Bool {
    createSession()
    return rimeAPI.processKey(key, andSession: session)
  }

  func inputKeyCode(_ keycode: Int32, modifier: Int32 = 0) -> Bool {
    createSession()
    return rimeAPI.processKeyCode(keycode, modifier: modifier, andSession: session)
  }

  func candidateList() -> [Candidate] {
    let candidates = rimeAPI.getCandidateList(session)
    if candidates != nil {
      return candidates!.map {
        Candidate(text: $0.text, comment: $0.comment)
      }
    }
    return []
  }

//  func isAsciiMode() -> Bool {
//    return rimeAPI.getOption(session, andOption: asciiModeKey)
//  }
//
//  func asciiMode(_ value: Bool) -> Bool {
//    return rimeAPI.setOption(session, andOption: asciiModeKey, andValue: value)
//  }

  func getCandidate(index: Int, count: Int) -> [IRimeCandidate] {
    rimeAPI.getCandidateWith(Int32(index), andCount: Int32(count), andSession: session) ?? []
  }

  func selectCandidate(index: Int) -> Bool {
    return rimeAPI.selectCandidate(session, andIndex: Int32(index))
  }

  // index: 指candidates索引, 从1开始
  // count: 指每次获取的总数量
  // 注意: 举例每页10个候选字
  // 第一页: index = 1, count = 10
  // 第二页: index = 11, count = 10
  // 第二页: index = 21, count = 10
  // 以此类推
  func candidateListWithIndex(index: Int, andCount count: Int) -> [Candidate] {
    let candidates = rimeAPI.getCandidateWith(
      Int32(index), andCount: Int32(count), andSession: session
    )
    if candidates != nil {
      return candidates!.map {
        Candidate(text: $0.text, comment: $0.comment)
      }
    }
    return []
  }

  func getInputKeys() -> String {
    return rimeAPI.getInput(session)
  }

  func getCommitText() -> String {
    return rimeAPI.getCommit(session)!
  }

  func cleanComposition() {
    rimeAPI.cleanComposition(session)
  }

  func status() -> IRimeStatus {
    return rimeAPI.getStatus(session)
  }

  func context() -> IRimeContext {
    return rimeAPI.getContext(session)
  }

  func getSchemas() -> [Schema] {
    return rimeAPI.schemaList().map {
      Schema(schemaId: $0.schemaId, schemaName: $0.schemaName)
    }
  }

  func currentSchema() -> Schema? {
    let status = rimeAPI.getStatus(session)!
    return Schema(schemaId: status.schemaId, schemaName: status.schemaName)
  }

  func setSchema(_ schemaId: String) -> Bool {
    createSession()
    currentInputSchema = schemaId
    return rimeAPI.selectSchema(session, andSchemaId: schemaId)
  }

  func colorSchema(_ useSquirrel: Bool = true) -> [ColorSchema] {
    // open squirrel.yaml or hamster.yaml
    let cfg = useSquirrel ? rimeAPI.openConfig("squirrel") : rimeAPI.openConfig("hamster")
    guard cfg != nil else {
      return []
    }

    let config = cfg!
    // 获取配色名称
    let schemaNameList = config.getMapValues("preset_color_schemes")
    let list = schemaNameList!.map { item in
      var schema = ColorSchema()
      schema.schemaName = item.key
      schema.name = config.getString(item.path + "/name")
      schema.author = config.getString(item.path + "/author")
      schema.backColor = config.getString(item.path + "/back_color")
      schema.borderColor = config.getString(item.path + "/border_color")
      schema.hilitedCandidateBackColor = config.getString(item.path + "/hilited_candidate_back_color")
      schema.hilitedCandidateTextColor = config.getString(item.path + "/hilited_candidate_text_color")
      schema.hilitedCommentTextColor = config.getString(item.path + "/hilited_comment_text_color")
      schema.candidateTextColor = config.getString(item.path + "/candidate_text_color")
      schema.commentTextColor = config.getString(item.path + "/comment_text_color")
      schema.hilitedTextColor = config.getString(item.path + "/hilited_text_color")
      schema.hilitedBackColor = config.getString(item.path + "/hilited_back_color")
      schema.textColor = config.getString(item.path + "/text_color")
      return schema
    }

    cfg?.close()
    return list
  }

  func currentColorSchemaName(_ useSquirrel: Bool = true) -> String {
    // open squirrel.yaml or hamster.yaml
    let config = useSquirrel ? rimeAPI.openConfig("squirrel") : rimeAPI.openConfig("hamster")
    if config == nil {
      return ""
    }
    let currentColorSchemaName = config!.getString("style/color_scheme") ?? ""
    config?.close()
    return currentColorSchemaName
  }

  // 注意：用户目录必须存在 "default.coustom.yaml" 文件，调用才有效
  func getAvailableRimeSchemas() -> [Schema] {
    rimeAPI.getAvailableRimeSchemaList()
      .map { Schema(schemaId: $0.schemaId, schemaName: $0.schemaName) }
  }

  func getSelectedRimeSchema() -> [Schema] {
    rimeAPI.getSelectedRimeSchemaList()
      .map { Schema(schemaId: $0.schemaId, schemaName: $0.schemaName) }
  }
  
  
  func getHotkeys() -> String {
    rimeAPI.getHotkeys()
  }

  // MARK: 通知回调函数

  func setDeployStartCallback(callback: @escaping () -> Void) {
    deployStartCallback = callback
  }

  func setDeploySuccessCallback(callback: @escaping () -> Void) {
    deploySuccessCallback = callback
  }

  func setDeployFailureCallback(callback: @escaping () -> Void) {
    deployFailureCallback = callback
  }

  func setChangeModeCallback(callback: @escaping (String) -> Void) {
    changeModeCallback = callback
  }

  func setLoadingSchemaCallback(callback: @escaping (String) -> Void) {
    loadingSchemaCallback = callback
  }
}

// MARK: implementation IRimeNotificationDelegate

extension Rime {
  func onDeployStart() {
    Logger.shared.log.info("HamsterRimeNotification: onDeployStart")
//    DispatchQueue.main.async { [weak self] in
//      if let self = self {
//        self.deployState = .Begin
//      }
//    }
    deployStartCallback?()
  }

  func onDeploySuccess() {
    Logger.shared.log.info("HamsterRimeNotification: onDeploySuccess")
    deploySuccessCallback?()
  }

  func onDeployFailure() {
    Logger.shared.log.info("HamsterRimeNotification: onDeployFailure")
    deployFailureCallback?()
  }

  func onChangeMode(_ mode: String) {
    Logger.shared.log.info("HamsterRimeNotification: onChangeMode, mode: \(mode)")
    changeModeCallback?(mode)
  }

  func onLoadingSchema(_ schema: String) {
    Logger.shared.log.info("HamsterRimeNotification: onLoadingSchema, schema: \(schema)")
    loadingSchemaCallback?(schema)
  }
}
