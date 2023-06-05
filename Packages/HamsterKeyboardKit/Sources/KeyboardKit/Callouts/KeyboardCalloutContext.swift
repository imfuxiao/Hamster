//
//  CalloutContext.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-01-24.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Combine

/**
 This observable context can be used to handle callout state
 for a keyboard.

 此可观察上下文可用于处理键盘的呼出状态。

 The class wraps contexts for both action and input callouts,
 so that we only have to pass around a single instance.

 该类封装了操作（action）和输入呼出(input callout)的上下文，因此我们只需传递一个实例。

 KeyboardKit automatically creates an instance of this class
 and binds the created instance to the keyboard controller's
 ``KeyboardInputViewController/calloutContext``.

 KeyboardKit 会自动创建该类的实例，并将该实例绑定到键盘 controller 的
 ``KeyboardInputViewController/calloutContext`` 中。
 */
open class KeyboardCalloutContext: ObservableObject {
  /**
   The action callout context that is bound to the context.

   操作呼出上下文。
   */
  public var action: ActionCalloutContext

  /**
   The input callout context that is bound to the context.

   输入呼出的上下文
   */
  public var input: InputCalloutContext

  /**
   Create a new callout context instance,

   - Parameters:
     - action: The action callout context to use.
     - input: The input callout context to use.
   */
  public init(
    action: ActionCalloutContext,
    input: InputCalloutContext
  ) {
    self.action = action
    self.input = input
  }
}

public extension KeyboardCalloutContext {


  /**
   This disabled context can be used to disable callouts.
   */
  static var disabled: KeyboardCalloutContext {
    KeyboardCalloutContext(
      action: .disabled,
      input: .disabled
    )
  }
}
