import CoreGraphics
import KeyboardKit

// 滑动手势
public protocol SwipeGestureHandler {
  // 拖拽进行中
  var isDragging: Bool { get set }

  func handleDragGesture(
    action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint
  )

  func endDragGesture()
}
