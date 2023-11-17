//
//  KeyboardInputViewController+.swift
//
//
//  Created by morse on 2023/8/24.
//

import HamsterKit
import OSLog
import UIKit

// MARK: - 快捷指令处理

public extension KeyboardInputViewController {
  /// 尝试处理键入的快捷指令
  func tryHandleShortcutCommand(_ command: ShortcutCommand) {
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
//    case .selectInputSchema:
    // TODO: 方案切换视图
    // self.appSettings.keyboardStatus = .switchInputSchema
//      break
    case .newLine:
      self.textDocumentProxy.insertText("\r")
    case .clearSpellingArea:
      self.rimeContext.reset()
//    case .selectColorSchema:
//      // TODO: 颜色方案切换
//      break
    case .switchLastInputSchema:
      self.switchLastInputSchema()
//    case .oneHandOnLeft:
//      // TODO: 左手单手模式切换
//      break
//    case .oneHandOnRight:
//      // TODO: 右手单手模式切换
//      break
    case .rimeSwitcher:
      self.rimeSwitcher()
//    case .emojiKeyboard:
//      // TODO: 切换 emoji 键盘
//      break
//    case .symbolKeyboard:
//      // TODO: 切换符号键盘
//      break
//    case .numberKeyboard:
//      // TODO: 切换数字键盘
//      break
    case .moveLeft:
      adjustTextPosition(byCharacterOffset: -1)
    case .moveRight:
      adjustTextPosition(byCharacterOffset: 1)
    case .cut:
      self.cutCommand()
    case .copy:
      self.copyCommand()
    case .paste:
      self.pasteCommand()
    case .sendKeys(let keys):
      self.sendKeys(keys)
    case .dismissKeyboard:
      self.dismissKeyboard()
    default:
      break
    }
  }

  func switchTraditionalSimplifiedChinese() {
    guard let simplifiedModeKey = keyboardContext.hamsterConfiguration?.rime?.keyValueOfSwitchSimplifiedAndTraditional else {
      Logger.statistics.warning("cannot get keyValueOfSwitchSimplifiedAndTraditional")
      return
    }

    rimeContext.switchTraditionalSimplifiedChinese(simplifiedModeKey)
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

    rimeContext.switchEnglishChinese()
  }

  /// 首选候选字上屏
  func selectPrimaryCandidate() {
    rimeContext.selectCandidate(index: 0)
  }

  /// 第二位候选字上屏
  func selectSecondaryCandidate() {
    rimeContext.selectCandidate(index: 1)
  }

  /// 第三位候选字上屏
  func selectTertiaryCandidate() {
    rimeContext.selectCandidate(index: 2)
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
    rimeContext.switchLatestInputSchema()
  }

  /// RIME Switcher
  func rimeSwitcher() {
    rimeContext.switcher()
  }

  /// 剪切命令
  func cutCommand() {
    if let selectText = textDocumentProxy.selectedText {
      UIPasteboard.general.string = selectText
      textDocumentProxy.deleteBackward()
    }
  }

  /// 复制命令
  func copyCommand() {
    if let selectText = textDocumentProxy.selectedText {
      UIPasteboard.general.string = selectText
    }
  }

  /// 粘贴命令
  func pasteCommand() {
    if let text = UIPasteboard.general.string {
      textDocumentProxy.insertText(text)
    }
  }

  /// 向 RIME 引擎发送指定键
  func sendKeys(_ keys: String) {
    var keyList = keys.split(separator: "+").map { String($0) }
    guard let inputKey = keyList.popLast() else { return }
    guard let inputKeyCode = RimeContext.keyCodeMapping[inputKey] else {
      Logger.statistics.warning("inputKey: \(inputKey) not found mapping keyCode")
      return
    }
    let modifier = keyList.compactMap { RimeContext.modifierMapping[$0] }.reduce(0) { $0 | $1 }
    let handled = rimeContext.tryHandleInputCode(inputKeyCode, modifier: modifier)
    Logger.statistics.info("send keys: \(keys) to rime handled \(handled)")
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
      let symbols = self.keyboardContext.hamsterConfiguration?.keyboard?.symbolsOfCursorBack ?? []
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
