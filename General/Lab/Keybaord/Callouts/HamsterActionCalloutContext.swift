import KeyboardKit
import SwiftUI

class HamsterActionCalloutContext: ActionCalloutContext {
  typealias CalloutAction = (KeyboardContext) -> Void

  init(keyboardContext: KeyboardContext, actionHandler: KeyboardActionHandler, actionProvider: CalloutActionProvider) {
    self.keyboardContext = keyboardContext
    super.init(actionHandler: actionHandler, actionProvider: actionProvider)
  }

  var keyboardContext: KeyboardContext
  var calloutAction: CalloutAction?

  /**
   手势结束触发一个自定义完成手势
   */
  override func endDragGesture() {
    super.endDragGesture()
    if let action = actionHandler as? HamsterKeyboardActionHandler {
      Logger.shared.log.debug("HamsterActionCalloutContext.endDragGesture()")
      action.swipeGestureHandler.endDragGesture()
    }
    calloutAction?(keyboardContext)
    calloutAction = nil
  }

  /**
   Update the input actions for a certain keyboard action.
   更新某个键盘动作的InputAction
   */
//  override func updateInputs(for action: KeyboardAction?, in geo: GeometryProxy, alignment: HorizontalAlignment? = nil) {
//    guard let action = action else { return reset() }
//    let actions = actionProvider.calloutActions(for: action)
//    self.buttonFrame = geo.frame(in: .named(Self.coordinateSpace))
//    self.alignment = alignment ?? getAlignment(for: geo)
//    self.actions = isLeading ? actions : actions.reversed()
//    self.selectedIndex = startIndex
//    guard isActive else { return }
//    triggerHapticFeedbackForSelectionChange()
//  }
}
