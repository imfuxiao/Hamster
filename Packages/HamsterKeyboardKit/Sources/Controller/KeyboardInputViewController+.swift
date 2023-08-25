//
//  KeyboardInputViewController+.swift
//
//
//  Created by morse on 2023/8/24.
//

import HamsterKit
import HamsterModel
import OSLog

// MARK: - 快捷指令处理

public extension KeyboardInputViewController {
  /// 尝试处理键入的快捷指令
  func tryHandleShortCommand(_ inputText: String) -> Bool {
    guard inputText.hasPrefix("#") else { return false }
    guard let command = ShortcutCommand(rawValue: inputText) else { return false }

    switch command {
    case .simplifiedTraditionalSwitch:
      self.switchTraditionalSimplifiedChinese()
    case .switchChineseOrEnglish:
      self.switchEnglishChinese()
    case .selectSecondary:
      self.selectSecondaryCandidate()
    case .selectTertiary:
      self.selectTertiaryCandidate()
    case .beginOfSentence:
      self.moveBeginOfSentence()
    case .endOfSentence:
      self.moveEndOfSentence()
    case .selectInputSchema:
      // TODO: 方案切换视图
      // self.appSettings.keyboardStatus = .switchInputSchema
      break
    case .newLine:
      self.textDocumentProxy.insertText("\r")
    case .clearSpellingArea:
      self.rimeContext.reset()
    case .selectColorSchema:
      // TODO: 颜色方案切换
      break
    case .switchLastInputSchema:
      switchLastInputSchema()
    case .oneHandOnLeft:
      // TODO: 左手单手模式切换
      break
    case .oneHandOnRight:
      // TODO: 右手单手模式切换
      break
    case .rimeSwitcher:
      rimeSwitcher()
    case .emojiKeyboard:
      // TODO: 切换 emoji 键盘
      break
    case .symbolKeyboard:
      // TODO: 切换符号键盘
      break
    case .numberKeyboard:
      // TODO: 切换数字键盘
      break
    default:
      return false
    }

    return true
  }

  func switchTraditionalSimplifiedChinese() {
    guard let simplifiedModeKey = hamsterConfiguration?.rime?.keyValueOfSwitchSimplifiedAndTraditional else {
      Logger.statistics.warning("cannot get keyValueOfSwitchSimplifiedAndTraditional")
      return
    }

    Task {
      await rimeContext.switchTraditionalSimplifiedChinese(simplifiedModeKey)
    }
  }

  func switchEnglishChinese() {
    //    中文模式下, 在已经有候选字的情况下, 切换英文模式.
    //
    //    情况1. 清空中文输入, 开始英文输入
    //    self.rimeEngine.reset()

    //    情况2. 候选栏字母上屏, 并开启英文输入
    var userInputKey = self.rimeContext.userInputKey
    if !userInputKey.isEmpty {
      userInputKey.removeAll(where: { $0 == " " })
      self.textDocumentProxy.insertText(userInputKey)
    }
    //    情况3. 首选候选字上屏, 并开启英文输入
    //    _ = self.candidateTextOnScreen()

    Task {
      await rimeContext.switchEnglishChinese()
    }
  }

  /// 首选候选字上屏
  func selectPrimaryCandidate() {
    Task {
      if let text = await rimeContext.selectCandidate(index: 0) {
        textDocumentProxy.insertText(text)
      }
    }
  }

  /// 第二位候选字上屏
  func selectSecondaryCandidate() {
    Task {
      if let text = await rimeContext.selectCandidate(index: 1) {
        textDocumentProxy.insertText(text)
      }
    }
  }

  /// 第三位候选字上屏
  func selectTertiaryCandidate() {
    Task {
      if let text = await rimeContext.selectCandidate(index: 2) {
        textDocumentProxy.insertText(text)
      }
    }
  }

  /// 光标移动句首
  func moveBeginOfSentence() {
    if let beforInput = self.textDocumentProxy.documentContextBeforeInput {
      if let lastIndex = beforInput.lastIndex(of: "\n") {
        let offset = beforInput[lastIndex ..< beforInput.endIndex].count - 1
        if offset > 0 {
          self.textDocumentProxy.adjustTextPosition(byCharacterOffset: -offset)
        }
      } else {
        self.textDocumentProxy.adjustTextPosition(byCharacterOffset: -beforInput.count)
      }
    }
  }

  /// 光标移动句尾
  func moveEndOfSentence() {
    let offset = self.textDocumentProxy.documentContextAfterInput?.count ?? 0
    if offset > 0 {
      self.textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
    }
  }

  /// 切换最近的一次输入方案
  func switchLastInputSchema() {
    Task {
      await rimeContext.switchLatestInputSchema()
    }
  }

  /// RIME Switcher
  func rimeSwitcher() {
    Task {
      await rimeContext.switcher()
    }
  }
}

// MARK: - 特殊功能按键处理

public extension KeyboardInputViewController {
  /// 特殊功能键处理
  func tryHandleSpecificCode(_ code: Int32) {
    switch code {
    case XK_Return:
      self.textDocumentProxy.insertText(.newline)
    case XK_BackSpace:
      let beforeInput = self.textDocumentProxy.documentContextBeforeInput ?? ""
      let afterInput = self.textDocumentProxy.documentContextAfterInput ?? ""
      // 光标可以居中的符号，成对删除
      let symbols = self.hamsterConfiguration?.Keyboard?.symbolsOfCursorBack ?? []
      if symbols.contains(String(beforeInput.suffix(1) + afterInput.prefix(1))) {
        self.textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
        self.textDocumentProxy.deleteBackward(times: 2)
      } else {
        self.textDocumentProxy.deleteBackward()
      }
    case XK_Tab:
      self.textDocumentProxy.insertText(.tab)
    case XK_space:
      self.textDocumentProxy.insertText(.space)
    default:
      break
    }
  }
}
