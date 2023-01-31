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
    case .release: return nil
    case .repeatPress: return hamsterStandardRepeatAction
    case .tap: return hamsterStandardReleaseAction
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
    case .backspace: return hamsterStandardReleaseAction
    case .space: return { _ in { _ in }}
    default: return nil
    }
  }
  
  /**
   The action that by default should be triggered when the
   action is pressed.
   */
  var hamsterStandardPressAction: HamsterGestureAction? {
    switch self {
    case .keyboardType(let type): return { _ in {
        // TODO: 切换九宫格
        if case .numeric = type {
          $0?.keyboardContext.keyboardType = .custom(named: KeyboardConstant.keyboardType.GridView)
        } else {
          $0?.keyboardContext.keyboardType = type
        }
      }
      }
    default: return nil
    }
  }
  
  /**
   The action that by default should be triggered when the
   action is released.
   */
  var hamsterStandardReleaseAction: HamsterGestureAction? {
    if let action = hamsterStandardTextDocumentProxyAction { return action }
    switch self {
    case .dismissKeyboard: return { _ in { $0?.dismissKeyboard() }}
    case .nextLocale: return { _ in { $0?.keyboardContext.selectNextLocale() }}
    case .shift(let currentState): return { hamsterInputViewContorller in
        {
          // MARK: Shift键做为小鹤双形通配符

          if let rimeEngine = hamsterInputViewContorller?.rimeEngine {
            let inputKey = rimeEngine.getInputKeys()
            if !inputKey.isEmpty {
              if rimeEngine.inputKey(KeyboardConstant.KeySymbol.QuoteLeft.rawValue) {
                rimeEngine.userInputKey.append(KeyboardConstant.KeySymbol.QuoteLeft.string())
              }
              return
            }
          }
          
          switch currentState {
          case .lowercased: $0?.keyboardContext.keyboardType = .alphabetic(.uppercased)
          case .auto, .capsLocked, .uppercased: $0?.keyboardContext.keyboardType = .alphabetic(.lowercased)
          }
        }
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
  
  /**
   The standard text document proxy action, if any.
   */
  var hamsterStandardTextDocumentProxyAction: HamsterGestureAction? {
    let newLineAction: GestureAction = {
      $0?.textDocumentProxy.insertText(.newline)
    }
    let deleteAction: GestureAction = {
      $0?.textDocumentProxy.deleteBackward(range: $0?.keyboardBehavior.backspaceRange ?? .char)
    }
    
    switch self {
    case .backspace: return { hamsterInputViewController in
        guard let rimeEngine = hamsterInputViewController?.rimeEngine else {
          return deleteAction
        }
      
        if rimeEngine.userInputKey.isEmpty {
          return deleteAction
        }
      
        rimeEngine.userInputKey.removeLast()
        if !rimeEngine.inputKey(KeyboardConstant.KeySymbol.Backspace.rawValue) {
          NSLog("rime engine input backspace key error")
          rimeEngine.rest()
        }
        return { _ in }
      }
    case .character(let char): return { hamsterInputViewController in
        let insertCharAction: GestureAction = { $0?.textDocumentProxy.insertText(char) }
      
        guard let keyboardType = hamsterInputViewController?.keyboardContext.keyboardType else {
          return insertCharAction
        }
      
        // 键盘非小写状态
        if keyboardType != .alphabetic(.lowercased) {
          return insertCharAction
        }
      
        guard let rimeEngine = hamsterInputViewController?.rimeEngine else {
          return insertCharAction
        }
      
        // 输入法引擎为字母状态
        if rimeEngine.isAsciiMode() {
          return insertCharAction
        }
      
        // 调用输入法引擎
        if rimeEngine.inputKey(char) {
          // 唯一码直接上屏
          let commitText = rimeEngine.getCommitText()
          if !commitText.isEmpty {
            rimeEngine.rest()
            return { $0?.textDocumentProxy.insertText(commitText) }
          }
          
          let status = rimeEngine.status()
          // 不存在候选字
          if !status.isComposing {
            rimeEngine.rest()
          } else {
            rimeEngine.userInputKey.append(char)
          }
          return { _ in }
        } else {
          NSLog("rime engine input character(%s) error. ", char)
          rimeEngine.rest()
        }
        return insertCharAction
      }
      
    case .characterMargin(let char): return { _ in { $0?.textDocumentProxy.insertText(char) }}
    case .emoji(let emoji): return { _ in { $0?.textDocumentProxy.insertText(emoji.char) }}
    case .moveCursorBackward: return { _ in { $0?.textDocumentProxy.adjustTextPosition(byCharacterOffset: -1) }}
    case .moveCursorForward: return { _ in { $0?.textDocumentProxy.adjustTextPosition(byCharacterOffset: 1) }}
      
    // TODO: new line action process
    case .newLine: return { _ in newLineAction }
    case .primary: return { _ in newLineAction }
    case .return: return { _ in newLineAction }
      
    case .space: return { hamsterInputViewController in
        let spaceAction: GestureAction = { $0?.textDocumentProxy.insertText(.space) }
        guard let rimeEngine = hamsterInputViewController?.rimeEngine else { return spaceAction }
        let status = rimeEngine.status()
        if status.isComposing {
          let candidates = rimeEngine.context().getCandidates()
          if !candidates.isEmpty {
            rimeEngine.rest()
            return { $0?.textDocumentProxy.insertText(candidates[0].text) }
          }
        }
        return spaceAction
      }
    case .tab: return { _ in { $0?.textDocumentProxy.insertText(.tab) }}
    default: return nil
    }
  }
}
