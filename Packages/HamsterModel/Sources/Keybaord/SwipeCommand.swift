//
//  SwipeCommand.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 划动命令
public enum SwipeCommand: String, CaseIterable, Equatable, Identifiable {
  public var id: Self {
    self
  }

  case switchSimplifiedOrTraditional = "#繁简切换"
  case switchChineseOrEnglish = "#中英切换"
  case beginOfSentence = "#行首"
  case endOfSentence = "#行尾"
  case selectSecondary = "#次选上屏"
  case selectThirdly = "#三选上屏"
  case switchInputSchema = "#方案切换"
  case switchColorSchema = "#配色切换"
  case newLine = "#换行"
  case deleteInputKey = "#清屏"
  case switchLastInputSchema = "#切换上个输入方案"
  case oneHandOnLeft = "#左手模式"
  case oneHandOnRight = "#右手模式"
  case rimeSwitcher = "#RimeSwitcher"
  case emojiKeyboard = "#emojiKeyboard"
  case symbolKeyboard = "#symbolKeyboard"
  case none = "无"

  var text: String {
    switch self {
    case .switchSimplifiedOrTraditional:
      return "繁"
    case .switchChineseOrEnglish:
      return "英"
    case .beginOfSentence:
      return "⇤"
    case .endOfSentence:
      return "⇥"
    case .selectSecondary:
      return "次"
    case .oneHandOnLeft:
      return "左"
    case .oneHandOnRight:
      return "右"
    default:
      return ""
    }
  }
}
