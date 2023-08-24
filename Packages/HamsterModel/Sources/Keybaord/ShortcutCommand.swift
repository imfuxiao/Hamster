//
//  ShortcutCommand.swift
//
//
//  Created by morse on 2023/8/24.
//

import Foundation

/// 键盘快捷指令
public enum ShortcutCommand: String, CaseIterable, Equatable, Identifiable {
  public var id: Self {
    self
  }

  case simplifiedTraditionalSwitch = "#繁简切换"
  case switchChineseOrEnglish = "#中英切换"
  case beginOfSentence = "#行首"
  case endOfSentence = "#行尾"
  case selectSecondary = "#次选上屏"
  case selectTertiary = "#三选上屏"
  case selectInputSchema = "#方案切换"
  case selectColorSchema = "#配色切换"
  case newLine = "#换行"
  case clearSpellingArea = "#清空拼写"
  case switchLastInputSchema = "#切换上个输入方案"
  case oneHandOnLeft = "#左手模式"
  case oneHandOnRight = "#右手模式"
  case rimeSwitcher = "#RimeSwitcher"
  case emojiKeyboard = "#emojiKeyboard"
  case symbolKeyboard = "#symbolKeyboard"
  case numberKeyboard = "#numberKeyboard"
  case none = "无"
}
