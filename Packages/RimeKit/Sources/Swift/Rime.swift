//
//  Rime.swift
//  Hamster
//
//  Created by morse on 14/5/2023.
//

import Foundation
import HamsterKit
import os
@_exported import RimeKitObjC

/// 对 librime 的二次封装
public class Rime {
  private let logger = Logger(
    subsystem: "com.ihsiao.apps.hamster.RimeKit",
    category: "Rime"
  )

  public static let shared: Rime = .init()

  typealias DeployCallbackFunction = () -> Void
  typealias ChangeCallbackFunction = (String) -> Void

  private var isFirstRun = true

  private var traits: IRimeTraits?

  /// rime session
  private var session: RimeSessionId = 0
  private var currentInputSchema: String = ""
  private var currentSimplifiedModeKey: String = ""
  private var currentSimplifiedModeValue: Bool = false
  private let rimeAPI = IRimeAPI()

  private var deployStartCallback: DeployCallbackFunction?
  private var deploySuccessCallback: DeployCallbackFunction?
  private var deployFailureCallback: DeployCallbackFunction?
  private var changeModeCallback: ChangeCallbackFunction?
  private var loadingSchemaCallback: ChangeCallbackFunction?

  private init() {}

  public func API() -> IRimeAPI {
    return rimeAPI
  }

