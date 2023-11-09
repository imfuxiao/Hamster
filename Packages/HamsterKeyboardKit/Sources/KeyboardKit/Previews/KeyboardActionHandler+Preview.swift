//
//  Actions+Preview.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-25.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics

public extension KeyboardActionHandler where Self == PreviewKeyboardActionHandler {
  /**
   This preview handler can be used in SwiftUI previews.

   该预览处理程序可用于 SwiftUI 预览。
   */
  static var preview: KeyboardActionHandler { PreviewKeyboardActionHandler() }
}

/**
 This action handler can be used in SwiftUI previews.

 此操作处理程序可在 SwiftUI 预览中使用。
 */
public class PreviewKeyboardActionHandler: KeyboardActionHandler {
  public init() {}

  public func canHandle(_ gesture: KeyboardGesture, on action: KeyboardAction) -> Bool { false }
  public func handle(_ action: KeyboardAction) {}
  public func handle(_ gesture: KeyboardGesture, on action: KeyboardAction) {}
  public func handle(_ gesture: KeyboardGesture, on key: Key) {}
  public func handleDrag(on action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint) {}
}
