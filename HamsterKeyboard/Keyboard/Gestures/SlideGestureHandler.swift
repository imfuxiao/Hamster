import CoreGraphics
import KeyboardKit



// 滑动手势
public protocol SlideGestureHandler {
  func handleDragGesture(
    action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint
  )

  func endDragGesture()
}
