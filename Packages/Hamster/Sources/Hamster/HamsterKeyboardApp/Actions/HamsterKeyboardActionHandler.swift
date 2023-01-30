import KeyboardKit
import SwiftUI

class HamsterKeyboardActionHandler: StandardKeyboardActionHandler {
  // 滑动手势
  let slideGestureHandler: SlideGestureHandler
  weak var ivc: HamsterKeyboardViewController?
  var gestureEndAction: KeyboardAction.GestureAction?
  
  init(inputViewController ivc: HamsterKeyboardViewController) {
    weak var input = ivc
    self.ivc = input
    
    var keyboardActionExtendConfig: [String: String] = [:]
    if let dict = input?.actionExtend.dict {
      for (key, value) in dict {
        if let value = value as? String {
          keyboardActionExtendConfig[(key as! String).lowercased()] = value
        }
      }
    }
    
    self.slideGestureHandler = CharacterSlideGestureHandler(
      config: keyboardActionExtendConfig,
      rimeEngine: self.ivc?.rimeEngine
    )
    
    super.init(inputViewController: ivc)
  }
  
  /**
   Whether or not the action handler can be used to handle
   a certain `gesture` on a certain `action`.
   */
  override func canHandle(_ gesture: KeyboardGesture, on action: KeyboardAction) -> Bool {
    self.action(for: gesture, on: action) != nil
  }

  override func action(for gesture: KeyboardGesture, on action: KeyboardAction) -> KeyboardAction.GestureAction? {
    // 手势完成信号
    if gesture == .tap && action == .custom(named: KeyboardConstant.Action.endDragGesture) {
      return gestureEndAction
    }
    
    if let action = action.hamsterStanderAction(for: gesture) {
      return action(ivc)
    }
    
    return nil
  }

  override func handle(_ gesture: KeyboardKit.KeyboardGesture, on action: KeyboardKit.KeyboardAction) {
    // triggerFeedback(for: gesture, on: action)
    
    guard let gestureAction = self.action(for: gesture, on: action) else { return }
    
    // tryRemoveAutocompleteInsertedSpace(before: gesture, on: action)
    // tryApplyAutocompleteSuggestion(before: gesture, on: action)
    
    gestureAction(.shared)
    
    // tryReinsertAutocompleteRemovedSpace(after: gesture, on: action)
    // tryEndSentence(after: gesture, on: action)
    // tryChangeKeyboardType(after: gesture, on: action)
    // tryRegisterEmoji(after: gesture, on: action)
    
    autocompleteAction()
  }

  override func handleDrag(on action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint) {
    switch action {
    case .space: spaceDragGestureHandler.handleDragGesture(from: startLocation, to: currentLocation)
    case .character:
      gestureEndAction = slideGestureHandler.handleDragGesture(action: action, from: startLocation, to: currentLocation)
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
