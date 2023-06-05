//
//  KeyboardActionHandler.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-04-24.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics

/**
 This protocol can be implemented by classes that can handle
 ``KeyboardAction`` events.
 
 该协议可以由能够处理``KeyboardAction``事件的类来实现。
 
 KeyboardKit will create a ``StandardKeyboardActionHandler``
 instance when the keyboard extension is started, then apply
 it to ``KeyboardInputViewController/keyboardActionHandler``.
 It will then use this instance by default to handle actions.
 
 启动键盘扩展时，KeyboardKit 将创建一个 ``StandardKeyboardActionHandler`` 实例，
 然后将其应用到 ``KeyboardInputViewController/keyboardActionHandler`` 中。
 然后，controller 将默认使用该实例来处理操作。
 
 Many keyboard actions have standard behaviors, while others
 don't and require custom handling. To customize how actions
 are handled, you can implement a custom action handler.
 
 许多键盘操作都有标准行为，而另一些则没有，需要自定义 handle。
 要自定义 handle 的处理方式，您可以实现自定义操作的 handle。
 
 You can create a custom implementation of this protocol, by
 inheriting and customizing the standard class or creating a
 new implementation from scratch. When you're implementation
 is ready, just replace the controller service with your own
 implementation to make the library use it instead.
 
 您可以通过继承和定制标准类或从头开始创建一个新的实现来创建该协议的自定义实现。
 当你的实现准备就绪时，只需用你自己的实现替换 controller 中的服务，就能让程序库使用它。
 */
public protocol KeyboardActionHandler: AnyObject {
  /**
   Whether or not the handler can handle a certain gesture
   on a certain action.
   
   处理程序是否可以处理某个操作上的某个手势。
   */
  func canHandle(_ gesture: KeyboardGesture, on action: KeyboardAction) -> Bool
    
  /**
   Handle a certain action using its standard action.
   
   使用标准操作处理逻辑, 处理某个操作。
   */
  func handle(_ action: KeyboardAction)

  /**
   Handle a certain gesture on a certain action.
   
   处理某个操作上的某个手势。
   */
  func handle(_ gesture: KeyboardGesture, on action: KeyboardAction)

  /**
   处理 Key 的上某个手势
   */
  func handle(_ gesture: KeyboardGesture, on key: Key)

  /**
   Handle a drag gesture on a certain action.
   
   处理某个操作上的拖动手势。
   */
  func handleDrag(on action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint)
}
