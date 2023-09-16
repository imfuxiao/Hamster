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
}
