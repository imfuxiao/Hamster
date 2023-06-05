//
//  KeyboardFeedbackHandler.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any classes that can be
 used to trigger audio and haptic feedback to the user.
 
 该协议可由任何可用于向用户触发音频和触觉反馈的类实现。
 
 KeyboardKit will create a ``StandardKeyboardFeedbackHandler``
 instance when the keyboard extension is started, then apply
 it to ``KeyboardInputViewController/keyboardFeedbackHandler``.
 It will then use this instance by default to give feedback.
 
 当键盘扩展启动时，KeyboardKit 将创建一个 ``StandardKeyboardFeedbackHandler`` 实例，
 然后将其应用到 ``KeyboardInputViewController/keyboardFeedbackHandler`` 中。
 这样，它就会默认使用该实例来提供反馈。
 
 Many keyboard actions have standard feedbacks, while others
 don't and require custom handling. To customize how actions
 give feedback, you can implement a custom feedback handler.
 
 许多键盘操作都有标准反馈，而有些操作则没有，需要自定义处理逻辑。
 要自定义处理操作的反馈方式，您可以实现自定义反馈处理程序。
 
 You can create a custom implementation of this protocol, by
 inheriting and customizing the standard class or creating a
 new implementation from scratch. When you're implementation
 is ready, just replace the controller service with your own
 implementation to make the library use it instead.
 
 您可以通过继承和定制标准类或从头开始创建一个新的实现来创建该协议的自定义实现。
 当你的实现准备就绪时，只需用你自己的实现替换 controller 中的服务，就能让程序库使用它。
 */
public protocol KeyboardFeedbackHandler {
  /**
   Trigger feedback for when a `gesture` is performed on a
   certain `action`.
   
   当对某个 `action` 执行特定 `gesture` 时，触发反馈。
   */
  func triggerFeedback(for gesture: KeyboardGesture, on action: KeyboardAction)
 
  /**
   Trigger feedback for when a `gesture` is performed on a
   certain `action`.
   
   当对某个 `action` 执行特定 `gesture` 时，触发音频反馈。
   */
  func triggerAudioFeedback(for gesture: KeyboardGesture, on action: KeyboardAction)
    
  /**
   Trigger feedback for when a `gesture` is performed on a
   certain `action`.
   
   当对某个 `action` 执行特定 `gesture` 时，触发触觉反馈。
   */
  func triggerHapticFeedback(for gesture: KeyboardGesture, on action: KeyboardAction)
}
