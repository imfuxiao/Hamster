//
//  HamsterSlidingGestureHandler.swift
//  HamsterKeyboard
//
//  Created by morse on 23/4/2023.
//

import Foundation
import KeyboardKit

/// 滑动方向
enum SwipeDirection: Equatable {
  case up
  case down
  case left
  case right

  // 是否X轴滑动
  var isXAxis: Bool {
    self == .left || self == .right
  }

  var isYAxis: Bool {
    self == .up || self == .down
  }
}

/// 全键盘手势滑动处理
class HamsterSwipeGestureHandler: SwipeGestureHandler {
  typealias OffsetX = Int
  typealias OffsetY = Int
  typealias SwipeGestureAction = (KeyboardAction, SwipeDirection, OffsetX, OffsetY) -> Void
  public init(
    keyboardContext: KeyboardContext,
    // 滑动敏感度：滑动超过阈值才有效
    sensitivityX: SpaceDragSensitivity = .custom(points: 10),
    sensitivityY: SpaceDragSensitivity = .custom(points: 20),
    action: @escaping SwipeGestureAction
  ) {
    self.keyboardContext = keyboardContext
    self.sensitivityY = sensitivityY
    self.sensitivityX = sensitivityX
    self.action = action
  }

  var isDragging: Bool = false

  private let enableSpaceSliding: Bool = false
  public let keyboardContext: KeyboardContext
  public let sensitivityX: SpaceDragSensitivity
  public let sensitivityY: SpaceDragSensitivity
  public let action: SwipeGestureAction

  // 当前触发开始的Action
  public var currentAction: KeyboardAction?
  // 当前触发开始位置Location
  // 系统每次调用Drag时, 如果startLocation不同, 则视为一个新的startLocation
  public var currentDragStartLocation: CGPoint?

  // Action完成标志
  private var currentActionIsFinished = false

  // 保留从开始位置到结束位置y轴偏移量(偏移量需要除以sensitivity的值, 已确定是否超过阈值)
  public var currentDragOffsetY: Int = 0

  // 保留从开始位置到结束位置X轴偏移量(偏移量需要除以sensitivity的值, 已确定是否超过阈值)
  public var currentDragOffsetX: Int = 0

  public func handleDragGesture(action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint) {
    let isNewAction = action == currentAction
    if isNewAction {
      currentAction = action
      currentDragOffsetY = 0
      currentDragOffsetX = 0
      currentActionIsFinished = false
    }

    tryStartNewDragGesture(from: startLocation, to: currentLocation)
    let dragDeltaY = startLocation.y - currentLocation.y
    let dragDeltaX = startLocation.x - currentLocation.x
    let dragOffsetY = Int(dragDeltaY / CGFloat(sensitivityY.points))
    let dragOffsetX = Int(dragDeltaX / CGFloat(sensitivityX.points))
    // x，y轴都没有超过阈值，则不视做一次滑动
    if dragOffsetX == currentDragOffsetX && dragOffsetY == currentDragOffsetY {
      return
    }

    // 滑动方向
    var slidingDirection: SwipeDirection

    if dragOffsetX == 0 && dragOffsetY != 0 { // 上下滑动
      slidingDirection = dragOffsetY > 0 ? .up : .down
    } else if dragOffsetY == 0 && dragOffsetX != 0 { // 左右滑动
      slidingDirection = dragOffsetX > 0 ? .left : .right
    } else { // 其余情况已左右滑动优先
      slidingDirection = dragOffsetX > 0 ? .left : .right
    }

    // TODO：目前只有空格左右滑动可以连续触发, 其余Action都是一次性触发
    if action == .space && slidingDirection.isXAxis {
      isDragging = true
      let offsetDelta = dragOffsetX - currentDragOffsetX
      self.action(action, slidingDirection, -offsetDelta, 0)
    } else if !currentActionIsFinished {
      isDragging = true
      self.action(action, slidingDirection, dragOffsetX, dragOffsetY)
      currentActionIsFinished = true
    }

    currentDragOffsetX = dragOffsetX
    currentDragOffsetY = dragOffsetY
  }

  func endDragGesture() {
    currentAction = nil
    currentDragOffsetX = 0
    currentDragOffsetY = 0
    currentActionIsFinished = false
    isDragging = false
  }

  func tryStartNewDragGesture(
    from startLocation: CGPoint,
    to currentLocation: CGPoint
  ) {
    let isNewDrag = currentDragStartLocation != startLocation
    currentDragStartLocation = startLocation
    guard isNewDrag else { return }
    currentDragOffsetY = 0
    currentDragOffsetX = 0
  }
}
