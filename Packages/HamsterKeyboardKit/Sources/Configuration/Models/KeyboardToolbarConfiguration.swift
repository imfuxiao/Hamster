//
//  KeyboardToolbarConfiguration.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 键盘工具栏偏好
/// 工具栏包含候选栏，如果关闭工具栏，则候选文字不会显示
public struct KeyboardToolbarConfiguration: Codable, Hashable {
  /// 工具栏
  public var enableToolbar: Bool?

  /// 工具栏高度
  public var heightOfToolbar: Int?

  /// 显示应用图标按钮
  public var displayAppIconButton: Bool?

  /// 显示键盘收起键
  public var displayKeyboardDismissButton: Bool?

  /// 编码区高度
  /// 编码区：指待上屏区域
  public var heightOfCodingArea: Int?

  /// 编码区字体大小
  public var codingAreaFontSize: Int?

  /// 候选字字体大小
  /// 指候选列表中的字体大小
  public var candidateWordFontSize: Int?

  /// 候选备注字体大小
  public var candidateCommentFontSize: Int?

  /// 显示候选文字索引
  public var displayIndexOfCandidateWord: Bool?

  /// 显示候选文字 Comment 信息
  public var displayCommentOfCandidateWord: Bool?

  public init(enableToolbar: Bool? = nil, heightOfToolbar: Int? = nil, displayAppIconButton: Bool? = nil, displayKeyboardDismissButton: Bool? = nil, heightOfCodingArea: Int? = nil, codingAreaFontSize: Int? = nil, candidateWordFontSize: Int? = nil, candidateCommentFontSize: Int? = nil, displayIndexOfCandidateWord: Bool? = nil, displayCommentOfCandidateWord: Bool? = nil) {
    self.enableToolbar = enableToolbar
    self.heightOfToolbar = heightOfToolbar
    self.displayAppIconButton = displayAppIconButton
    self.displayKeyboardDismissButton = displayKeyboardDismissButton
    self.heightOfCodingArea = heightOfCodingArea
    self.codingAreaFontSize = codingAreaFontSize
    self.candidateWordFontSize = candidateWordFontSize
    self.candidateCommentFontSize = candidateCommentFontSize
    self.displayIndexOfCandidateWord = displayIndexOfCandidateWord
    self.displayCommentOfCandidateWord = displayCommentOfCandidateWord
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.enableToolbar = try container.decodeIfPresent(Bool.self, forKey: .enableToolbar)
    self.heightOfToolbar = try container.decodeIfPresent(Int.self, forKey: .heightOfToolbar)
    self.displayAppIconButton = try container.decodeIfPresent(Bool.self, forKey: .displayAppIconButton)
    self.displayKeyboardDismissButton = try container.decodeIfPresent(Bool.self, forKey: .displayKeyboardDismissButton)
    self.heightOfCodingArea = try container.decodeIfPresent(Int.self, forKey: .heightOfCodingArea)
    self.codingAreaFontSize = try container.decodeIfPresent(Int.self, forKey: .codingAreaFontSize)
    self.candidateWordFontSize = try container.decodeIfPresent(Int.self, forKey: .candidateWordFontSize)
    self.candidateCommentFontSize = try container.decodeIfPresent(Int.self, forKey: .candidateCommentFontSize)
    self.displayIndexOfCandidateWord = try container.decodeIfPresent(Bool.self, forKey: .displayIndexOfCandidateWord)
    self.displayCommentOfCandidateWord = try container.decodeIfPresent(Bool.self, forKey: .displayCommentOfCandidateWord)
  }

  enum CodingKeys: CodingKey {
    case enableToolbar
    case heightOfToolbar
    case displayAppIconButton
    case displayKeyboardDismissButton
    case heightOfCodingArea
    case codingAreaFontSize
    case candidateWordFontSize
    case candidateCommentFontSize
    case displayIndexOfCandidateWord
    case displayCommentOfCandidateWord
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.enableToolbar, forKey: .enableToolbar)
    try container.encodeIfPresent(self.heightOfToolbar, forKey: .heightOfToolbar)
    try container.encodeIfPresent(self.displayAppIconButton, forKey: .displayAppIconButton)
    try container.encodeIfPresent(self.displayKeyboardDismissButton, forKey: .displayKeyboardDismissButton)
    try container.encodeIfPresent(self.heightOfCodingArea, forKey: .heightOfCodingArea)
    try container.encodeIfPresent(self.codingAreaFontSize, forKey: .codingAreaFontSize)
    try container.encodeIfPresent(self.candidateWordFontSize, forKey: .candidateWordFontSize)
    try container.encodeIfPresent(self.candidateCommentFontSize, forKey: .candidateCommentFontSize)
    try container.encodeIfPresent(self.displayIndexOfCandidateWord, forKey: .displayIndexOfCandidateWord)
    try container.encodeIfPresent(self.displayCommentOfCandidateWord, forKey: .displayCommentOfCandidateWord)
  }
}
