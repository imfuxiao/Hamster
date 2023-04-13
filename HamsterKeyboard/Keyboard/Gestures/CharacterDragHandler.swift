//
//  CharacterDragHandler.swift
//  HamsterKeyboard
//
//  Created by morse on 17/3/2023.
//

import Foundation
import KeyboardKit

class CharacterDragHandler: SlideGestureHandler {
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

  // 当前触发开始的Action
  public var currentAction: KeyboardAction?
  // 当前触发开始位置Location
  // 系统每次调用Drag时, 如果startLocation不同, 则视为一个新的startLocation
  public var currentDragStartLocation: CGPoint?

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
    let dragOffset = Int(dragDelta / CGFloat(sensitivity.points))
    // 重复触发
    guard dragOffset != currentDragOffset else { return }

    if !currentActionIsFinished {
      self.action(action, dragOffset)
      currentActionIsFinished = true
    }

    currentDragOffset = dragOffset
  }

  func endDragGesture() {
    currentAction = nil
    currentDragOffset = 0
    currentActionIsFinished = false
  }

  func tryStartNewDragGesture(
    from startLocation: CGPoint,
    to currentLocation: CGPoint
  ) {
    let isNewDrag = currentDragStartLocation != startLocation
    currentDragStartLocation = startLocation
    guard isNewDrag else { return }
    currentDragOffset = 0
  }
}
