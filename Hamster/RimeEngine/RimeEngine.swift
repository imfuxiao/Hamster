import Foundation
import LibrimeKit
import SwiftUI

/// UI候选字
public struct HamsterSuggestion: Identifiable {
  /**
   Create a suggestion with completely custom properties.

   - Parameters:
   - text: The text that should be sent to the text document proxy.
   - title: The text that should be presented to the user, by default `text`.
   - isAutocomplete: Whether or not this is an autocompleting suggestion, by default `false`.
   - isUnknown: Whether or not this is an unknown suggestion, by default `false`.
   - subtitle: An optional subtitle that can complete the `title`, by default `nil`.
   - additionalInfo: An optional dictionary that can contain additional info, by default `empty`.
   */
  public init(
    text: String,
    title: String? = nil,
    isAutocomplete: Bool = false,
    isUnknown: Bool = false,
    subtitle: String? = nil,
    additionalInfo: [String: Any] = [:]
  ) {
    self.text = text
    self.title = title ?? text
    self.isAutocomplete = isAutocomplete
    self.isUnknown = isUnknown
    self.subtitle = subtitle
    self.additionalInfo = additionalInfo
  }

  public var id = UUID()

  /**
   The text that should be sent to the text document proxy.
   */
  public var text: String

  /**
   The text that should be presented to the user.
   */
  public var title: String

  /**
   Whether or not this is an autocompleting suggestion.

   These suggestions are typically shown in white, rounded
   squares when presented in an iOS system keyboard.
   */
  public var isAutocomplete: Bool

  /**
   Whether or not this is an unknown suggestion.

   These suggestions are typically surrounded by quotation
   marks when presented in an iOS system keyboard.
   */
  public var isUnknown: Bool

  /**
   An optional subtitle that can complete the `title`.
   */
  public var subtitle: String?

  /**
   An optional dictionary that can contain additional info.
   */
  public var additionalInfo: [String: Any]
}

extension HamsterSuggestion {
  var index: Int {
    get {
      if let comment = additionalInfo["index"] {
        return comment as! Int
      }
      return 0
    }
    set {
      additionalInfo["index"] = newValue
    }
  }

  var comment: String? {
    get {
      if let comment = additionalInfo["comment"] {
        return comment as? String
      }
      return nil
    }
    set {
      additionalInfo["comment"] = newValue
    }
  }
}

/// 候选文字
public struct Candidate {
  let text: String
  let comment: String
}

public struct Schema: Identifiable, Equatable {
  public let id = UUID()
  let schemaId: String
  let schemaName: String
}

public struct ColorSchema: Identifiable, Equatable {
  public let id = UUID()

  var schemaName: String = ""
  var name: String = ""
  var author: String = ""

  // 窗体背景色
  var backColor: Color?
  var borderColor: Color? // 边框颜色: border_color

  // 组字区域
  var textColor: Color? // 编码行文字颜色 24位色值，16进制，BGR顺序: text_color
  var hilitedTextColor: Color? // 编码高亮: hilited_text_color
  var hilitedBackColor: Color? // 编码背景高亮: hilited_back_color

  // 候选栏颜色
  var hilitedCandidateTextColor: Color? // 首选文字颜色: hilited_candidate_text_color
  var hilitedCandidateBackColor: Color? // 首选背景颜色: hilited_candidate_back_color
  // hilited_candidate_label_color 首选序号颜色
  var hilitedCommentTextColor: Color? // 首选提示字母色: hilited_comment_text_color

  var candidateTextColor: Color? // 次选文字色: candidate_text_color
  var commentTextColor: Color? // 次选提示色: comment_text_color
  // label_color 次选序号颜色
}

let asciiModeKey = "ascii_mode"
let simplifiedChineseKey = "simplification"

enum RimeDeployStatus {
  case Begin
  case Success
  case Failure
  case none
}

public class RimeEngine: ObservableObject, IRimeNotificationDelegate {
  private let rimeAPI: IRimeAPI = .init()
  private var session: RimeSessionId = 0

  /// 用户输入键值
  @Published
  var userInputKey: String = ""

  @Published
  var simplifiedChineseMode: Bool = true

  @Published
  var asciiMode: Bool = false

  @Published
  var deployState: RimeDeployStatus = .none

  /// 上一页
  @Published
  var previousPage: Bool = false

  /// 下一页
  @Published
  var nextPage: Bool = false

  @Published
  var suggestions: [HamsterSuggestion] = []

  public static let shared: RimeEngine = .init()
  private init() {}

