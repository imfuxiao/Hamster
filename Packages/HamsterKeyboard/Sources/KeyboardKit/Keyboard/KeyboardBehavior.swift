//
//  KeyboardBehavior.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-28.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be used to specify behavior rules for the
 keyboard. It aims to separate behavior from action handling
 to make the code cleaner and more understandable.
 
 该协议可用于指定键盘的行为规则。其目的是将行为与操作处理分开，使代码更简洁易懂。
 
 `IMPORTANT` Whenever you replace the standard behavior with
 your own custom behavior, make sure to do so before calling
 any other services that depend on the behavior, or recreate
 the services that do depend on it.
 
 > 重要提示：无论何时都要确保，在调用依赖于该行为的任何其他服务，或重新创建依赖于该行为的服务之前，
 > 用自己的自定义行为替换标准行为。
 */
public protocol KeyboardBehavior {
  /**
   The range that the backspace key should delete when the
   key is long pressed.
   
   长按退格键时应删除的范围。
   */
  var backspaceRange: DeleteBackwardRange { get }
    
  /**
   The preferred keyboard type that should be applied when
   a certain gesture has been performed on an action.
   
   当对某个操作执行特定手势时，应用的首选键盘类型。
   */
  func preferredKeyboardType(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> KeyboardType
    
  /**
   Whether or not to end the currently typed sentence when
   a certain gesture has been performed on an action.
   
   当对某个操作执行特定手势时，是否结束当前键入的句子。
   */
  func shouldEndSentence(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> Bool
    
  /**
   Whether or not to switch to capslock when a gesture has
   been performed on an action.
   
   当对某个操作执行特定手势时，是否切换到大写锁定。
   */
  func shouldSwitchToCapsLock(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> Bool
    
  /**
   Whether or not to switch to the preferred keyboard type
   when a certain gesture has been performed on an action.
   
   当对某个操作执行特定手势时，是否切换到首选键盘类型。
   */
  func shouldSwitchToPreferredKeyboardType(
    after gesture: KeyboardGesture,
    on action: KeyboardAction
  ) -> Bool

  /**
   Whether or not to switch to the preferred keyboard type
   after the text document proxy text did change.
   
   在 ``textDocumentProxy`` 的文本发生变化后，是否切换到首选键盘类型。
   */
  func shouldSwitchToPreferredKeyboardTypeAfterTextDidChange() -> Bool
}
