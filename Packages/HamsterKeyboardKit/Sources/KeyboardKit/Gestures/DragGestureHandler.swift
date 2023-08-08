//
//  KeyboardGesture.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics

/**
 This protocol can be implemented by classes that can handle
 drag gestures from a start position to a current one.

 该协议可以由能够处理从起始位置到当前位置的拖动手势的类来实现。
 */
public protocol DragGestureHandler {
  /**
   Handle drag gestures from a start to a current location.

   处理从起始位置到当前位置的拖动手势。
   */
  func handleDragGesture(from startLocation: CGPoint, to currentLocation: CGPoint)
}