  private func setNotificationDelegate(_ delegate: IRimeNotificationDelegate) {
    rimeAPI.setNotificationDelegate(delegate)
  }

  private func setup(_ traits: IRimeTraits) {
    rimeAPI.setup(traits)
  }

  private func start(_ traits: IRimeTraits, fullCheck: Bool) {
    rimeAPI.start(traits, withFullCheck: fullCheck)
  }

  func inputKey(_ key: String) -> Bool {
    if !rimeAlive() {
      session = rimeAPI.session()
    }
    return rimeAPI.processKey(key, andSession: session)
  }

  func inputKeyCode(_ key: Int32) -> Bool {
    if !rimeAlive() {
      session = rimeAPI.session()
    }
    return rimeAPI.processKeyCode(key, andSession: session)
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

  public func cleanComposition() {
    rimeAPI.cleanComposition(session)
  }

  public func status() -> IRimeStatus {
    return rimeAPI.getStatus(session)
  }

  public func context() -> IRimeContext {
    return rimeAPI.getContext(session)
  }

  public func getSchemas() -> [Schema] {
    let list = rimeAPI.schemaList()
    if list == nil {
      return []
    }
    return list!.map { Schema(schemaId: $0.schemaId, schemaName: $0.schemaName) }
  }

  // 通过getStatus()获取当前schema
  //    public func currentSchema() -> Schema? {
  //        let rimeSchema = rimeAPI.currentSchema(session)
  //        if rimeSchema == nil {
  //            return nil
  //        }
  //        return Schema(schemaId: rimeSchema!.schemaId, schemaName: rimeSchema!.schemaName)
  //    }

  public func setSchema(_ schemaId: String) -> Bool {
    rimeAPI.selectSchema(session, andSchameId: schemaId)
  }

  public func colorSchema() -> [ColorSchema] {
    // open squirrel.yaml
    let cfg = rimeAPI.openConfig("squirrel")
    guard cfg != nil else {
      return []
    }

    let config = cfg!
    // 获取配色名称
    let schemaNameList = config.getMapValues("preset_color_schemes")
    return schemaNameList!.map { item in
      var schema = ColorSchema()
      schema.schemaName = item.key
      schema.name = config.getString(item.path + "/name")
      schema.author = config.getString(item.path + "/author")
      schema.backColor = config.getString(item.path + "/back_color").bgrColor
      schema.borderColor = config.getString(item.path + "/border_color").bgrColor
      schema.hilitedCandidateBackColor = config.getString(item.path + "/hilited_candidate_back_color").bgrColor
      schema.hilitedCandidateTextColor = config.getString(item.path + "/hilited_candidate_text_color").bgrColor
      schema.hilitedCommentTextColor = config.getString(item.path + "/hilited_comment_text_color").bgrColor
      schema.candidateTextColor = config.getString(item.path + "/candidate_text_color").bgrColor
      schema.commentTextColor = config.getString(item.path + "/comment_text_color").bgrColor
      schema.hilitedTextColor = config.getString(item.path + "/hilited_text_color").bgrColor
      schema.hilitedBackColor = config.getString(item.path + "/hilited_back_color").bgrColor
      schema.textColor = config.getString(item.path + "/text_color").bgrColor
      return schema
    }
  }

  public func currentColorSchemaName() -> String {
    // open squirrel.yaml
    let config = rimeAPI.openConfig("squirrel")
    if config == nil {
      return ""
    }
    return config!.getString("style/color_scheme")
  }
}

public extension RimeEngine {
  func createTraits(sharedSupportDir: String, userDataDir: String) -> IRimeTraits {
    let traits = IRimeTraits()
    traits.sharedDataDir = sharedSupportDir
    traits.userDataDir = userDataDir
    traits.distributionCodeName = "Hamster"
    traits.distributionName = "仓鼠"
    traits.distributionVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    // TODO: appName设置名字会产生异常
    // utilities.cc:365] Check failed: !IsGoogleLoggingInitialized() You called InitGoogleLogging() twice!
    // traits.appName = "rime.Hamster"

    return traits
  }

  func deployInstallRime(sharedSupportDir: String, userDataDir: String) {
    deployInstallRime(createTraits(sharedSupportDir: sharedSupportDir, userDataDir: userDataDir))
  }

  func deployInstallRime(_ traits: IRimeTraits) {
    rimeAPI.deployerInitialize(traits)
  }

  func setupRime(sharedSupportDir: String, userDataDir: String) {
    setupRime(createTraits(sharedSupportDir: sharedSupportDir, userDataDir: userDataDir))
  }

  func setupRime(_ traits: IRimeTraits) {
    setNotificationDelegate(self)
    rimeAPI.setup(traits)
  }

