import KeyboardKit
import SwiftUI

class HamsterKeyboardActionHandler: StandardKeyboardActionHandler {
  public weak var hamsterKeyboardController: HamsterKeyboardViewController?

  // 其他按键滑动处理
  public let characterGragActionHandler: SlideGestureHandler

  // 字符滑动处理
  let characterGragAction: (HamsterKeyboardViewController) -> ((KeyboardAction, Int) -> Void) = { ivc in
    let actionConfig: [String: String] = ivc.actionExtend.strDict
    let rimeEngine = ivc.rimeEngine
    let keyboardContext = ivc.keyboardContext

    return { action, offset in
      if case .character(let char) = action {
        let actionKey = offset < 0 ?
          char.lowercased() + KeyboardConstant.Character.SlideDown :
          char.lowercased() + KeyboardConstant.Character.SlideUp

        guard let value = actionConfig[actionKey] else {
          return
        }

        // TODO: 以#开头为功能
        if value.hasPrefix("#"), value.count > 1 {
          let function = KeyboardConstant.Fuction(rawValue: value)
          switch function {
          case .SimplifiedTraditionalSwitch:
            let status = rimeEngine.status()
            _ = rimeEngine.simplifiedChineseMode(status.isSimplified)
          case .ChineseEnglishSwitch:
            let status = rimeEngine.status()
            _ = rimeEngine.asciiMode(!status.isASCIIMode)
          case .SelectSecond:
            let status = rimeEngine.status()
            if status.isComposing {
              let candidates = rimeEngine.context().candidates
              if candidates != nil && candidates!.isEmpty {
                break
              }
              if candidates!.count == 2 {
                keyboardContext.textDocumentProxy.insertText(candidates![1].text)
                rimeEngine.rest()
              }
            }
          default:
            break
          }
          return
        }
        
        // 字符处理
        ivc.insertText(value)
        if value.count > 1 {
          keyboardContext.textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
        }
      }
    }
  }

  public init(inputViewController ivc: HamsterKeyboardViewController) {
    self.hamsterKeyboardController = ivc

    self.characterGragActionHandler = CharacterDragHandler(
      keyboardContext: ivc.keyboardContext,
      feedbackHandler: ivc.keyboardFeedbackHandler,
      action: characterGragAction(ivc)
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
      characterGragActionHandler.handleDragGesture(action: action, from: startLocation, to: currentLocation)
    default: break
    }
  }
}
