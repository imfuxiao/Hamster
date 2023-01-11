import KeyboardKit
import CoreGraphics

public protocol SlideGestureHandler {
  
  /**
   Handle Slide gestures from a start to a current location.
   */
  func handleDragGesture(action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint)
}