  public static func createTraits(sharedSupportDir: String, userDataDir: String, models: [String] = []) -> IRimeTraits {
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

  public func setNotificationDelegate(_ delegate: IRimeNotificationDelegate) {
    rimeAPI.setNotificationDelegate(delegate)
  }

  public func setupRime(sharedSupportDir: String, userDataDir: String) {
    setupRime(Self.createTraits(sharedSupportDir: sharedSupportDir, userDataDir: userDataDir))
  }

  public func setupRime(_ traits: IRimeTraits) {
    if isFirstRun {
      rimeAPI.setup(traits)
      isFirstRun = false
    }
  }

  public func initialize(_ traits: IRimeTraits? = nil) {
    rimeAPI.initialize(traits)
  }

  public func start(_ traits: IRimeTraits? = nil, maintenance: Bool = false, fullCheck: Bool = false) {
    if let traits = traits {
      setupRime(traits)
    }

    self.traits = traits

    initialize(traits)

    if maintenance {
      rimeAPI.startMaintenance(fullCheck)
    }

    // session = rimeAPI.createSession()
  }

  public func deploy(_ traits: IRimeTraits? = nil) -> Bool {
    rimeAPI.deployerInitialize(traits)
    return rimeAPI.deploy()
  }

  public func isRunning() -> Bool {
    return session != 0
  }

  public func shutdown() {
    rimeAPI.destroySession(session)
    session = 0
    rimeAPI.finalize()
  }

  public func getSession() -> RimeSessionId {
    return session
  }

  public func createSession() {
    if !isRunning() {
      session = rimeAPI.createSession()
    }
  }

  public func restSession() {
    rimeAPI.destroySession(session)
    session = rimeAPI.createSession()
  }

  public func openSchema(schema: String) -> IRimeConfig {
    rimeAPI.openSchema(schema)
  }

  public func simplifiedChineseMode(key: String) -> Bool {
    return rimeAPI.getOption(session, andOption: key)
  }

  public func setSimplifiedChineseMode(key: String, value: Bool) {
    currentSimplifiedModeKey = key
    currentSimplifiedModeValue = value
    rimeAPI.setOption(session, andOption: key, andValue: value)
  }

  public func inputKey(_ key: String) -> Bool {
    createSession()
    return rimeAPI.processKey(key, andSession: session)
  }

  public func inputKeyCode(_ keycode: Int32, modifier: Int32 = 0) -> Bool {
    createSession()
    return rimeAPI.processKeyCode(keycode, modifier: modifier, andSession: session)
  }

  public func replaceInputKeys(_ inputKeys: String, startPos: Int, count: Int) -> Bool {
    return rimeAPI.replaceInputKeys(inputKeys, withStartPos: Int32(startPos), andCount: Int32(count), andSession: session)
  }

  public func candidateList() -> [CandidateWord] {
    let candidates = rimeAPI.getCandidateList(session)
    if candidates != nil {
      return candidates!.map {
        CandidateWord(text: $0.text, comment: $0.comment)
      }
    }
    return []
  }

  public func isAsciiMode() -> Bool {
    return rimeAPI.getOption(session, andOption: Self.asciiModeKey)
  }

  public func asciiMode(_ value: Bool) {
    rimeAPI.setOption(session, andOption: Self.asciiModeKey, andValue: value)
  }

  public func getCandidate(index: Int, count: Int) -> [IRimeCandidate] {
    rimeAPI.getCandidateWith(Int32(index), andCount: Int32(count), andSession: session) ?? []
  }

  public func selectCandidate(index: Int) -> Bool {
    return rimeAPI.selectCandidate(session, andIndex: Int32(index))
  }

  // index: 指candidates索引, 从0开始
  // count: 指每次获取的总数量
  // 注意: 举例每页10个候选字
  // 第一页: index = 0, count = 10
  // 第二页: index = 10, count = 10
  // 第二页: index = 20, count = 10
  // 以此类推
  public func candidateListWithIndex(index: Int, andCount count: Int) -> [CandidateWord] {
    let candidates = rimeAPI.getCandidateWith(
      Int32(index), andCount: Int32(count), andSession: session
    )
    if candidates != nil {
      return candidates!.map {
        CandidateWord(text: $0.text ?? "", comment: $0.comment ?? "")
      }
    }
    return []
  }

  public func getInputKeys() -> String {
    return rimeAPI.getInput(session)
  }

  public func getCommitText() -> String {
    return rimeAPI.getCommit(session)!
  }

  public func cleanComposition() {
    rimeAPI.cleanComposition(session)
  }

  public func status() -> IRimeStatus {
    return rimeAPI.getStatus(session)
  }

  public func context() -> IRimeContext {
    return rimeAPI.getContext(session)
  }

  public func getSchemas() -> [RimeSchema] {
    return rimeAPI.schemaList().map {
      RimeSchema(schemaId: $0.schemaId, schemaName: $0.schemaName)
    }
  }

  public func currentSchema() -> RimeSchema? {
    let status = rimeAPI.getStatus(session)!
    return RimeSchema(schemaId: status.schemaId, schemaName: status.schemaName)
  }

  public func setSchema(_ schemaId: String) -> Bool {
    createSession()
    currentInputSchema = schemaId
    return rimeAPI.selectSchema(session, andSchemaId: schemaId)
  }

  // 注意：用户目录必须存在 "default.coustom.yaml" 文件，调用才有效
  public func getAvailableRimeSchemas() -> [RimeSchema] {
    rimeAPI.getAvailableRimeSchemaList()
      .map { RimeSchema(schemaId: $0.schemaId, schemaName: $0.schemaName) }
  }

  public func getSelectedRimeSchema() -> [RimeSchema] {
    rimeAPI.getSelectedRimeSchemaList()
      .map { RimeSchema(schemaId: $0.schemaId, schemaName: $0.schemaName) }
  }

  public func selectRimeSchemas(_ schemas: [String]) -> Bool {
    rimeAPI.selectRimeSchemas(schemas)
  }

  public func getHotkeys() -> String {
    rimeAPI.getHotkeys()
  }

  public func getCaretPosition() -> Int {
    Int(rimeAPI.getCaretPosition(session))
  }

  public func setCaretPosition(_ position: Int) {
    rimeAPI.setCaretPosition(Int32(position), withSession: session)
  }

  public func getConfigFileValue(configFileName: String, key: String) -> String? {
    guard let config = rimeAPI.openUserConfig(configFileName) else { return nil }
    let value = config.getString(key)
    config.close()
    return value
  }

  public func getStateLabel(option: String, state: Bool, abbreviated: Bool) -> String {
    createSession()
    return rimeAPI.getStateLabelAbbreviated(session, optionName: option, state: state, abbreviated: abbreviated)
  }
}

extension Rime {
  private static let asciiModeKey = "ascii_mode"
  private static let simplifiedChineseKey = "simplification"
}
