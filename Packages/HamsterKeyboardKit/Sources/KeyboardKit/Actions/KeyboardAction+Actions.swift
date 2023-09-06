//
//  KeyboardAction+Actions.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-07-01.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation
import HamsterKit

/**
 This extension defines standard gesture actions for various
 keyboard actions and ``KeyboardInputViewController``s.
 
 该扩展为各种键盘操作和 ``KeyboardInputViewController`` 定义了标准手势操作(GestureAction)。

 The ``KeyboardAction/GestureAction`` typealias signature is
 using an optional ``KeyboardController`` since some classes
 will use this with a weak controller reference.
 
 ``KeyboardAction/GestureAction`` 类型别名的签名使用了
 可选的 ``KeyboardController``，因为某些类将使用弱引用的 controller。
 */
public extension KeyboardAction {
  /**
   This typealias represents a gesture action that affects
   the provided ``KeyboardController``.
   
   该类型别名表示影响所提供的 ``KeyboardController`` 的手势操作。
   */
  typealias GestureAction = (KeyboardController?) -> Void

  /**
   The action that by default should be triggered when the
   action is triggered without a certain ``KeyboardGesture``.
   
   在没有特定 ``KeyboardGesture`` 键盘手势的情况下触发操作时，默认应触发的操作。
   */
  var standardAction: GestureAction? {
    standardReleaseAction ?? standardPressAction
  }
    
  /**
   The action that by default should be triggered when the
   action is triggered with a certain ``KeyboardGesture``.
   
   默认情况下，当使用特定的 ``KeyboardGesture`` 键盘手势, 触发操作时应触发的操作。
   */
  func standardAction(for gesture: KeyboardGesture) -> GestureAction? {
    switch gesture {
    case .doubleTap: return standardDoubleTapAction
    case .longPress: return standardLongPressAction
    case .press: return standardPressAction
    case .release: return standardReleaseAction
    case .repeatPress: return standardRepeatAction
    case .swipeUp: return standerSwipeUpAction
    case .swipeDown: return standerSwipeUpAction
    case .swipeLeft: return standerSwipeUpAction
    case .swipeRight: return standerSwipeUpAction
    }
  }
    
  /**
   The action that by default should be triggered when the
   action is double tapped.
   
   默认情况下，双击该操作时应触发的操作。
   */
  var standardDoubleTapAction: GestureAction? { nil }
    
  /**
   The action that by default should be triggered when the
   action is long pressed.
   
   默认情况下，长按该操作时应触发的操作。
   */
  var standardLongPressAction: GestureAction? {
    switch self {
    case .space: return { _ in }
    default: return nil
    }
  }
    
  /**
   The action that by default should be triggered when the
   action is pressed.
   
   默认情况下，按下时该操作时应触发的操作。
   */
  var standardPressAction: GestureAction? {
    switch self {
    case .backspace: return { $0?.deleteBackward() }
    case .keyboardType(let type): return { $0?.setKeyboardType(type) }
    default: return nil
    }
  }
    
  /**
   The action that by default should be triggered when the
   action is released.
   
   默认情况下，释放该操作时应触发的操作。
   */
  var standardReleaseAction: GestureAction? {
    switch self {
    case .character(let char): return { $0?.insertText(char) }
    case .characterMargin(let char): return { $0?.insertText(char) }
    case .symbol(let symbol): return { $0?.insertSymbol(symbol) }
    case .dismissKeyboard: return { $0?.dismissKeyboard() }
    case .emoji(let emoji): return { $0?.insertText(emoji.char) }
    case .moveCursorBackward: return { $0?.adjustTextPosition(byCharacterOffset: -1) }
    case .moveCursorForward: return { $0?.adjustTextPosition(byCharacterOffset: 1) }
    case .nextLocale: return { $0?.selectNextLocale() }
    case .nextKeyboard: return { $0?.selectNextKeyboard() }
    case .primary: return { $0?.insertRimeKeyCode(XK_Return) }
    case .shift(let currentState): return {
        switch currentState {
        case .lowercased: $0?.setKeyboardCase(.uppercased)
        case .auto, .capsLocked, .uppercased: $0?.setKeyboardCase(.lowercased)
        }
      }
    case .space: return { $0?.insertRimeKeyCode(XK_space) }
    case .systemSettings: return { $0?.openUrl(.keyboardSettings) }
    case .tab: return { $0?.insertRimeKeyCode(XK_Tab) }
    case .url(let url, _): return { $0?.openUrl(url) }
    case .returnLastKeyboard: return { $0?.returnLastKeyboard() }
    default: return nil
    }
  }
    
  /**
   The action that by default should be triggered when the
   action is pressed, and repeated until it is released.
   
   默认情况下，按下时应触发操作，并在重复按下直至释放。
   */
  var standardRepeatAction: GestureAction? {
    switch self {
    case .backspace: return standardPressAction
    default: return nil
    }
  }
  
  /// 默认情况下，上滑触发的操作
  var standerSwipeUpAction: GestureAction? {
    // TODO: 补充滑动触发的逻辑
    switch self {
    case .backspace: return { $0?.resetInputEngine() }
    case .space: return { $0?.selectSecondaryCandidate() }
    default:
      return nil
    }
  }
  
  /// 默认情况下，下滑触发的操作
  var standerSwipeDownAction: GestureAction? {
    // TODO: 补充滑动触发的逻辑
    return nil
  }
  
  /// 默认情况下，左滑触发的操作
  var standerSwipeLeftAction: GestureAction? {
    // TODO: 补充滑动触发的逻辑
    switch self {
    case .backspace: return { $0?.resetInputEngine() }
    default:
      return nil
    }
  }
  
  /// 默认情况下，右滑触发的操作
  var standerSwipeRightAction: GestureAction? {
    // TODO: 补充滑动触发的逻辑
    return nil
  }
}
