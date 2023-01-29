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
    case .shift(let currentState): return { hamsterInputViewContorller in {
        // shift 小鹤双形通配符
        if let rimeEngine = hamsterInputViewContorller?.rimeEngine {
          if !rimeEngine.inputKey.isEmpty {
            if rimeEngine.inputKey(KeyboardConstant.KeySymbol.QuoteLeft.rawValue) {
              let candidates = rimeEngine.context().getCandidates()
              if !candidates.isEmpty {
                rimeEngine.candidates = candidates
                rimeEngine.inputKey = rimeEngine.getInputKeys()
              }
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
    let newLineAction: GestureAction = { $0?.textInputProxy?.insertText(.newline) }
    let deleteAction: GestureAction = {
      $0?.textDocumentProxy.deleteBackward(range: $0?.keyboardBehavior.backspaceRange ?? .char)
    }
    
    switch self {
    case .backspace: return { hamsterInputViewController in
        if let rimeEngine = hamsterInputViewController?.rimeEngine {
          let inputKeys = rimeEngine.getInputKeys()
          if inputKeys.isEmpty {
            return deleteAction
          }

          // TODO:
          if rimeEngine.inputKey(KeyboardConstant.KeySymbol.Backspace.rawValue) {
            rimeEngine.candidates = rimeEngine.context().getCandidates()
            rimeEngine.inputKey = rimeEngine.getInputKeys()
          } else {
            rimeEngine.cleanAll()
          }
        }
        return { _ in }
      }
    case .character(let char): return { hamsterInputViewController in
        let insertCharAction: GestureAction = { $0?.textDocumentProxy.insertText(char) }
      
        // Shift 小写
        if hamsterInputViewController?.keyboardContext.keyboardType == .alphabetic(.lowercased),
           let rimeEngine = hamsterInputViewController?.rimeEngine
        {
          if rimeEngine.isAsciiMode() {
            return insertCharAction
          }
          
          if rimeEngine.inputKey(char) {
            let commit = rimeEngine.getCommitText()
            if commit.isEmpty {
              rimeEngine.inputKey = rimeEngine.getInputKeys()
              rimeEngine.candidates = rimeEngine.candidateList()
            } else {
              rimeEngine.cleanAll()
              return { $0?.textDocumentProxy.insertText(commit) }
            }
          }
          return { _ in }
        }
      
        if let rimeEgine = hamsterInputViewController?.rimeEngine {
          rimeEgine.cleanComposition()
          rimeEgine.inputKey = ""
          rimeEgine.candidates = []
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
        let action: GestureAction = { $0?.textDocumentProxy.insertText(.space) }
        if let rimeEngine = hamsterInputViewController?.rimeEngine {
          let status = rimeEngine.status()
          if status.isComposing {
            if !rimeEngine.candidates.isEmpty {
              let candidates = rimeEngine.candidates
              rimeEngine.inputKey = ""
              rimeEngine.candidates = []
              rimeEngine.cleanComposition()
              return { $0?.textDocumentProxy.insertText(candidates[0].text) }
            }
          }
        }
        return action
      }
    case .tab: return { _ in { $0?.textDocumentProxy.insertText(.tab) }}
    default: return nil
    }
  }
}
