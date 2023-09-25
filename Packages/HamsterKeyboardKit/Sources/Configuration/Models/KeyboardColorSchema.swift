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

  /// 次选文字色: candidate_text_color
  public var candidateTextColor: String?

  /// 次选提示文字颜色: comment_text_color
  public var commentTextColor: String?

  public init(schemaName: String? = nil, name: String? = nil, author: String? = nil, backColor: String? = nil, borderColor: String? = nil, textColor: String? = nil, hilitedTextColor: String? = nil, hilitedBackColor: String? = nil, hilitedCandidateTextColor: String? = nil, hilitedCandidateBackColor: String? = nil, hilitedCommentTextColor: String? = nil, candidateTextColor: String? = nil, commentTextColor: String? = nil) {
    self.schemaName = schemaName
    self.name = name
    self.author = author
    self.backColor = backColor
    self.borderColor = borderColor
    self.textColor = textColor
    self.hilitedTextColor = hilitedTextColor
    self.hilitedBackColor = hilitedBackColor
    self.hilitedCandidateTextColor = hilitedCandidateTextColor
    self.hilitedCandidateBackColor = hilitedCandidateBackColor
    self.hilitedCommentTextColor = hilitedCommentTextColor
    self.candidateTextColor = candidateTextColor
    self.commentTextColor = commentTextColor
  }
}

extension KeyboardColorSchema {
  enum CodingKeys: String, CodingKey {
    case name
    case author
    case schemaName
    case backColor = "back_color"
    case borderColor = "border_color"
    case textColor = "text_color"
    case hilitedTextColor = "hilited_text_color"
    case hilitedBackColor = "hilited_back_color"
    case hilitedCandidateTextColor = "hilited_candidate_text_color"
    case hilitedCandidateBackColor = "hilited_candidate_back_color"
    case hilitedCommentTextColor = "hilited_comment_text_color"
    case candidateTextColor = "candidate_text_color"
    case commentTextColor = "comment_text_color"
  }

  public static func < (lhs: KeyboardColorSchema, rhs: KeyboardColorSchema) -> Bool {
    (lhs.schemaName ?? "") < (rhs.schemaName ?? "")
  }
}
