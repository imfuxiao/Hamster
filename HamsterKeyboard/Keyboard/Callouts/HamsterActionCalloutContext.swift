import KeyboardKit

class HamsterActionCalloutContext: ActionCalloutContext {
  // 手势结束触发一个自定义完成手势
  override func endDragGesture() {
    if let action = actionHandler as? HamsterKeyboardActionHandler {
      action.characterDragActionHandler.endDragGesture()
    }
    super.endDragGesture()
  }
}
