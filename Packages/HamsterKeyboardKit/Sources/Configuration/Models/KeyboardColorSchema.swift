//
//  KeyboardColorScheme.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 键盘配色方案
/// 注意: 修改字段需要修改与字段匹配的 CodingKeys
public struct KeyboardColorSchema: Codable, Hashable, Comparable {
  /// 方案名称，应用配置具体使用的名称
  public var schemaName: String?

  /// 人类可读名称
  public var name: String?

  /// 作者
  public var author: String?

  /// 窗体背景色 back_color
  /// 对应键盘整体背景色
  public var backColor: String?

  /// 按键背景色 button_back_color
  public var buttonBackColor: String?

  /// 按键按下时背景色 button_pressed_back_color
  public var buttonPressedBackColor: String?

  /// 按键文字颜色 button_front_color
  public var buttonFrontColor: String?

  /// 按键按下时文字颜色 button_pressed_front_color
  public var buttonPressedFrontColor: String?

  /// 按键上划动文字颜色
  public var buttonSwipeFrontColor: String?

  /// 按键的圆角半径 corner_radius
  public var cornerRadius: Int?

  /// 边框颜色 border_color
  /// 对应键盘按键边框颜色
  public var borderColor: String?

  // MARK: 编码区域，对应键盘候选栏上方用户输入编码

  /// 编码区域 文字颜色 24位色值，16进制，BGR顺序: text_color
  /// 用于显示编码区域已确认文字颜色
  public var textColor: String?

  /// 编码高亮文字颜色: hilited_text_color
  /// 用于显示编码区未确认的编码颜色
  public var hilitedTextColor: String?

  /// 编码背景高亮: hilited_back_color
  /// 用于显示编码区未确认的编码背景色（只在编码部分显示背景色）
  public var hilitedBackColor: String?

  // MARK: 候选栏区域

  /// 首选文字颜色: hilited_candidate_text_color
  public var hilitedCandidateTextColor: String?

  /// 首选背景颜色: hilited_candidate_back_color
  public var hilitedCandidateBackColor: String?

  /// 首选提示文字颜色: hilited_comment_text_color
  public var hilitedCommentTextColor: String?

  /// 首选文字序号颜色 hilited_candidate_label_color
  public var hilitedCandidateLabelColor: String?

  /// 次选文字色: candidate_text_color
  public var candidateTextColor: String?

  /// 次选提示文字颜色: comment_text_color
  public var commentTextColor: String?

  /// 次选文字序号颜色 label_color
  public var labelColor: String?

  public init(schemaName: String? = nil, name: String? = nil, author: String? = nil, backColor: String? = nil, buttonBackColor: String? = nil, buttonPressedBackColor: String? = nil, buttonFrontColor: String? = nil, buttonPressedFrontColor: String? = nil, buttonSwipeFrontColor: String? = nil, cornerRadius: Int? = nil, borderColor: String? = nil, textColor: String? = nil, hilitedTextColor: String? = nil, hilitedBackColor: String? = nil, hilitedCandidateTextColor: String? = nil, hilitedCandidateBackColor: String? = nil, hilitedCommentTextColor: String? = nil, hilitedCandidateLabelColor: String? = nil, candidateTextColor: String? = nil, commentTextColor: String? = nil, labelColor: String? = nil) {
    self.schemaName = schemaName
    self.name = name
    self.author = author
    self.backColor = backColor
    self.buttonBackColor = buttonBackColor
    self.buttonPressedBackColor = buttonPressedBackColor
    self.buttonFrontColor = buttonFrontColor
    self.buttonPressedFrontColor = buttonPressedFrontColor
    self.buttonSwipeFrontColor = buttonSwipeFrontColor
    self.cornerRadius = cornerRadius
    self.borderColor = borderColor
    self.textColor = textColor
    self.hilitedTextColor = hilitedTextColor
    self.hilitedBackColor = hilitedBackColor
    self.hilitedCandidateTextColor = hilitedCandidateTextColor
    self.hilitedCandidateBackColor = hilitedCandidateBackColor
    self.hilitedCommentTextColor = hilitedCommentTextColor
    self.hilitedCandidateLabelColor = hilitedCandidateLabelColor
    self.candidateTextColor = candidateTextColor
    self.commentTextColor = commentTextColor
    self.labelColor = labelColor
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.schemaName = try container.decodeIfPresent(String.self, forKey: .schemaName)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.author = try container.decodeIfPresent(String.self, forKey: .author)
    self.backColor = try container.decodeIfPresent(String.self, forKey: .backColor)
    self.buttonBackColor = try container.decodeIfPresent(String.self, forKey: .buttonBackColor)
    self.buttonPressedBackColor = try container.decodeIfPresent(String.self, forKey: .buttonPressedBackColor)
    self.buttonFrontColor = try container.decodeIfPresent(String.self, forKey: .buttonFrontColor)
    self.buttonPressedFrontColor = try container.decodeIfPresent(String.self, forKey: .buttonPressedFrontColor)
    self.buttonSwipeFrontColor = try container.decodeIfPresent(String.self, forKey: .buttonSwipeFrontColor)
    self.cornerRadius = try container.decodeIfPresent(Int.self, forKey: .cornerRadius)
    self.borderColor = try container.decodeIfPresent(String.self, forKey: .borderColor)
    self.textColor = try container.decodeIfPresent(String.self, forKey: .textColor)
    self.hilitedTextColor = try container.decodeIfPresent(String.self, forKey: .hilitedTextColor)
    self.hilitedBackColor = try container.decodeIfPresent(String.self, forKey: .hilitedBackColor)
    self.hilitedCandidateTextColor = try container.decodeIfPresent(String.self, forKey: .hilitedCandidateTextColor)
    self.hilitedCandidateBackColor = try container.decodeIfPresent(String.self, forKey: .hilitedCandidateBackColor)
    self.hilitedCommentTextColor = try container.decodeIfPresent(String.self, forKey: .hilitedCommentTextColor)
    self.hilitedCandidateLabelColor = try container.decodeIfPresent(String.self, forKey: .hilitedCandidateLabelColor)
    self.candidateTextColor = try container.decodeIfPresent(String.self, forKey: .candidateTextColor)
    self.commentTextColor = try container.decodeIfPresent(String.self, forKey: .commentTextColor)
    self.labelColor = try container.decodeIfPresent(String.self, forKey: .labelColor)
  }

