//
//  Rime+Model.swift
//  Hamster
//
//  Created by morse on 14/5/2023.
//

import Foundation

/// UI候选字
public struct HamsterSuggestion: Identifiable, Equatable {
  public static func == (lhs: HamsterSuggestion, rhs: HamsterSuggestion) -> Bool {
    lhs.id == rhs.id
  }

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

public struct Schema: Identifiable, Equatable, Hashable, Comparable, Codable {
  public static func < (lhs: Schema, rhs: Schema) -> Bool {
    lhs.schemaId <= rhs.schemaId
  }

  public static func == (lhs: Schema, rhs: Schema) -> Bool {
    return lhs.schemaId == rhs.schemaId
  }

  public var hashValue: Int {
    schemaId.hashValue
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(schemaId)
  }

  public var id = UUID()
  let schemaId: String
  let schemaName: String
}

public struct ColorSchema: Identifiable, Equatable, Codable {
  public var id = UUID()

  var schemaName: String = ""
  var name: String = ""
  var author: String = ""

  var backColor: String = "" // 窗体背景色 back_color
  var borderColor: String = "" // 边框颜色 border_color

  // MARK: 组字区域，对应键盘候选栏的用户输入字码

  var textColor: String = "" // 编码行文字颜色 24位色值，16进制，BGR顺序: text_color
  var hilitedTextColor: String = "" // 编码高亮: hilited_text_color
  var hilitedBackColor: String = "" // 编码背景高亮: hilited_back_color

  // 候选栏颜色
  var hilitedCandidateTextColor: String = "" // 首选文字颜色: hilited_candidate_text_color
  var hilitedCandidateBackColor: String = "" // 首选背景颜色: hilited_candidate_back_color
  // hilited_candidate_label_color 首选序号颜色
  var hilitedCommentTextColor: String = "" // 首选提示字母色: hilited_comment_text_color

  var candidateTextColor: String = "" // 次选文字色: candidate_text_color
  var commentTextColor: String = "" // 次选提示色: comment_text_color
  // label_color 次选序号颜色
}

let asciiModeKey = "ascii_mode"
let simplifiedChineseKey = "simplification"
