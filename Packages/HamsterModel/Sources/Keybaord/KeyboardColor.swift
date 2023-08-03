//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation
import UIKit

public struct KeyboardColor: Equatable {
  // 配置使用的名称
  public var schemaName: String

  // 方案名称(可读显示)
  public var name: String
  public var author: String

  public var backColor: UIColor // 窗体背景色 back_color
  public var borderColor: UIColor // 边框颜色 border_color

  // MARK: 组字区域，对应键盘候选栏的用户输入字码

  public var textColor: UIColor // 编码行文字颜色 24位色值，16进制，BGR顺序: text_color
  public var hilitedTextColor: UIColor // 编码高亮: hilited_text_color
  public var hilitedBackColor: UIColor // 编码背景高亮: hilited_back_color

  // 候选栏颜色
  public var hilitedCandidateTextColor: UIColor // 首选文字颜色: hilited_candidate_text_color
  public var hilitedCandidateBackColor: UIColor // 首选背景颜色: hilited_candidate_back_color
  // hilited_candidate_label_color 首选序号颜色
  public var hilitedCommentTextColor: UIColor // 首选提示字母色: hilited_comment_text_color

  public var candidateTextColor: UIColor // 次选文字色: candidate_text_color
  public var commentTextColor: UIColor // 次选提示色: comment_text_color
  // label_color 次选序号颜色

  public init(name: String, colorSchema schema: KeyboardColorSchema) {
    self.schemaName = name
    self.name = schema.name
    self.author = schema.author ?? ""
    self.backColor = schema.backColor?.bgrColor ?? .clear
    self.borderColor = schema.borderColor?.bgrColor ?? .clear
    self.textColor = schema.textColor?.bgrColor ?? .label
    self.hilitedTextColor = schema.hilitedTextColor?.bgrColor ?? .label
    self.hilitedBackColor = schema.hilitedBackColor?.bgrColor ?? .clear
    self.hilitedCandidateTextColor = schema.hilitedCandidateTextColor?.bgrColor ?? .label
    self.hilitedCandidateBackColor = schema.hilitedCandidateBackColor?.bgrColor ?? .clear
    self.hilitedCommentTextColor = schema.hilitedCommentTextColor?.bgrColor ?? .secondaryLabel
    self.candidateTextColor = schema.candidateTextColor?.bgrColor ?? .label
    self.commentTextColor = schema.commentTextColor?.bgrColor ?? .label
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.schemaName == rhs.schemaName
  }
}

extension String {
  /// RIME配置文件中的颜色为: 24位色值，16进制，BGR顺序
  var bgrColor: UIColor? {
    if isEmpty || !hasPrefix("0x") {
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

    return UIColor(red: r, green: g, blue: b, alpha: alpha)
  }
}
