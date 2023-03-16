import KeyboardKit
import SwiftUI

class HamsterKeyboardActionHandler: StandardKeyboardActionHandler {
  public weak var hamsterKeyboardController: HamsterKeyboardViewController?

  // 滑动手势
  let slideGestureHandler: SlideGestureHandler
  // 滑动手势EndAction
  var dragGestureEndAction: KeyboardAction.GestureAction?

  public init(inputViewController ivc: HamsterKeyboardViewController) {
    self.hamsterKeyboardController = ivc
    self.slideGestureHandler = CharacterSlideGestureHandler(
      config: ivc.actionExtend.strDict,
      rimeEngine: ivc.rimeEngine
    )

    super.init(
      keyboardController: ivc,
      keyboardContext: ivc.keyboardContext,
      keyboardBehavior: ivc.keyboardBehavior,
      keyboardFeedbackHandler: ivc.keyboardFeedbackHandler,
      autocompleteContext: ivc.autocompleteContext,
      spaceDragGestureHandler: SpaceCursorDragGestureHandler(
        keyboardContext: ivc.keyboardContext,
        feedbackHandler: ivc.keyboardFeedbackHandler,
        action: { [weak ivc] in
          ivc?.keyboardContext.textDocumentProxy.adjustTextPosition(byCharacterOffset: $0)
        }
      ),
      spaceDragSensitivity: .medium
    )
  }

  override func action(for gesture: KeyboardGesture, on action: KeyboardAction) -> KeyboardAction
    .GestureAction?
  {
    if let hamsterAction = action.hamsterStanderAction(for: gesture) {
      triggerFeedback(for: gesture, on: action)
      return hamsterAction(hamsterKeyboardController)
    }
    return nil
  }

  override func handle(
    _ gesture: KeyboardKit.KeyboardGesture, on action: KeyboardKit.KeyboardAction
  ) {
    guard let gestureAction = self.action(for: gesture, on: action) else { return }
    gestureAction(keyboardController)
  }

  override func triggerFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) {
    keyboardFeedbackHandler.triggerFeedback(for: gesture, on: action)
  }

  override func handleDrag(
    on action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint
  ) {
    switch action {
    case .space:
      if hamsterKeyboardController?.appSettings.slideBySapceButton ?? true {
        spaceDragGestureHandler.handleDragGesture(from: startLocation, to: currentLocation)
      }
    case .character:
      // TODO: 只有字母类型键盘开启滑动手势
      if keyboardContext.keyboardType.isAlphabetic {
        dragGestureEndAction = slideGestureHandler.handleDragGesture(
          action: action, from: startLocation, to: currentLocation
        )
      }
    default: break
    }
  }
}
