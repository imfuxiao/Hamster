import KeyboardKit
import SwiftUI

class HamsterKeyboardActionHandler: StandardKeyboardActionHandler {
  // 滑动手势
  let slidGestureHandler: SlideGestureHandler
  weak var rimeEngine: RimeEngine?
  
  init(inputViewController ivc: KeyboardInputViewController, rimeEngine: RimeEngine) {
    self.rimeEngine = rimeEngine
    self.slidGestureHandler = CharacterSlideGestureHandler(context: ivc.keyboardContext)
    
    super.init(inputViewController: ivc)
  }
  
  override func action(for gesture: KeyboardGesture, on action: KeyboardAction) -> KeyboardAction.GestureAction? {
    return action.hamsterStanderAction(for: gesture)
  }
  
  // 滑动手势处理
  override func handleDrag(on action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint) {
    switch action {
    case .space: spaceDragGestureHandler.handleDragGesture(from: startLocation, to: currentLocation)
    case .character: self.slidGestureHandler.handleDragGesture(action: action, from: startLocation, to: currentLocation)
    default: break
    }
  }
  
  // MARK: - Custom actions
  
  func longPressAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
    return nil
  }
  
  func tapAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
    return nil
  }
}
