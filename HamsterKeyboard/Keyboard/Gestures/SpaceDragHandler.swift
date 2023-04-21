//
//  SpaceDragHandler.swift
//  HamsterKeyboard
//
//  Created by Vitta on 2023/4/20.
//

import Foundation
import KeyboardKit

class SpaceDragHandler: SlideGestureHandler {
  /**
   Create a handler space cursor drag gesture handler.

   - Parameters:
   - keyboardContext: The keyboard context to use.
   - feedbackHandler: The feedback handler to use.
   - sensitivity: The drag sensitivity, by default ``SpaceDragSensitivity/medium``.
   - action: The action to perform for the drag offset.
   */
  public init(
    keyboardContext: KeyboardContext,
    feedbackHandler: KeyboardFeedbackHandler,
    sensitivity: SpaceDragSensitivity = .custom(points: 60),
    action: @escaping (KeyboardAction, Int) -> Void
  ) {
    self.keyboardContext = keyboardContext
    self.feedbackHandler = feedbackHandler
    self.sensitivity = sensitivity
    self.action = action
  }

  public let keyboardContext: KeyboardContext
  public let feedbackHandler: KeyboardFeedbackHandler
  public let sensitivity: SpaceDragSensitivity
  public let action: (KeyboardAction, Int) -> Void
  public var horizontalDragging: () -> Void = {}
  public var allowAction: Bool = false
  public let SpaceHorizontalDragSensitivity: SpaceDragSensitivity = .custom(points: 30)
  // 当前触发开始的Action
  public var currentAction: KeyboardAction?
  // 当前触发开始位置Location
  // 系统每次调用Drag时, 如果startLocation不同, 则视为一个新的startLocation
  public var currentDragStartLocation: CGPoint?

  // 水平滑动距离
  private var currentActionIsFinished = false
  // 保留从开始位置到结束位置y轴偏移量(偏移量需要除以sensitivity的值, 已确定是否超过阈值)
  public var currentDragOffset: Int = 0

  public func handleDragGesture(
    action: KeyboardAction,
    from startLocation: CGPoint,
    to currentLocation: CGPoint
  ) {
    let isNewAction = action == currentAction
    if isNewAction {
      currentAction = action
      currentDragOffset = 0
      currentActionIsFinished = false
    }

    tryStartNewDragGesture(from: startLocation, to: currentLocation)
    let dragDelta = startLocation.y - currentLocation.y
    let dragX = abs(startLocation.x - currentLocation.x)
    let dragOffset = Int(dragDelta / CGFloat(sensitivity.points))

    if CGFloat(dragX) < CGFloat(SpaceHorizontalDragSensitivity.points) {
      // 视为 上下滑动

      // 重复触发
      guard dragOffset != currentDragOffset else { return }
      if !allowAction { return } else {
        self.action(action, dragOffset)
        currentActionIsFinished = true
      }

      currentDragOffset = dragOffset

    } else {
      // 视为左右滑动
      horizontalDragging()
    }
  }

  func endDragGesture() {
    currentAction = nil
    currentDragOffset = 0
    currentActionIsFinished = false
  }

  func tryStartNewDragGesture(
    from startLocation: CGPoint,
    to _: CGPoint
  ) {
    let isNewDrag = currentDragStartLocation != startLocation
    currentDragStartLocation = startLocation
    guard isNewDrag else { return }
    currentDragOffset = 0
  }

  /// 设置水平滑动事件和是否允许上下滑
  /// - Parameters:
  ///   - horizontalDragging: 水平滑动事件
  ///   - allowAction: 是否允许上下滑
  public func setHorizontalDraggingEventAndAllowAction(horizontalDragging: @escaping () -> Void, allowAction: Bool) {
    self.horizontalDragging = horizontalDragging
    self.allowAction = allowAction
  }
}
