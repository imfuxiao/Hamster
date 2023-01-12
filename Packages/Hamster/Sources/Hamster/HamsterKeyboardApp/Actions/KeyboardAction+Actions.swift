//
//  KeyboardActionHandler+Actions.swift
//  HamsterKeyboard
//
//  Created by morse on 10/1/2023.
//

import Foundation
import KeyboardKit

extension KeyboardAction {
  func hamsterStanderAction(for gesture: KeyboardGesture) -> GestureAction? {
    switch gesture {
    case .doubleTap: return hamsterStandardDoubleTapAction
    case .longPress: return hamsterStandardLongPressAction
    case .press: return hamsterStandardPressAction
    case .release: return hamsterStandardReleaseAction
    case .repeatPress: return hamsterStandardRepeatAction
    case .tap: return hamsterStandardTapAction
    }
  }
  
  /**
   The action that by default should be triggered when the
   action is double tapped.
   */
  var hamsterStandardDoubleTapAction: GestureAction? { nil }
  
  var hamsterStandardLongPressAction: GestureAction? {
    switch self {
    case .backspace: return standardReleaseAction
    case .space: return { _ in }
    default: return nil
    }
  }

  /**
   The action that by default should be triggered when the
   action is pressed.
   */
  var hamsterStandardPressAction: GestureAction? {
    switch self {
    case .keyboardType(let type): return {
        // TODO: 切换九宫格
        if case .numeric = type {
          $0?.keyboardContext.keyboardType = .custom(named: KeyboardConstant.keyboardType.GridView)
        } else {
          $0?.keyboardContext.keyboardType = type
        }
      }
    default: return nil
    }
  }
  
  /**
   The action that by default should be triggered when the
   action is released.
   */
  var hamsterStandardReleaseAction: GestureAction? { nil }

  var hamsterStandardTapAction: GestureAction? {
    if let action = standardTextDocumentProxyAction { return action }
    switch self {
    case .dismissKeyboard: return { $0?.dismissKeyboard() }
    case .nextLocale: return { $0?.keyboardContext.selectNextLocale() }
    case .shift(let currentState): return {
        switch currentState {
        case .lowercased: $0?.keyboardContext.keyboardType = .alphabetic(.uppercased)
        case .auto, .capsLocked, .uppercased: $0?.keyboardContext.keyboardType = .alphabetic(.lowercased)
        }
      }
    default: return nil
    }
  }
  
  /**
   The action that by default should be triggered when the
   action is pressed, and repeated until it is released.
   */
  var hamsterStandardRepeatAction: GestureAction? {
    switch self {
    case .backspace: return standardReleaseAction
    default: return nil
    }
  }
}
