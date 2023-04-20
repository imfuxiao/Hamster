import KeyboardKit
import SwiftUI

class HamsterKeyboardActionHandler: StandardKeyboardActionHandler {
  public weak var hamsterKeyboardController: HamsterKeyboardViewController?

  // 其他按键滑动处理
  public let characterDragActionHandler: SlideGestureHandler
  public let appSettings: HamsterAppSettings
  public let rimeEngine: RimeEngine

  // 键盘上下滑动处理
  let characterDragAction: (HamsterKeyboardViewController) -> ((KeyboardAction, Int) -> Void) = { keyboardController in
    weak var ivc = keyboardController
    guard let ivc = ivc else { return { _, _ in } }
    let actionConfig: [String: String] = ivc.appSettings.keyboardUpAndDownSlideSymbol
    return { [weak ivc] action, offset in
      if case .character(let char) = action {
        let actionKey = offset < 0 ?
          char.lowercased() + KeyboardConstant.Character.SlideDown :
          char.lowercased() + KeyboardConstant.Character.SlideUp

        guard let value = actionConfig[actionKey] else {
          return
        }

        guard let ivc = ivc else { return }

        // TODO: 以#开头为功能
        if value.hasPrefix("#"), value.count > 1 {
          let function = SlideFunction(rawValue: value)
          switch function {
          case .SimplifiedTraditionalSwitch:
            ivc.switchTraditionalSimplifiedChinese()
          case .ChineseEnglishSwitch:
            ivc.switchEnglishChinese()
          case .SelectSecond:
            _ = ivc.secondCandidateTextOnScreen()
          case .BeginOfSentence:
            ivc.moveBeginOfSentence()
          case .EndOfSentence:
            ivc.moveEndOfSentence()
          default:
            break
          }
          return
        }

        // TODO: 字符处理
        if value.count > 1 {
          ivc.textDocumentProxy.insertText(value)
          if value.count > 1 {
            ivc.adjustTextPosition(byCharacterOffset: -1)
          }
        } else {
          ivc.insertText(value)
        }
      }
    }
  }

  public init(
    inputViewController ivc: HamsterKeyboardViewController,
    keyboardContext: KeyboardContext,
    keyboardFeedbackHandler: KeyboardFeedbackHandler
  ) {
    weak var keyboardController = ivc
    self.hamsterKeyboardController = keyboardController
    self.appSettings = ivc.appSettings
    self.rimeEngine = ivc.rimeEngine
    self.characterDragActionHandler = CharacterDragHandler(
      keyboardContext: keyboardContext,
      feedbackHandler: keyboardFeedbackHandler,
      action: characterDragAction(ivc)
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
          ivc?.adjustTextPosition(byCharacterOffset: $0 > 0 ? 1 : -1)
        }
      ),
      spaceDragSensitivity: .medium
    )
  }

  override func action(for gesture: KeyboardGesture, on action: KeyboardAction) -> KeyboardAction
    .GestureAction?
  {
    if let hamsterAction = action.hamsterStanderAction(for: gesture) {
      return hamsterAction
    }
    return nil
  }

  override func handle(
    _ gesture: KeyboardKit.KeyboardGesture, on action: KeyboardKit.KeyboardAction
  ) {
    handle(gesture, on: action, replaced: false)
  }

  override func handle(_ gesture: KeyboardGesture, on action: KeyboardAction, replaced: Bool) {
    if !replaced && tryHandleReplacementAction(before: gesture, on: action) { return }
    triggerFeedback(for: gesture, on: action)
    guard let gestureAction = self.action(for: gesture, on: action) else { return }
    gestureAction(keyboardController)
    // TODO: 这里可以添加中英自动加入空格等特性
    // tryReinsertAutocompleteRemovedSpace(after: gesture, on: action)
    // tryEndSentence(after: gesture, on: action)
    // 这里改变键盘类型: 比如双击, 不能在KeyboardAction+Action那里改
    tryChangeKeyboardType(after: gesture, on: action)
  }

  /**
   Try to change `keyboardType` after a `gesture` has been
   performed on the provided `action`.
   */
  override func tryChangeKeyboardType(after gesture: KeyboardGesture, on action: KeyboardAction) {
    guard keyboardBehavior.shouldSwitchToPreferredKeyboardType(after: gesture, on: action) else { return }
    let newType = keyboardBehavior.preferredKeyboardType(after: gesture, on: action)
    keyboardContext.keyboardType = newType
  }

  override func triggerFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) {
    guard shouldTriggerFeedback(for: gesture, on: action) else { return }
    keyboardFeedbackHandler.triggerFeedback(for: gesture, on: action)
  }

  override func handleDrag(
    on action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint
  ) {
    switch action {
    case .space:
      if appSettings.slideBySpaceButton {
        if appSettings.enableInputEmbeddedMode && !rimeEngine.userInputKey.isEmpty {
          return
        }
        triggerFeedback(for: .longPress, on: action)
        spaceDragGestureHandler.handleDragGesture(from: startLocation, to: currentLocation)
      }
    case .character:
      if appSettings.enableKeyboardUpAndDownSlideSymbol {
        characterDragActionHandler.handleDragGesture(action: action, from: startLocation, to: currentLocation)
      }
    default: break
    }
  }
}
