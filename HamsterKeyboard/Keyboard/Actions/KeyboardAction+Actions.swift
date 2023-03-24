import Foundation
import KeyboardKit

extension KeyboardAction {
  // 用于注入 HamsterInputViewController 并兼容 KeyboardKit
  typealias HamsterGestureAction = (HamsterKeyboardViewController?) -> GestureAction

  func hamsterStanderAction(for gesture: KeyboardGesture) -> HamsterGestureAction? {
    switch gesture {
    case .doubleTap: return hamsterStandardDoubleTapAction
    case .longPress: return hamsterStandardLongPressAction
    case .press: return hamsterStandardPressAction
    case .release: return hamsterStandardReleaseAction
    case .repeatPress: return hamsterStandardRepeatAction
    }
  }

  /**
   The action that by default should be triggered when the
   action is double tapped.
   */
  var hamsterStandardDoubleTapAction: HamsterGestureAction? { nil }

  /**
   The action that by default should be triggered when the
   action is long pressed.
   */
  var hamsterStandardLongPressAction: HamsterGestureAction? {
    switch self {
    case .backspace: return hamsterStandardPressAction
    case .space: return { _ in { _ in } }
    default: return nil
    }
  }

  /**
   The action that by default should be triggered when the
   action is pressed.
   */
  var hamsterStandardPressAction: HamsterGestureAction? {
    switch self {
    case .backspace:
      return { hamsterInputViewController in
        guard let rimeEngine = hamsterInputViewController?.rimeEngine else {
          return { $0?.deleteBackward() }
        }

        if rimeEngine.userInputKey.isEmpty {
          return { $0?.deleteBackward() }
        }

        rimeEngine.userInputKey.removeLast()
        if !rimeEngine.inputKey(KeyboardConstant.KeySymbol.Backspace.rawValue) {
          NSLog("rime engine input backspace key error")
          rimeEngine.rest()
        }
        return { _ in }
      }
    case .keyboardType(let type):
      return { hamsterKeyboardContorller in
        { _ in hamsterKeyboardContorller?.setHamsterKeyboardType(type) }
      }
    default: return nil
    }
  }

  /**
   The action that by default should be triggered when the
   action is released.
   */
  var hamsterStandardReleaseAction: HamsterGestureAction? {
    switch self {
    case .character(let char):
      return { hamsterInputViewController in
        let insertCharAction: GestureAction = { $0?.insertText(char) }

        guard let keyboardType = hamsterInputViewController?.keyboardContext.keyboardType else {
          return insertCharAction
        }

        if !keyboardType.isAlphabetic {
          return insertCharAction
        }

        guard let rimeEngine = hamsterInputViewController?.rimeEngine else {
          return insertCharAction
        }

        if rimeEngine.isAsciiMode() {
          return insertCharAction
        }

        // 调用输入法引擎
        if rimeEngine.inputKey(char) {
          // 唯一码直接上屏
          let commitText = rimeEngine.getCommitText()
          if !commitText.isEmpty {
            rimeEngine.rest()
            return { $0?.insertText(commitText) }
          }

          let status = rimeEngine.status()
          // 不存在候选字
          if !status.isComposing {
            rimeEngine.rest()
          } else {
            rimeEngine.userInputKey = rimeEngine.getInputKeys()
          }
          return { _ in }
        } else {
          log.error("rime engine input character \(char) error.")
          rimeEngine.rest()
        }
        return insertCharAction
      }

    case .characterMargin(let char): return { _ in { $0?.insertText(char) } }
    case .dismissKeyboard: return { _ in { $0?.dismissKeyboard() } }
    case .emoji(let emoji): return { _ in { $0?.insertText(emoji.char) } }
    case .moveCursorBackward: return { _ in { $0?.adjustTextPosition(byCharacterOffset: -1) } }
    case .moveCursorForward: return { _ in { $0?.adjustTextPosition(byCharacterOffset: 1) } }
    case .nextLocale: return { _ in { $0?.selectNextLocale() } }
    case .primary:
      return { hamsterInputViewController in
        let newLineAction: GestureAction = {
          $0?.insertText(.newline)
        }

        guard let rimeEngine = hamsterInputViewController?.rimeEngine else {
          return newLineAction
        }

        if !rimeEngine.userInputKey.isEmpty {
          let text = rimeEngine.userInputKey
          rimeEngine.rest()
          return { $0?.insertText(text) }
        }

        return newLineAction
      }
    case .shift(let currentState):
      return { _ in
        {
          switch currentState {
          case .lowercased: $0?.setKeyboardType(.alphabetic(.uppercased))
          case .auto, .capsLocked, .uppercased: $0?.setKeyboardType(.alphabetic(.lowercased))
          }
        }
      }
    case .space:
      return { hamsterInputViewController in
        let spaceAction: GestureAction = { $0?.insertText(.space) }
        guard let rimeEngine = hamsterInputViewController?.rimeEngine else { return spaceAction }
        let status = rimeEngine.status()
        if status.isComposing {
          let candidates = rimeEngine.context().getCandidates()
          if !candidates.isEmpty {
            let text = candidates[0].text
            rimeEngine.rest()
            return { $0?.insertText(text) }
          }

          if !rimeEngine.userInputKey.isEmpty {
            let text = rimeEngine.userInputKey
            rimeEngine.rest()
            return { $0?.insertText(text) }
          }
        }
        return spaceAction
      }
    case .tab: return { _ in { $0?.insertText(.tab) } }
    // TODO: 自定义按键动作处理
    case .custom(let name):
      return { hamsterInputViewController in
        guard let rimeEngine = hamsterInputViewController?.rimeEngine else { return { _ in } }
        if rimeEngine.inputKey(name) {
          // 唯一码直接上屏
          let commitText = rimeEngine.getCommitText()
          if !commitText.isEmpty {
            rimeEngine.rest()
            return { $0?.insertText(commitText) }
          }

          let status = rimeEngine.status()
          // 不存在候选字
          if !status.isComposing {
            rimeEngine.rest()
          } else {
            rimeEngine.userInputKey = rimeEngine.getInputKeys()
          }
          return { _ in }
        }
        return { _ in }
      }
    default: return nil
    }
  }

  /**
   The action that by default should be triggered when the
   action is pressed, and repeated until it is released.
   */
  var hamsterStandardRepeatAction: HamsterGestureAction? {
    switch self {
    case .backspace: return hamsterStandardReleaseAction
    default: return nil
    }
  }
}
