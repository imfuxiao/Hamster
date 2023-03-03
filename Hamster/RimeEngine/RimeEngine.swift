import Foundation
import LibrimeKit
import SwiftUI

/**
 候选文字
 */
public struct Candidate {
  let text: String
  let comment: String
}

public struct ColorSchema {
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
  
  public func setNotificationDelegate(_ delegate: IRimeNotificationDelegate) {
    rimeAPI.setNotificationDelegate(delegate)
  }
  
  public func startService(_ traits: IRimeTraits) {
    rimeAPI.startRimeServer(traits)
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

extension String {
  // bgr顺序: 24位色值，16进制，BGR顺序
  var bgrColor: Color? {
    if !hasPrefix("0x") {
      return nil
    }
    
    // 提取 0x 后数字
    let beginIndex = index(startIndex, offsetBy: 2)
    let hexColorStr = String(self[beginIndex...])
    let scanner = Scanner(string: hexColorStr)
    
    var hexValue: UInt64 = .zero
    var r: CGFloat = .zero
    var g: CGFloat = .zero
    var b: CGFloat = .zero
    var alpha = CGFloat(0xff) / 255
    
    switch count {
    case 8:
      // sscanf(string.UTF8String, "0x%02x%02x%02x", &b, &g, &r);
      if scanner.scanHexInt64(&hexValue) {
        r = CGFloat(hexValue & 0xff) / 255
        g = CGFloat((hexValue & 0xff00) >> 8) / 255
        b = CGFloat((hexValue & 0xff0000) >> 16) / 255
      }
    case 10:
      // sscanf(string.UTF8String, "0x%02x%02x%02x%02x", &a, &b, &g, &r);
      if scanner.scanHexInt64(&hexValue) {
        r = CGFloat(hexValue & 0xff) / 255
        g = CGFloat((hexValue & 0xff00) >> 8) / 255
        b = CGFloat((hexValue & 0xff0000) >> 16) / 255
        alpha = CGFloat((hexValue & 0xff000000) >> 24) / 255
      }
    default:
      return nil
    }
    return Color(
      red: r,
      green: g,
      blue: b,
      opacity: alpha
    )
  }
}

extension IRimeContext {
  func getCandidates() -> [Candidate] {
    candidates.map {
      Candidate(text: $0.text, comment: $0.comment)
    }
  }
}
