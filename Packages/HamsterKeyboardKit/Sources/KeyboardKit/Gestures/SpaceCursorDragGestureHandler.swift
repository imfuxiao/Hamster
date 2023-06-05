//
//  SpaceCursorDragGestureHandler.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This drag gesture handler handles the space key cursor move
 drag gesture.

 该拖动手势处理程序可处理空格键光标移动的拖动手势。
 */
open class SpaceCursorDragGestureHandler: DragGestureHandler {
  // MARK: - Properties

  public let feedbackHandler: KeyboardFeedbackHandler
  public let sensitivity: SpaceDragSensitivity
  public let verticalThreshold: Double
  public let action: (Int) -> Void

  /// 当前拖动起始位置
  public var currentDragStartLocation: CGPoint?

  /// 当前拖动的文本位置偏移量
  public var currentDragTextPositionOffset: Int = 0

  // MARK: - Initializations

  /**
   Create a handler space cursor drag gesture handler.

   创建空格键移动光标的拖动手势处理程序。

   You can provide a `sensitivity` to set how much a space
   drag gesture will move the input cursor.

   您可以提供一个 `sensitivity` 灵敏度来设置空格拖动手势将移动多少光标位置。

   You can provide a `verticalThreshold` to set how much a
   drag gesture can move up and down before the text input
   cursor stops moving when the gesture changes.

   您可以提供一个 `verticalThreshold` 垂直阈值来设置拖动手势上下移动的幅度，
   当手势改变时，文本输入光标才会停止移动。

   - Parameters:
     - feedbackHandler: The feedback handler to use.
                        使用的反馈处理程序。
     - sensitivity: The drag sensitivity, by default ``SpaceDragSensitivity/medium``.
                    拖动灵敏度，默认为``SpaceDragSensitivity/medium``。
     - verticalThreshold: The vertical tolerance in points, by default `50`.
                           以 points 为单位, 垂直方向阈值，默认为 `50`。
     - action: The action to perform for the drag offset.
                对拖动偏移执行的操作。
   */
  public init(
    feedbackHandler: KeyboardFeedbackHandler,
    sensitivity: SpaceDragSensitivity = .medium,
    verticalThreshold: Double = 50,
    action: @escaping (Int) -> Void
  ) {
    self.feedbackHandler = feedbackHandler
    self.sensitivity = sensitivity
    self.verticalThreshold = verticalThreshold
    self.action = action
  }

  // MARK: - Functions

  /**
   Handle a drag gesture on space, which by default should
   move the cursor left and right after a long press.

   处理空格拖动手势，默认情况下，长按后光标会左右移动。
   */
  public func handleDragGesture(
    from startLocation: CGPoint,
    to currentLocation: CGPoint
  ) {
    tryStartNewDragGesture(from: startLocation, to: currentLocation)
    let dragDelta = startLocation.x - currentLocation.x
    let textPositionOffset = Int(dragDelta / CGFloat(sensitivity.points))
    guard textPositionOffset != currentDragTextPositionOffset else { return }
    let offsetDelta = textPositionOffset - currentDragTextPositionOffset
    currentDragTextPositionOffset = textPositionOffset
    let verticalDistance = abs(startLocation.y - currentLocation.y)
    guard verticalDistance < verticalThreshold else { return }
    action(-offsetDelta)
  }
}

extension UITextDocumentProxy {
  /**
   This hopefully temporary multiplier offset is used when
   a drag gesture moves over a combined emoji.

   当拖动手势移动到 emoji 上时，就会使用这个临时乘数偏移。
   */
  func spaceDragOffset(for rawOffset: Int) -> Int? {
    let multiplier = spaceDragOffsetMultiplier(for: rawOffset)
    return rawOffset * (multiplier ?? 1)
  }

  /**
   This hopefully temporary multiplier is used when a drag
   gesture moves over a combined emoji.

   当拖动手势移动到 emoji 符号上时，就会使用这个临时乘数。
   */
  func spaceDragOffsetMultiplier(for offset: Int) -> Int? {
    let char = spaceDragOffsetMultiplierCharacter(for: offset)
    return char?.spaceDragOffsetMultiplier
  }

  /**
   This hopefully temporary character is used when a space
   drag gesture moves over a combined emoji.

   当空格拖动手势移动到 emoji 上时，就会使用这个临时字符。
   */
  func spaceDragOffsetMultiplierCharacter(for offset: Int) -> String.Element? {
    if offset == 1 { return documentContextAfterInput?.first }
    if offset == -1 { return documentContextBeforeInput?.last }
    return nil
  }
}

extension String.Element {
  /**
   This hopefully temporary multiplier is used when a drag
   gesture moves over a combined emoji.

   当拖动手势移动到 emoji 符号上时，就会使用这个临时乘数。
   */
  var spaceDragOffsetMultiplier: Int {
    guard isEmoji else { return 1 }
    return Int(floor(Double(utf8.count) / 2))
  }
}

private extension SpaceCursorDragGestureHandler {
  /// 尝试开始新拖动手势
  func tryStartNewDragGesture(
    from startLocation: CGPoint,
    to currentLocation: CGPoint
  ) {
    let isNewDrag = currentDragStartLocation != startLocation
    currentDragStartLocation = startLocation
    guard isNewDrag else { return }
    currentDragTextPositionOffset = 0
  }
}