  enum CodingKeys: String, CodingKey {
    case schemaName
    case name
    case author
    case backColor = "back_color"
    case buttonBackColor = "button_back_color"
    case buttonPressedBackColor = "button_pressed_back_color"
    case buttonFrontColor = "button_front_color"
    case buttonPressedFrontColor = "button_pressed_front_color"
    case buttonSwipeFrontColor = "button_swipe_front_color"
    case cornerRadius = "corner_radius"
    case borderColor = "border_color"
    case textColor = "text_color"
    case hilitedTextColor
    case hilitedBackColor
    case hilitedCandidateTextColor = "hilited_candidate_text_color"
    case hilitedCandidateBackColor = "hilited_candidate_back_color"
    case hilitedCommentTextColor = "hilited_comment_text_color"
    case hilitedCandidateLabelColor = "hilited_candidate_label_color"
    case candidateTextColor = "candidate_text_color"
    case commentTextColor = "comment_text_color"
    case labelColor = "label_color"
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.schemaName, forKey: .schemaName)
    try container.encodeIfPresent(self.name, forKey: .name)
    try container.encodeIfPresent(self.author, forKey: .author)
    try container.encodeIfPresent(self.backColor, forKey: .backColor)
    try container.encodeIfPresent(self.buttonBackColor, forKey: .buttonBackColor)
    try container.encodeIfPresent(self.buttonPressedBackColor, forKey: .buttonPressedBackColor)
    try container.encodeIfPresent(self.buttonFrontColor, forKey: .buttonFrontColor)
    try container.encodeIfPresent(self.buttonPressedFrontColor, forKey: .buttonPressedFrontColor)
    try container.encodeIfPresent(self.buttonSwipeFrontColor, forKey: .buttonSwipeFrontColor)
    try container.encodeIfPresent(self.cornerRadius, forKey: .cornerRadius)
    try container.encodeIfPresent(self.borderColor, forKey: .borderColor)
    try container.encodeIfPresent(self.textColor, forKey: .textColor)
    try container.encodeIfPresent(self.hilitedTextColor, forKey: .hilitedTextColor)
    try container.encodeIfPresent(self.hilitedBackColor, forKey: .hilitedBackColor)
    try container.encodeIfPresent(self.hilitedCandidateTextColor, forKey: .hilitedCandidateTextColor)
    try container.encodeIfPresent(self.hilitedCandidateBackColor, forKey: .hilitedCandidateBackColor)
    try container.encodeIfPresent(self.hilitedCommentTextColor, forKey: .hilitedCommentTextColor)
    try container.encodeIfPresent(self.hilitedCandidateLabelColor, forKey: .hilitedCandidateLabelColor)
    try container.encodeIfPresent(self.candidateTextColor, forKey: .candidateTextColor)
    try container.encodeIfPresent(self.commentTextColor, forKey: .commentTextColor)
    try container.encodeIfPresent(self.labelColor, forKey: .labelColor)
  }
}

public extension KeyboardColorSchema {
  static func < (lhs: KeyboardColorSchema, rhs: KeyboardColorSchema) -> Bool {
    (lhs.schemaName ?? "") < (rhs.schemaName ?? "")
  }
}
