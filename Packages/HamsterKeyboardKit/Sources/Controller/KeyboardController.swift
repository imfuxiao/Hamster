//
//  KeyboardActionTrigger.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-01-23.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
  This protocol is used to make using the keyboard input view
  controller more abstract and available to more platforms.

  该协议用于使 InputViewController 使用更加抽象，并适用于更多平台。

  ``KeyboardInputViewController`` implements this protocol by
  calling itself, its document proxy, or its keyboard context.

 `` KeyboardInputViewController`` 通过调用自身、document proxy 或键盘 context 来实现此协议。

  The protocol currently defines what's currently required to
  trigger controller-specific actions within the library, but
  it may add functionality over time. Note that this protocol
  should only specify operations and not state.

  该协议目前定义了在程序库中触发控制器特定操作所需的内容，但随着时间的推移可能会增加功能。
  请注意，该协议只能指定操作，而不能指定状态。
  */
public protocol KeyboardController: AnyObject {
  /**
   Adjust the text input cursor position.

   调整文字输入光标位置。
   */
  func adjustTextPosition(byCharacterOffset: Int)

  /**
   Delete backwards.

   向后删除。
   */
  func deleteBackward()

  /**
   Delete backwards a certain number of times.

   向后删除一定次数。
   */
  func deleteBackward(times: Int)

  /**
   Dismiss the keyboard.

   关闭键盘。
   */
  func dismissKeyboard()

  /**
   Insert the provided autocomplete suggestion.

   插入所提供的自动完成建议。
   */
  func insertAutocompleteSuggestion(_ suggestion: AutocompleteSuggestion)

  /**
   Insert the provided text.

   插入提供的文本。
   */
  func insertText(_ text: String)

  /// 插入符号
  func insertSymbol(_ symbol: Symbol)

  /// 快捷指令
  func tryHandleShortcutCommand(_ command: ShortcutCommand)

  /**
   Perform an autocomplete operation.

   执行自动完成操作。
   */
  func performAutocomplete()

  /**
   Perform a keyboard-initiated dictation operation.

   执行键盘启动的听写操作。
   */
  // func performDictation()

  /**
   Perform a text context sync.

   执行文本上下文同步。
   */
  func performTextContextSync()

  /**
   Reset the current autocomplete state.

   重置当前的自动完成状态。
   */
  func resetAutocomplete()

  /**
   Select the next keyboard, if any.

   选择下一个键盘（如果有）。
   */
  func selectNextKeyboard()

  /**
   Select the next locale, if any.

   选择下一个语言环境（如果有）。
   */
  func selectNextLocale()

  /**
   Set a certain keyboard type.

   设置某种键盘类型。
   */
  func setKeyboardType(_ type: KeyboardType)

  /**
   设置键盘大小写
   */
  func setKeyboardCase(_ casing: KeyboardCase)

  /**
   Open a certain URL

   打开某个 URL
   */
  func openUrl(_ url: URL?)

  /// 重置输入法引擎
  func resetInputEngine()

  /**
   插入 RIME 引擎可识别的编码
   */
  func insertRimeKeyCode(_ keyCode: Int32)

  /**
   次选候选字
   */
  func selectSecondaryCandidate()

  /// 返回上一次的键盘
  func returnLastKeyboard()
}