  func startRime(fullCheck: Bool = false) {
    rimeAPI.start(nil, withFullCheck: fullCheck)
    session = rimeAPI.session()
    simplifiedChineseMode = status().isSimplified
  }

  func deploy(fullCheck: Bool = true) {
    DispatchQueue.main.async { [weak self] in
      self?.rimeAPI.shutdown()
      self?.rimeAPI.start(nil, withFullCheck: true)
      self?.session = self?.rimeAPI.session() ?? 0
    }
  }

  func shutdownRime() {
    rimeAPI.shutdown()
  }

  func rest() {
    DispatchQueue.main.async { [weak self] in
      self?.userInputKey = ""
      self?.cleanComposition()
      self?.suggestions = []
      self?.nextPage = false
      self?.previousPage = false
    }
  }

  func rimeAlive() -> Bool {
    return session > 0 && rimeAPI.findSession(session)
  }

  func restSession() {
    rimeAPI.cleanAllSession()
    session = rimeAPI.session()
  }

  func openSchema(schema: String) -> IRimeConfig {
    rimeAPI.openSchema(schema)
  }

  func isAsciiMode() -> Bool {
    return asciiMode
//    return rimeAPI.getOption(session, andOption: asciiModeKey)
  }

  func asciiMode(_ value: Bool) -> Bool {
    asciiMode = value
    return asciiMode
//    return rimeAPI.setOption(session, andOption: asciiModeKey, andValue: value)
  }

  func isSimplifiedMode() -> Bool {
    return !rimeAPI.getOption(session, andOption: simplifiedChineseKey)
  }

  func simplifiedChineseMode(_ value: Bool) -> Bool {
    return rimeAPI.setOption(session, andOption: simplifiedChineseKey, andValue: !value)
  }

  // context响应
  func contextReact() {
    let context = context()

    if context.composition != nil {
      userInputKey = context.composition.preedit
    }

    if context.menu != nil {
      previousPage = context.menu.pageNo != 0
      nextPage = !context.menu.isLastPage && context.menu.pageSize != 0

      let candidates = context.menu.candidates
      var result: [HamsterSuggestion] = []
      for i in 0 ..< candidates!.count {
        var suggestion = HamsterSuggestion(
          text: candidates![i].text
        )
        suggestion.index = i + 1
        suggestion.comment = candidates![i].comment
        if i == 0 {
          suggestion.isAutocomplete = true
        }
        result.append(suggestion)
      }
      suggestions = result
    }
  }
}

// MARK: implementation IRimeNotificationDelegate

public extension RimeEngine {
  func onDelployStart() {
    Logger.shared.log.info("HamsterRimeNotification: onDelployStart")
    DispatchQueue.main.async { [weak self] in
      self?.deployState = .Begin
    }
  }

  func onDeploySuccess() {
    Logger.shared.log.info("HamsterRimeNotification: onDeploySuccess")
    let inputSchema = HamsterAppSettings.shared.rimeInputSchema
    if !inputSchema.isEmpty {
      Logger.shared.log.info("rime set schema: \(inputSchema)")
      // 输入方案切换
      if setSchema(inputSchema) {
        Logger.shared.log.error("rime engine set schema \(inputSchema) error")
      }

      // 设置分页数量
      setRimePageSize(inputSchema)
    }

    if rimeAlive() {
      session = rimeAPI.session()
    }

    DispatchQueue.main.async { [weak self] in
      Logger.shared.log.info("session \(String(self?.session ?? 0))")
      self?.deployState = .Success
    }
  }

  func onDeployFailure() {
    Logger.shared.log.info("HamsterRimeNotification: onDeployFailure")
    DispatchQueue.main.async { [weak self] in
      self?.deployState = .Failure
    }
  }

  func onChangeMode(_ mode: String) {
    Logger.shared.log.info("HamsterRimeNotification: onChangeMode, mode: \(mode)")
  }

  func onLoadingSchema(_ schema: String) {
    Logger.shared.log.info("HamsterRimeNotification: onLoadingSchema, schema: \(schema)")
    setRimePageSize(schema)
  }

  func setRimePageSize(_ schema: String) {
    // 设置分页数量
    Logger.shared.log.info("setting schema: \(schema) menu/page_size: \(HamsterAppSettings.shared.rimePageSize)")
    let config = openSchema(schema: schema)
    if config.setInt("menu/page_size", value: Int32(HamsterAppSettings.shared.rimePageSize)) {
      Logger.shared.log.error("edit menu/page_size result error")
    }
  }
}
