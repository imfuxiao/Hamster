import Foundation
import KeyboardKit

// 代码来源: KeyboardKit/StandardKeyboardBehavior
// 因类方法部分无法重写, 所以不能直接继承
class HamsterKeyboardBehavior: KeyboardBehavior {
  let appSettings: HamsterAppSettings
  let rimeEngine: RimeEngine
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
    appSettings: HamsterAppSettings,
    rimeEngine: RimeEngine,
    doubleTapThreshold: TimeInterval = 0.5,
    endSentenceThreshold: TimeInterval = 3.0,
    repeatGestureTimer: RepeatGestureTimer = .shared
  ) {
    self.keyboardContext = keyboardContext
    self.appSettings = appSettings
    self.rimeEngine = rimeEngine
    self.doubleTapThreshold = doubleTapThreshold
    self.endSentenceThreshold = endSentenceThreshold
    self.repeatGestureTimer = repeatGestureTimer
  }

  /// The keyboard context to use.
  public let keyboardContext: KeyboardContext

  /// The second threshold to detect a tap as a double tap.
  public let doubleTapThreshold: TimeInterval

  /// The second threshold during which a sentence can be auto-closed.
  public let endSentenceThreshold: TimeInterval

  /// A timer that is responsible for triggering a repeat gesture action.
  public let repeatGestureTimer: RepeatGestureTimer

  var lastShiftCheck = Date()
  var lastSpaceTap = Date()

  /**
   The range that the backspace key should delete when the
   key is long pressed.
   */
  public var backspaceRange: DeleteBackwardRange {
    let duration = repeatGestureTimer.duration ?? 0
    return duration > 3 ? .word : .character
  }

  /**
   The preferred keyboard type that should be applied when
   a certain gesture has been performed on an action.
   当对一个动作执行了某种手势后，应该应用的首选键盘类型。
   */
  public func preferredKeyboardType(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> KeyboardType {
    if shouldSwitchToCapsLock(after: gesture, on: action) { return .alphabetic(.capsLocked) }
    if appSettings.enableKeyboardAutomaticallyLowercase && action.isCharacterAction {
      if keyboardContext.keyboardType == .alphabetic(.uppercased) {
        return .alphabetic(.lowercased)
      }
    }
    return keyboardContext.keyboardType
  }

  /**
   Whether or not to end the currently typed sentence when
   a certain gesture has been performed on an action.
   */
  open func shouldEndSentence(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> Bool {
//    #if os(iOS) || os(tvOS)
//    guard gesture == .release, action == .space else { return false }
//    let proxy = keyboardContext.textDocumentProxy
//    let isNewWord = proxy.isCursorAtNewWord
//    let isNewSentence = proxy.isCursorAtNewSentence
//    let isClosable = (proxy.documentContextBeforeInput ?? "").hasSuffix("  ")
//    let isEndingTap = Date().timeIntervalSinceReferenceDate - lastSpaceTap.timeIntervalSinceReferenceDate < endSentenceThreshold
//    let shouldClose = isEndingTap && isNewWord && !isNewSentence && isClosable
//    lastSpaceTap = Date()
//    return shouldClose
//    #else
//    return false
//    #endif
    return false
  }

  /**
   Whether or not to switch to capslock when a gesture has
   been performed on an action.
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

   当对一个Action进行了某种手势后，是否切换到首选键盘类型。
   */
  open func shouldSwitchToPreferredKeyboardType(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> Bool {
    switch action {
    case .keyboardType(let type):
      return type.shouldSwitchToPreferredKeyboardType
    case .shift: return true
    default:
      // 检测键盘是否开启自动小写功能
      if appSettings.enableKeyboardAutomaticallyLowercase {
        return true
      }
      return false
    }
  }

  /**
   Whether or not to switch to the preferred keyboard type
   after the text document proxy text did change.
   在文本发生变化后应切换到首选的键盘类型
   注意: KeyboardInputViewController会在`textDidChange`函数调用此方法
   */
  public func shouldSwitchToPreferredKeyboardTypeAfterTextDidChange() -> Bool {
    return false
  }
}

private extension HamsterKeyboardBehavior {
  var isDoubleShiftTap: Bool {
    guard keyboardContext.keyboardType.isAlphabetic else { return false }
    let date = Date().timeIntervalSinceReferenceDate
    let lastDate = lastShiftCheck.timeIntervalSinceReferenceDate
    let isDoubleTap = (date - lastDate) < doubleTapThreshold
    lastShiftCheck = isDoubleTap ? Date().addingTimeInterval(-1) : Date()
    return isDoubleTap
  }
}

private extension KeyboardType {
  var shouldSwitchToPreferredKeyboardType: Bool {
    switch self {
    case .alphabetic(let state): return state.shouldSwitchToPreferredKeyboardType
    default: return false
    }
  }
}

private extension KeyboardCase {
  var shouldSwitchToPreferredKeyboardType: Bool {
    switch self {
    case .auto: return true
    default: return false
    }
  }
}
