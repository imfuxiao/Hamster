import Foundation
import LibrimeKit

/**
 候选文字
 */
public struct Candidate {
    let text: String
    let comment: String
}

public struct Schema: Identifiable, Equatable {
    public let id = UUID()
    let schemaId: String
    let schemaName: String
}

public struct ColorSchema: Identifiable {
    public let id = UUID()
    
    var schemaName: String = ""
    var name: String = ""
  
    // 候选栏颜色
    var backColor: String = "" // 候选栏背景色: back_color
    var borderColor: String = "" // 边框颜色: border_color
    var hilitedCandidateBackColor: String = "" // 首选背景颜色: hilited_candidate_back_color
    var hilitedCandidateTextColor: String = "" // 首选文字颜色: hilited_candidate_text_color
    var hilitedCommenttextcolor: String = "" // 首选提示字母色: hilited_comment_text_color
    var candidateTextColor: String = "" // 次选文字色: candidate_text_color
    var commentTextColor: String = "" // 次选提示字母色: comment_text_color
  
    // 需要开启内嵌编码
    var hilitedTextColor: String = "" // 编码高亮: hilited_text_color
    var hilitedBackColor: String = "" // 编码背景高亮: hilited_back_color
    var textColor: String = "" // 编码行文字颜色 24位色值，16进制，BGR顺序: text_color
}

let asciiModeKey = "ascii_mode"
let simplifiedChineseKey = "simplification"

public class RimeEngine: ObservableObject {
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
        return rimeAPI.findSession(session)
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
        let candidates = rimeAPI.getCandidateWith(Int32(index), andCount: Int32(count), andSession: session)
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
            schema.backColor = config!.getString(item.path + "/back_color")
            schema.borderColor = config!.getString(item.path + "/border_color")
            schema.hilitedCandidateBackColor = config!.getString(item.path + "/hilited_candidate_back_color")
            schema.hilitedCandidateTextColor = config!.getString(item.path + "/hilited_candidate_text_color")
            schema.hilitedCommenttextcolor = config!.getString(item.path + "/hilited_comment_text_color")
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

    func launch() throws {
        let traits = try createTraits()
        
        setNotificationDelegate(HamsterRimeNotification())
        rimeAPI.setup(traits)
        rimeAPI.start(traits, withFullCheck: false)
        session = rimeAPI.session()
        
        // TODO: 启动时判断繁体是否开启
        // rimeEngine.traditionalMode(appSettings.preferences.switchTraditionalChinese)
    }
    
    func setup() throws {
        let traits = try createTraits()
        setNotificationDelegate(HamsterRimeNotification())
        rimeAPI.setup(traits)
    }

    func rest() {
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
