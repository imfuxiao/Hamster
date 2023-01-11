import CoreGraphics
import KeyboardKit

class CharacterSlideGestureHandler: SlideGestureHandler {
  private let characterSwipeConfig: [String: String] = [:]
  public let context: KeyboardContext
  private let sensitivity: CharacterSlideSensitivity
  
  var slideUp: String {
    KeyboardConstant.Character.SlideUp
  }
  
  var slideDown: String {
    KeyboardConstant.Character.SlideDown
  }
  
  init(context: KeyboardContext, sensitivity: CharacterSlideSensitivity = .high) {
    self.sensitivity = sensitivity
    self.context = context
  }
  
  func handleDragGesture(action: KeyboardKit.KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint) {
    guard case let .character(char) = action else {
      return
    }
    
    // 上下滑动只关心Y轴, 且滑动距离需要大于设置的敏感度
    let slideYDelta = startLocation.y - currentLocation.y
    if abs(slideYDelta) > CGFloat(sensitivity.points) {
      return
    }
    
    let actionKey = slideYDelta > 0 ? char + slideDown : char + slideUp
    
    if let value = characterSwipeConfig[actionKey] {
      // TODO: 对于#开头的action, 如中英切换, 简繁切换等需要处理
      if !value.hasPrefix("#") {
        context.textDocumentProxy.insertText(value)
      }
    }
  }
}
