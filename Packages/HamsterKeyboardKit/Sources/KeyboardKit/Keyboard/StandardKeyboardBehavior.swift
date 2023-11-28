//
//  StandardKeyboardBehavior.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-28.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This class defines how a standard, Western keyboard behaves.

 该类定义了标准西式键盘的行为方式。

 You can inherit this class and override any open properties
 and functions to customize the standard behavior.

 您可以继承该类，并覆盖任何 open 属性和函数，以自定义标准行为。

 This class makes heavy use of standard logic that's defined
 elsewhere. However, having this makes it easy to change the
 actual behavior.

 该类大量使用了其他地方定义的标准逻辑。不过，有了它就可以轻松改变实际行为。

 `NOTE` This class handles `shift` a bit different, since it
 must handle double taps to switch to caps lock. Due to this,
 it must not switch to the preferred keyboard, but must also
 always try to do so. This behavior is tested to ensure that
 is is behaving as it should, although it may be hard to see
 why the code is the way it is.

 `NOTE`: 该类处理 `shift` 的方式有点不同，因为它必须处理双击以切换到大写锁定。
 正因为如此，它不能换到首选键盘，但也必须始终尝试这样做。
 我们会对该行为进行测试，以确保其行为符合预期，尽管可能很难理解代码为何如此。
 */
open class StandardKeyboardBehavior: KeyboardBehavior {
  // MARK: - Properties

  /// The keyboard context to use.
  ///
  /// 要使用的键盘上下文。
  public let keyboardContext: KeyboardContext

  /// The second threshold to detect a tap as a double tap.
  ///
  /// 检测是否为双击的阈值
  public let doubleTapThreshold: TimeInterval

  /// The second threshold during which a sentence can be auto-closed.
  ///
  /// 检测句子是否结束的阈值
  public let endSentenceThreshold: TimeInterval

  /// A timer that is responsible for triggering a repeat gesture action.
  ///
  /// 负责触发重复手势操作的计时器。
  public let repeatGestureTimer: RepeatGestureTimer

  /// 最后一次 shift 状态检测时间
  var lastShiftCheck = Date()

  /// 最后一次点击空格的时间
  var lastSpaceTap = Date()

  // MARK: - initialisations

  /**
    Create a standard keyboard behavior instance.

    - Parameters:
      - keyboardContext: The keyboard context to use.
      - doubleTapThreshold: The second threshold to detect a tap as a double tap, by default `0.5`.
      - endSentenceThreshold: The second threshold during which a sentence can be auto-closed, by default `3.0`.
      - repeatGestureTimer: A timer that is responsible for triggering a repeat gesture action, by default ``RepeatGestureTimer/shared``.
   */
  public init(
    keyboardContext: KeyboardContext,
    doubleTapThreshold: TimeInterval = 0.5,
    endSentenceThreshold: TimeInterval = 3.0,
    repeatGestureTimer: RepeatGestureTimer = .shared
  ) {
    self.keyboardContext = keyboardContext
    self.doubleTapThreshold = doubleTapThreshold
    self.endSentenceThreshold = endSentenceThreshold
    self.repeatGestureTimer = repeatGestureTimer
  }

  // MARK: - Fonctions

  /**
   The range that the backspace key should delete when the
   key is long pressed.

   长按删除键时应删除的范围。
   */
  public var backspaceRange: DeleteBackwardRange {
    let duration = repeatGestureTimer.duration ?? 0
    return duration > 3 ? .word : .character
  }

