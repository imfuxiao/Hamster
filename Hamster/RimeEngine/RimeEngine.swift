import Foundation
import LibrimeKit

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
  var backColor: String = ""
  var borderColor: String = ""  // 边框颜色: border_color

  // 组字区域
  var textColor: String = ""  // 编码行文字颜色 24位色值，16进制，BGR顺序: text_color
  var hilitedTextColor: String = ""  // 编码高亮: hilited_text_color
  var hilitedBackColor: String = ""  // 编码背景高亮: hilited_back_color

  // 候选栏颜色
  var hilitedCandidateTextColor: String = ""  // 首选文字颜色: hilited_candidate_text_color
  var hilitedCandidateBackColor: String = ""  // 首选背景颜色: hilited_candidate_back_color
  // hilited_candidate_label_color 首选序号颜色
  var hilitedCommentTextColor: String = ""  // 首选提示字母色: hilited_comment_text_color

  var candidateTextColor: String = ""  // 次选文字色: candidate_text_color
  var commentTextColor: String = ""  // 次选提示色: comment_text_color
  // label_color 次选序号颜色
}

let asciiModeKey = "ascii_mode"
let simplifiedChineseKey = "simplification"

public class RimeEngine: ObservableObject, IRimeNotificationDelegate {
  private let rimeAPI: IRimeAPI = .init()
  private var session: RimeSessionId = 0

  @Published var userInputKey: String = ""

  public static let shared: RimeEngine = .init()
  private init() {}

  func setNotificationDelegate(_ delegate: IRimeNotificationDelegate) {
    rimeAPI.setNotificationDelegate(delegate)
  }

  func setup(_ traits: IRimeTraits) {
    rimeAPI.setup(traits)
  }

  func start(_ traits: IRimeTraits, fullCheck: Bool) {
    rimeAPI.start(traits, withFullCheck: fullCheck)
  }

  func stopRimeService() {
    rimeAPI.shutdown()
  }

  func rimeAlive() -> Bool {
    return session > 0 && rimeAPI.findSession(session)
  }

  func inputKey(_ key: String) -> Bool {
    return rimeAPI.processKey(key, andSession: session)
  }

  func inputKey(_ key: Int32) -> Bool {
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
      Int32(index), andCount: Int32(count), andSession: session)
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
    let config = rimeAPI.openConfig("squirrel")
    if config == nil {
      return []
    }

    // 获取配色名称
    let schemaNameList = config!.getMapValues("preset_color_schemes")
    return schemaNameList!.map { item in
      var schema = ColorSchema()
      schema.schemaName = item.key
      schema.name = config!.getString(item.path + "/name")
      schema.author = config!.getString(item.path + "/author")
      schema.backColor = config!.getString(item.path + "/back_color")
      schema.borderColor = config!.getString(item.path + "/border_color")
      schema.hilitedCandidateBackColor = config!.getString(
        item.path + "/hilited_candidate_back_color")
      schema.hilitedCandidateTextColor = config!.getString(
        item.path + "/hilited_candidate_text_color")
      schema.hilitedCommentTextColor = config!.getString(item.path + "/hilited_comment_text_color")
      schema.candidateTextColor = config!.getString(item.path + "/candidate_text_color")
      schema.commentTextColor = config!.getString(item.path + "/comment_text_color")
      schema.hilitedTextColor = config!.getString(item.path + "/hilited_text_color")
      schema.hilitedBackColor = config!.getString(item.path + "/hilited_back_color")
      schema.textColor = config!.getString(item.path + "/text_color")
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

extension RimeEngine {
  private func createTraits() throws -> IRimeTraits {
    #if DEBUG
      print("app bundle path: \(Bundle.main.bundleURL)")
    #endif

    try Self.syncShareSupportDirectory()
    try Self.syncAppGroupUserDataDirectory()

    let traits = IRimeTraits()
    traits.sharedDataDir = Self.sharedSupportDirectory.path
    traits.userDataDir = Self.userDataDirectory.path
    traits.distributionCodeName = "Hamster"
    traits.distributionName = "仓鼠"
    traits.distributionVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    // TODO: appName设置名字会产生异常
    // utilities.cc:365] Check failed: !IsGoogleLoggingInitialized() You called InitGoogleLogging() twice!
    // traits.appName = "rime.Hamster"

    return traits
  }

  public func launch() throws {
    let traits = try createTraits()
    setNotificationDelegate(self)
    rimeAPI.setup(traits)
    rimeAPI.start(traits, withFullCheck: false)
    session = rimeAPI.session()
  }

  public func deploy() throws {
    rimeAPI.shutdown()
    rimeAPI.start(nil, withFullCheck: true)
    session = rimeAPI.session()
  }

  public func rest() {
    userInputKey = ""
    cleanComposition()
  }

  public func isAsciiMode() -> Bool {
    return rimeAPI.getOption(session, andOption: asciiModeKey)
  }

  public func asciiMode(_ value: Bool) -> Bool {
    return rimeAPI.setOption(session, andOption: asciiModeKey, andValue: value)
  }

  public func isSimplifiedMode() -> Bool {
    return rimeAPI.getOption(session, andOption: simplifiedChineseKey)
  }

  public func simplifiedChineseMode(_ value: Bool) -> Bool {
    return rimeAPI.setOption(session, andOption: simplifiedChineseKey, andValue: value)
  }
}

// MARK: implementation IRimeNotificationDelegate

extension RimeEngine {
  public func onDelployStart() {
    print("HamsterRimeNotification: onDelployStart")
  }

  public func onDeploySuccess() {
    print("HamsterRimeNotification: onDeploySuccess")
  }

  public func onDeployFailure() {
    print("HamsterRimeNotification: onDeployFailure")
  }

  public func onChangeMode(_ mode: String) {
    print("HamsterRimeNotification: onChangeMode, mode: ", mode)
  }

  public func onLoadingSchema(_ schema: String) {
    print("HamsterRimeNotification: onLoadingSchema, schema: ", schema)
  }
}
