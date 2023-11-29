//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation
import UIKit

public struct HamsterKeyboardColor: Equatable {
  // 配置使用的名称
  public var schemaName: String

  // 方案名称(可读显示)
  public var name: String
  public var author: String

  public var backColor: UIColor // 键盘背景色 back_color
  public var buttonBackColor: UIColor // 按键背景色 button_back_color
  public var buttonPressedBackColor: UIColor // 按键按下时背景色 button_pressed_back_color
  public var buttonFrontColor: UIColor /// 按键文字颜色 button_front_color
  public var buttonPressedFrontColor: UIColor /// 按键按下时文字颜色 button_pressed_front_color
  public var buttonSwipeFrontColor: UIColor /// 按键划动文字颜色 button_swipe_front_color
  public var cornerRadius: CGFloat // 按键的圆角半径 corner_radius
  public var borderColor: UIColor // 边框颜色 border_color

  // MARK: 组字区域，对应键盘候选栏的用户输入字码

  public var textColor: UIColor // 编码行文字颜色 24位色值，16进制，BGR顺序: text_color
  // public var hilitedTextColor: UIColor // (暂未使用)编码高亮: hilited_text_color
  // public var hilitedBackColor: UIColor // (暂未使用)编码背景高亮: hilited_back_color

  // 候选栏颜色
  public var hilitedCandidateTextColor: UIColor // 首选文字颜色: hilited_candidate_text_color
  public var hilitedCandidateBackColor: UIColor // 首选背景颜色: hilited_candidate_back_color
  public var hilitedCommentTextColor: UIColor // 首选提示字母色: hilited_comment_text_color
  public var hilitedCandidateLabelColor: UIColor // 首选序号颜色 hilited_candidate_label_color

  public var candidateTextColor: UIColor // 次选文字色: candidate_text_color
  public var commentTextColor: UIColor // 次选提示色: comment_text_color
  public var labelColor: UIColor // 次选序号颜色 label_color

  public init(
    colorSchema schema: KeyboardColorSchema = KeyboardColorSchema(),
    userInterfaceStyle: UIUserInterfaceStyle
  ) {
    let foregroundColor = HamsterUIColor.shared.standardButtonForeground(for: userInterfaceStyle)
    let backgroundColor = HamsterUIColor.shared.standardButtonBackground(for: userInterfaceStyle)

    self.schemaName = schema.schemaName ?? ""
    self.name = schema.name ?? ""
    self.author = schema.author ?? ""
    self.backColor = schema.backColor?.bgrColor ?? HamsterUIColor.shared.clearInteractable
    self.buttonBackColor = schema.buttonBackColor?.bgrColor ?? backgroundColor
    self.buttonPressedBackColor = schema.buttonPressedBackColor?.bgrColor ?? HamsterUIColor.shared.standardDarkButtonBackground(for: userInterfaceStyle)
    self.buttonFrontColor = schema.buttonFrontColor?.bgrColor ?? foregroundColor
    self.buttonPressedFrontColor = schema.buttonPressedFrontColor?.bgrColor ?? foregroundColor
    self.buttonSwipeFrontColor = schema.buttonSwipeFrontColor?.bgrColor ?? .secondaryLabel
    self.cornerRadius = CGFloat(schema.cornerRadius ?? 5)
    self.borderColor = schema.borderColor?.bgrColor ?? .clear
    self.textColor = schema.textColor?.bgrColor ?? foregroundColor
    self.hilitedCandidateTextColor = schema.hilitedCandidateTextColor?.bgrColor ?? foregroundColor
    self.hilitedCandidateBackColor = schema.hilitedCandidateBackColor?.bgrColor ?? backgroundColor
    self.hilitedCommentTextColor = schema.hilitedCommentTextColor?.bgrColor ?? foregroundColor
    self.hilitedCandidateLabelColor = schema.hilitedCandidateLabelColor?.bgrColor ?? foregroundColor
    self.candidateTextColor = schema.candidateTextColor?.bgrColor ?? foregroundColor
    self.commentTextColor = schema.commentTextColor?.bgrColor ?? foregroundColor
    self.labelColor = schema.labelColor?.bgrColor ?? foregroundColor
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