  /**
   The preferred keyboard type that should be applied when
   a certain gesture has been performed on an action.

   对某个操作执行特定手势时，应该使用的首选键盘类型。
   */
  public func preferredKeyboardType(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> KeyboardType {
    if shouldSwitchToCapsLock(after: gesture, on: action) {
      if keyboardContext.keyboardType.isAlphabetic {
        return .alphabetic(.capsLocked)
      }
      if keyboardContext.keyboardType.isChinesePrimaryKeyboard {
        return .chinese(.capsLocked)
      }

      if case .custom(let named, _) = keyboardContext.keyboardType {
        return .custom(named: named, case: .capsLocked)
      }
    }
//    if action.isAlternateQuotationDelimiter(for: keyboardContext) {
//      return .alphabetic(.lowercased)
//    }
    let should = shouldSwitchToPreferredKeyboardType(after: gesture, on: action)
    switch action {
    case .shift: return keyboardContext.keyboardType
    default: return should ? keyboardContext.preferredKeyboardType : keyboardContext.keyboardType
    }
  }

  /**
   Whether or not to end the currently typed sentence when
   a certain gesture has been performed on an action.

   当对某个操作执行特定手势时，是否结束当前键入的西文语句。
   */
  open func shouldEndSentence(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> Bool {
    guard gesture == .release, action == .space else { return false }
    let proxy = keyboardContext.textDocumentProxy
    let isNewWord = proxy.isCursorAtNewWord
    let isNewSentence = proxy.isCursorAtNewSentence
    let isClosable = (proxy.documentContextBeforeInput ?? "").hasSuffix("  ")
    let isEndingTap = Date().timeIntervalSinceReferenceDate - lastSpaceTap.timeIntervalSinceReferenceDate < endSentenceThreshold
    let shouldClose = isEndingTap && isNewWord && !isNewSentence && isClosable
    lastSpaceTap = Date()
    return shouldClose
  }

  /**
   Whether or not to switch to capslock when a gesture has
   been performed on an action.

   当对某个操作执行特定手势时，是否切换到大写锁定。
   */
  open func shouldSwitchToCapsLock(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> Bool {
    switch action {
    case .shift: return isDoubleShiftTap
    default: return false
    }
  }

  /**
   Whether or not to switch to the preferred keyboard type
   when a certain gesture has been performed on an action.

   当对某个操作执行特定特定手势时，是否切换到首选键盘类型。
   */
  open func shouldSwitchToPreferredKeyboardType(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> Bool {
    // if action.isAlternateQuotationDelimiter(for: context) { return true }
    switch action {
    case .keyboardType(let type): return type.shouldSwitchToPreferredKeyboardType
    case .shift: return true
    default: return gesture == .release && keyboardContext.keyboardType != keyboardContext.preferredKeyboardType
    }
  }

  /**
   Whether or not to switch to the preferred keyboard type
   after the text document proxy text did change.

   在 ``textDocumentProxy``的文本确实发生变化后，是否切换到首选键盘类型。
   */
  public func shouldSwitchToPreferredKeyboardTypeAfterTextDidChange() -> Bool {
    keyboardContext.keyboardType != keyboardContext.preferredKeyboardType
  }
}

private extension StandardKeyboardBehavior {
  var isDoubleShiftTap: Bool {
    // 不应判断是否是 Aliphabetic 键盘类型
//    guard keyboardContext.keyboardType.isAlphabetic else { return false }
    let date = Date().timeIntervalSinceReferenceDate
    let lastDate = lastShiftCheck.timeIntervalSinceReferenceDate
    let isDoubleTap = (date - lastDate) < doubleTapThreshold
    lastShiftCheck = isDoubleTap ? Date().addingTimeInterval(-1) : Date()
    return isDoubleTap
  }
}

private extension KeyboardAction {
  /// 是备用引号分隔符
  func isAlternateQuotationDelimiter(for context: KeyboardContext) -> Bool {
    switch self {
    case .character(let char): return char.isAlternateQuotationDelimiter(for: context)
    default: return false
    }
  }
}

private extension String {
  /// 是备用引号分隔符
  func isAlternateQuotationDelimiter(for context: KeyboardContext) -> Bool {
//    let locale = context.locale
//    return self == locale.alternateQuotationBeginDelimiter || self == locale.alternateQuotationEndDelimiter
    return false
  }
}

private extension KeyboardType {
  /// 应该切换到首选键盘类型
  var shouldSwitchToPreferredKeyboardType: Bool {
    switch self {
    case .alphabetic(let state): return state.shouldSwitchToPreferredKeyboardType
    default: return false
    }
  }
}

private extension KeyboardCase {
  /// 应切换到首选键盘类型
  var shouldSwitchToPreferredKeyboardType: Bool {
    switch self {
    case .auto: return true
    default: return false
    }
  }
}
