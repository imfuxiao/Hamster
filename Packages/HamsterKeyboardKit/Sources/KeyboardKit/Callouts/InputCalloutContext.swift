//
//  InputCalloutContext.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Combine
import UIKit

/**
 This context can be used to handle callouts that show a big
 version of the currently typed character.

 该上下文可用于处理显示当前键入字符的呼出。

 You can inherit this class and override any open properties
 and functions to customize the standard behavior.

 您可以继承该类，并覆盖任何 open 的属性和函数，以自定义标准行为。
 */
open class InputCalloutContext: ObservableObject {
  // MARK: - Properties

  /**
   This coordinate space is used when presenting callouts.

   该坐标空间用于显示呼出。
   */
  public static let coordinateSpace = "com.keyboardkit.coordinate.InputCallout"

  /**
   This value can be used to set the minimum duration of a
   callout.

   该值可用于设置呼出的最短持续时间。
   */
  public var minimumVisibleDuration: TimeInterval = 0.05

  // MARK: - Published Properties

  /**
   Whether or not the context is enabled, which means that
   it will show callouts as the user types.

   上下文是否启用，这意味着在用户输入时会显示呼出。
   */
  @Published
  public var isEnabled: Bool

  /**
   The action that is currently active for the context.

   上下文中当前激活的操作。
   */
  @Published
  public private(set) var action: KeyboardAction?

  /**
   The frame of the button that is active for the context.

   上下文中处于活动状态的按钮的 frame。
   */
  @Published
  public private(set) var buttonFrame: CGRect = .zero

  // MARK: - Initialization

  /**
   Create a new context instance,

   - Parameters:
     - isEnabled: Whether or not the context is enabled.
   */
  public init(isEnabled: Bool) {
    self.isEnabled = isEnabled
  }

  // MARK: - Functions

  /**
   Reset the context. This will cause any current callouts
   to be dismissed.

   重置上下文。这将导致当前任何呼出都被取消。
   */
  open func reset() {
    action = nil
    buttonFrame = .zero
  }

  /**
   Reset the context with a delay, which is useful when an
   input callout should be displayed a little while.

   通过延迟重置上下文，这在输入呼出需要显示一段时间时非常有用。
   */
  open func resetWithDelay() {
    let delay = minimumVisibleDuration
    let date = Date()
    lastActionDate = date
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      if self.lastActionDate > date { return }
      self.reset()
    }
  }

  public var lastActionDate = Date()

  /**
   Update the current input for a certain keyboard action.

   更新特定键盘操作的当前输入。
   */
//  open func updateInput(for action: KeyboardAction?, in geo: GeometryProxy) {
//    lastActionDate = Date()
//    self.action = action
//    buttonFrame = geo.frame(in: .named(Self.coordinateSpace))
//  }
}

public extension InputCalloutContext {
  /**
   Create a disabled context instance.
   */
  static var disabled: InputCalloutContext {
    InputCalloutContext(isEnabled: false)
  }
}

public extension InputCalloutContext {
  /**
   Get the optional input of any currently active action.

   获取当前激活操作的可选输入。
   */
  var input: String? {
    action?.inputCalloutText
  }

  /**
   Whether or not this context is active, which means that
   it's enabled and has an input.

   该上下文是否处于激活状态，这意味着它已启用并有输入。
   */
  var isActive: Bool {
    input != nil && isEnabled
  }
}
