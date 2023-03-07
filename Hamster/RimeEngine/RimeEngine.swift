import Foundation
import LibrimeKit

/**
 候选文字
 */
public struct Candidate {
    let text: String
    let comment: String
}

public struct Schema {
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

public class RimeEngine: ObservableObject {
    @Published var userInputKey: String = ""
  
    public static let shared: RimeEngine = .init()
  
    private let rimeAPI: IRimeAPI = .init()
  
    private var session: RimeSessionId?
    
    public func setNotificationDelegate(_ delegate: IRimeNotificationDelegate) {
        rimeAPI.setNotificationDelegate(delegate)
    }
  
    // TODO: 方法重写, 将sessionId集成在RimeEngine中
    public func startRimeServer(_ traits: IRimeTraits) {
//        rimeAPI.setup(traits)
//        rimeAPI.start(traits, withFullCheck: false)
//        let session = rimeAPI.session()
        rimeAPI.startRimeServer(traits)
        //  [self setup:traits];
        //  [self start:traits WithFullCheck:false];
        //  [self session];
    }
  
    public func stopService() {
        rimeAPI.shutdown()
    }
  
    public func inputKey(_ key: String) -> Bool {
        return rimeAPI.processKey(key)
    }
  
    public func inputKey(_ key: Int32) -> Bool {
        return rimeAPI.processKeyCode(key)
    }
  
    public func candidateList() -> [Candidate] {
        let candidates = rimeAPI.getCandidateList()
        if candidates != nil {
            return candidates!.map {
                Candidate(text: $0.text, comment: $0.comment)
            }
        }
        return []
    }
  
    public func candidateListWithIndex(index: Int, andCount count: Int) -> [Candidate] {
        let candidates = rimeAPI.getCandidateWith(Int32(index), andCount: Int32(count))
        if candidates != nil {
            return candidates!.map {
                Candidate(text: $0.text, comment: $0.comment)
            }
        }
        return []
    }
  
    public func getInputKeys() -> String {
        return rimeAPI.getInput()
    }
  
    public func getCommitText() -> String {
        return rimeAPI.getCommit()!
    }
  
    public func rest() {
        userInputKey = ""
        cleanComposition()
    }
  
    public func cleanComposition() {
        rimeAPI.cleanComposition()
    }
  
    public func status() -> IRimeStatus {
        return rimeAPI.getStatus()
    }
  
    public func context() -> IRimeContext {
        return rimeAPI.getContext()
    }
  
    // 繁体模式
    public func traditionalMode(_ value: Bool) {
        rimeAPI.simplification(value)
    }
  
    public func isSimplifiedMode() -> Bool {
        return !rimeAPI.isSimplifiedMode()
    }
  
    // 字母模式
    public func asciiMode(_ value: Bool) {
        rimeAPI.asciiMode(value)
    }
  
    public func isAsciiMode() -> Bool {
        return rimeAPI.isAsciiMode()
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
    func start() throws {
        
        print(Bundle.main.bundleURL)
        
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
        
        setNotificationDelegate(HamsterRimeNotification())
        startRimeServer(traits)
        
        // TODO: 启动时判断繁体是否开启
        // rimeEngine.traditionalMode(appSettings.preferences.switchTraditionalChinese)
    }
}
