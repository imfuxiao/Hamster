import KeyboardKit

class HamsterActionCalloutContext: ActionCalloutContext {
  
  // 手势结束触发一个自定义完成手势
  override func endDragGesture() {
    actionHandler.handle(.tap, on: .custom(named: KeyboardConstant.Action.endDragGesture))
    super.endDragGesture()
  }
}
