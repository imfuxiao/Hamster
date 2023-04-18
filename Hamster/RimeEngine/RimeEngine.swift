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
  typealias DeployCallbackFunction = () -> Void
  typealias ChangeCallbackFunction = (String) -> Void

  private let rimeAPI: IRimeAPI = .init()
  private var isFirstRunning = true
  private var traits: IRimeTraits?
  private var deployStartCallback: DeployCallbackFunction?
  private var deploySuccessCallback: DeployCallbackFunction?
  private var deployFailureCallback: DeployCallbackFunction?
  private var changeModeCallback: ChangeCallbackFunction?
  private var loadingSchemaCallback: ChangeCallbackFunction?

  /// rime session
  var session: RimeSessionId = 0

  /// 候选字上限
  var maxCandidateCount: Int32 = 100

  /// 用户输入键值
  @Published
  var userInputKey: String = ""

  /// 简繁中文模式
  @Published
  var simplifiedChineseMode: Bool = true

  /// 字母模式
  @Published
  var asciiMode: Bool = false

  /// Rime发布状态
//  @Published
//  var deployState: RimeDeployStatus = .none

  /// 候选字
  @Published
  var suggestions: [HamsterSuggestion] = []

  /// 当前颜色
  @Published
  var currentColorSchema = ColorSchema()
}

public extension RimeEngine {
  func createTraits(sharedSupportDir: String, userDataDir: String) -> IRimeTraits {
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
    return traits
  }

  private func setNotificationDelegate(_ delegate: IRimeNotificationDelegate) {
    rimeAPI.setNotificationDelegate(delegate)
  }

  func setupRime(sharedSupportDir: String, userDataDir: String) {
    setupRime(createTraits(sharedSupportDir: sharedSupportDir, userDataDir: userDataDir))
  }

  func setupRime(_ traits: IRimeTraits) {
    if isFirstRunning {
      isFirstRunning = false
      setNotificationDelegate(self)
      rimeAPI.setup(traits)
      self.traits = traits
    }
  }

  func startRime(_ traits: IRimeTraits? = nil, fullCheck: Bool = false) {
    rimeAPI.initialize(traits)
    rimeAPI.startMaintenance(fullCheck)
  }

  // 重新部署
  func deploy(fullCheck: Bool = true) {
    shutdownRime()
    startRime(traits, fullCheck: fullCheck)
  }

  func shutdownRime() {
    rimeAPI.cleanAllSession()
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.session = 0
    }
    rimeAPI.finalize()
  }

  func reset() {
    userInputKey = ""
    cleanComposition()
    suggestions = []
  }

  func rimeAlive() -> Bool {
    return session > 0 && rimeAPI.findSession(session)
  }

  func createSession() {
    if !rimeAlive() {
      session = rimeAPI.createSession()
    }
  }

  func restSession() {
    rimeAPI.cleanAllSession()
    session = rimeAPI.createSession()
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
    createSession()
    return !rimeAPI.getOption(session, andOption: simplifiedChineseKey)
  }

  func simplifiedChineseMode(_ value: Bool) -> Bool {
    createSession()
    return rimeAPI.setOption(session, andOption: simplifiedChineseKey, andValue: !value)
  }

  // context响应
  func contextReact() {
    let context = context()

    if context.composition != nil {
      userInputKey = context.composition.preedit
    }

    let candidates = rimeAPI.getCandidateWith(0, andCount: maxCandidateCount, andSession: session)!
    // 获取全部候选字
    // let candidates = rimeAPI.getCandidateList(session)!
    var result: [HamsterSuggestion] = []
    for (index, candidate) in candidates.enumerated() {
      var suggestion = HamsterSuggestion(
        text: candidate.text
      )
      suggestion.index = index
      suggestion.comment = candidate.comment
      suggestion.isAutocomplete = index == 0
      result.append(suggestion)
    }
    suggestions = result

    // TODO: 分页
//    if context.menu != nil {
//      Logger.shared.log.debug("rime context menu: \(context.menu.description)")
//      previousPage = context.menu.pageNo != 0
//      nextPage = !context.menu.isLastPage && context.menu.pageSize != 0
//
//      let candidates = context.menu.candidates
//      var result: [HamsterSuggestion] = []
//      for i in 0 ..< candidates!.count {
//        var suggestion = HamsterSuggestion(
//          text: candidates![i].text
//        )
//        suggestion.index = i + 1
//        suggestion.comment = candidates![i].comment
//        if i == 0 {
//          suggestion.isAutocomplete = true
//        }
//        result.append(suggestion)
//      }
//      suggestions = result
//    }
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
    let list = rimeAPI.schemaList()
    if list == nil {
      return []
    }
    return list!.map { Schema(schemaId: $0.schemaId, schemaName: $0.schemaName) }
  }

  func currentSchema() -> Schema? {
    let status = rimeAPI.getStatus(session)!
    return Schema(schemaId: status.schemaId, schemaName: status.schemaName)
  }

  func setSchema(_ schemaId: String) -> Bool {
    createSession()
    return rimeAPI.selectSchema(session, andSchameId: schemaId)
  }

  func colorSchema() -> [ColorSchema] {
    // open squirrel.yaml
    let cfg = rimeAPI.openConfig("squirrel")
    guard cfg != nil else {
      return []
    }

    defer {
      cfg?.close()
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

  func currentColorSchemaName() -> String {
    // open squirrel.yaml
    let config = rimeAPI.openConfig("squirrel")
    if config == nil {
      return ""
    }
    defer {
      config?.close()
    }
    return config!.getString("style/color_scheme")
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

public extension RimeEngine {
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
