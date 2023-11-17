//
//  ShortcutCommand.swift
//
//
//  Created by morse on 2023/8/24.
//

import Foundation

/// 键盘快捷指令
public enum ShortcutCommand: CaseIterable, Hashable, Identifiable, Codable {
  public static var allCases: [ShortcutCommand] = [
    ShortcutCommand.simplifiedTraditionalSwitch,
    ShortcutCommand.switchChineseOrEnglish,
    ShortcutCommand.beginOfSentence,
    ShortcutCommand.endOfSentence,
    ShortcutCommand.selectSecondary,
    ShortcutCommand.selectTertiary,
    ShortcutCommand.selectInputSchema,
    ShortcutCommand.selectColorSchema,
    ShortcutCommand.newLine,
    ShortcutCommand.clearSpellingArea,
    ShortcutCommand.switchLastInputSchema,
    ShortcutCommand.oneHandOnLeft,
    ShortcutCommand.oneHandOnRight,
    ShortcutCommand.rimeSwitcher,
    ShortcutCommand.emojiKeyboard,
    ShortcutCommand.symbolKeyboard,
    ShortcutCommand.numberKeyboard,
    ShortcutCommand.moveLeft,
    ShortcutCommand.moveRight,
    ShortcutCommand.cut,
    ShortcutCommand.copy,
    ShortcutCommand.paste,
    ShortcutCommand.none,
    ShortcutCommand.sendKeys(""),
    ShortcutCommand.dismissKeyboard,
  ]

  public var id: Self {
    self
  }

  case simplifiedTraditionalSwitch
  case switchChineseOrEnglish
  case beginOfSentence
  case endOfSentence
  case selectSecondary
  case selectTertiary
  case selectInputSchema
  case selectColorSchema
  case newLine
  case clearSpellingArea
  case switchLastInputSchema
  case oneHandOnLeft
  case oneHandOnRight
  case rimeSwitcher
  case emojiKeyboard
  case symbolKeyboard
  case numberKeyboard
  case moveLeft
  case moveRight
  case cut
  case copy
  case paste
  case none
  case sendKeys(String)
  case dismissKeyboard

  public init(rawValue: String) {
    switch rawValue {
    case "#简繁切换":
      self = .simplifiedTraditionalSwitch
    case "#中英切换":
      self = .switchChineseOrEnglish
    case "#行首":
      self = .beginOfSentence
    case "#行尾":
      self = .endOfSentence
    case "#次选上屏":
      self = .selectSecondary
    case "#三选上屏":
      self = .selectTertiary
    case "#方案切换":
      self = .selectInputSchema
    case "#配色切换":
      self = .selectColorSchema
    case "#换行":
      self = .newLine
    case "#重输":
      self = .clearSpellingArea
    case "#上个输入方案":
      self = .switchLastInputSchema
    case "#左手模式":
      self = .oneHandOnLeft
    case "#右手模式":
      self = .oneHandOnRight
    case "#RimeSwitcher":
      self = .rimeSwitcher
    case "#emojiKeyboard":
      self = .emojiKeyboard
    case "#symbolKeyboard":
      self = .symbolKeyboard
    case "#numberKeyboard":
      self = .numberKeyboard
    case "#左移":
      self = .moveLeft
    case "#右移":
      self = .moveRight
    case "#剪切":
      self = .cut
    case "#复制":
      self = .copy
    case "#粘贴":
      self = .paste
    case "无", "none":
      self = .none
    case "#关闭键盘":
      self = .dismissKeyboard
    default:
      guard let (key, value) = rawValue.attributeParse() else {
        self = .none
        return
      }
      switch key {
      case "sendKeys":
        self = .sendKeys(value)
      default:
        self = .none
      }
    }
  }

  public var rawValue: String {
    switch self {
    case .simplifiedTraditionalSwitch: return "#简繁切换"
    case .switchChineseOrEnglish: return "#中英切换"
    case .beginOfSentence: return "#行首"
    case .endOfSentence: return "#行尾"
    case .selectSecondary: return "#次选上屏"
    case .selectTertiary: return "#三选上屏"
    case .selectInputSchema: return "#方案切换"
    case .selectColorSchema: return "#配色切换"
    case .newLine: return "#换行"
    case .clearSpellingArea: return "#重输"
    case .switchLastInputSchema: return "#上个输入方案"
    case .oneHandOnLeft: return "#左手模式"
    case .oneHandOnRight: return "#右手模式"
    case .rimeSwitcher: return "#RimeSwitcher"
    case .emojiKeyboard: return "#emojiKeyboard"
    case .symbolKeyboard: return "#symbolKeyboard"
    case .numberKeyboard: return "#numberKeyboard"
    case .moveLeft: return "#左移"
    case .moveRight: return "#右移"
    case .cut: return "#剪切"
    case .copy: return "#复制"
    case .paste: return "#粘贴"
    case .none: return "无"
    case .sendKeys(let keys): return "sendKeys(\(keys))"
    case .dismissKeyboard: return "#关闭键盘"
    }
  }

  var text: String {
    switch self {
    case .simplifiedTraditionalSwitch:
      return "繁"
    case .switchChineseOrEnglish:
      return "英"
    case .beginOfSentence:
      return "⇤"
    case .endOfSentence:
      return "⇥"
    case .selectSecondary:
      return "次"
//    case .oneHandOnLeft:
//      return "左"
//    case .oneHandOnRight:
//      return "右"
    default:
      return ""
    }
  }
}
