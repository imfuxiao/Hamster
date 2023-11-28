//
//  StandardKeyboardActionHandler.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-04-24.
//  Copyright © 2019-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This standard keyboard action handler is used by default by
 KeyboardKit and provides a standard way of handling actions.

 KeyboardKit 默认使用此标准键盘操作处理程序，并提供了一种标准的操作处理方式。

 You can inherit this class and override any open properties
 and functions to customize the standard action behavior.

 您可以继承该类并覆盖任何 open 属性和函数，以自定义标准操作行为。
 */
open class StandardKeyboardActionHandler: NSObject, KeyboardActionHandler {
  // MARK: - Properties

  /// The controller to which this handler applies.
  public weak var keyboardController: KeyboardController?
  public let autocompleteContext: AutocompleteContext
  public let keyboardBehavior: KeyboardBehavior
  public let keyboardContext: KeyboardContext
  public let keyboardFeedbackHandler: KeyboardFeedbackHandler
  public let spaceDragGestureHandler: DragGestureHandler

  public var textDocumentProxy: UITextDocumentProxy { keyboardContext.textDocumentProxy }

  /// 空格拖动手势是否激活
  public var isSpaceDragGestureActive = false

  /// 空格拖动手势的激活位置
  private var spaceDragActivationLocation: CGPoint?
  private var rimeContext: RimeContext

  // MARK: - Initialization

  /**
   Create a standard keyboard action handler, using a view
   controller to setup all dependencies.

   创建一个标准键盘操作处理程序，使用 InputViewController 设置所有依赖关系。

   - Parameters:
     - inputViewController: The view controller to use.
     - keyboardContext: The keyboard context to use.
     - keyboardBehavior: The keyboard behavior to use.
     - keyboardFeedbackHandler: The keyboard feedback handler to use.
     - autocompleteContext: The autocomplete context to use.
     - spaceDragGestureHandler: A custom space drag gesture handler to use, if any.
   */
  public init(
    controller: KeyboardController?,
    keyboardContext: KeyboardContext,
    rimeContext: RimeContext,
    keyboardBehavior: KeyboardBehavior,
    autocompleteContext: AutocompleteContext,
    keyboardFeedbackHandler: KeyboardFeedbackHandler,
    spaceDragGestureHandler: DragGestureHandler
  ) {
    weak var weakController = controller
    self.keyboardController = weakController
    self.keyboardContext = keyboardContext
    self.keyboardBehavior = keyboardBehavior
    self.autocompleteContext = autocompleteContext
    self.keyboardFeedbackHandler = keyboardFeedbackHandler
    self.spaceDragGestureHandler = spaceDragGestureHandler
    self.rimeContext = rimeContext
  }

  // MARK: - Implementation KeyboardActionHandler Protocol

  /**
   Whether or not the handler can handle a certain gesture
   on a certain action.

   处理程序是否可以处理某个操作上的某个手势。
   */
  open func canHandle(_ gesture: KeyboardGesture, on action: KeyboardAction) -> Bool {
    self.action(for: gesture, on: action) != nil
  }

  /**
   Handle a certain action using its standard action.

   使用标准操作处理逻辑, 处理某个操作。
   */
  public func handle(_ action: KeyboardAction) {
    action.standardAction?(keyboardController)
  }

  /**
   Handle a certain gesture on a certain action.

   处理某个操作上的某个手势。
   */
  open func handle(_ gesture: KeyboardGesture, on action: KeyboardAction) {
    handle(gesture, on: action, replaced: false)
  }

  /**
   Handle a certain gesture on a certain action.

   处理某个操作上做出某种手势。

   This function is used to handle a case where the action
   can be triggered as a replacement of another operation.

   该函数用于处理可取代其他操作而触发 action 的情况。
   */
  open func handle(_ gesture: KeyboardGesture, on action: KeyboardAction, replaced: Bool) {
    // 不能被取代 && 尝试处理取代Action
    // 注意：是 if 不是 guard
    if !replaced && tryHandleReplacementAction(before: gesture, on: action) { return }
    triggerFeedback(for: gesture, on: action)
    tryUpdateSpaceDragState(for: gesture, on: action)
    guard let gestureAction = self.action(for: gesture, on: action) else { return }
    // tryRemoveAutocompleteInsertedSpace(before: gesture, on: action)
    // tryApplyAutocompleteSuggestion(before: gesture, on: action)
    gestureAction(keyboardController)
    // tryReinsertAutocompleteRemovedSpace(after: gesture, on: action)
    // tryEndSentence(after: gesture, on: action)
    tryChangeKeyboardType(after: gesture, on: action)
    tryRegisterEmoji(after: gesture, on: action)
    tryRegisterSymbol(after: gesture, on: action)
    // keyboardController?.performAutocomplete()
    keyboardController?.performTextContextSync()
  }

  /**
   处理 key 上的某个手势
   */
  open func handle(_ gesture: KeyboardGesture, on key: Key) {
    let action = key.action

    // 不能被取代 && 尝试处理取代Action
    // 注意：是 if 不是 guard
    if tryHandleReplacementAction(before: gesture, on: action) { return }
    triggerFeedback(for: gesture, on: action)
    tryUpdateSpaceDragState(for: gesture, on: action)
    guard let gestureAction = self.action(for: gesture, on: key) else { return }
    // tryRemoveAutocompleteInsertedSpace(before: gesture, on: action)
    // tryApplyAutocompleteSuggestion(before: gesture, on: action)
    gestureAction(keyboardController)
    // tryReinsertAutocompleteRemovedSpace(after: gesture, on: action)
    // tryEndSentence(after: gesture, on: action)
    tryChangeKeyboardType(after: gesture, on: action)
    tryRegisterEmoji(after: gesture, on: action)
    tryRegisterSymbol(after: gesture, on: action)
    // keyboardController?.performAutocomplete()
    keyboardController?.performTextContextSync()
  }

  /// 处理 key 上的手势及动作
  open func action(for gesture: KeyboardGesture, on key: Key) -> KeyboardAction.GestureAction? {
    return key.action.standardAction(for: gesture, processByRIME: key.processByRIME)
  }

  /**
   Handle a drag gesture on a certain action.

   处理特定操作上的拖动手势。
   */
  open func handleDrag(on action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint) {
    tryHandleSpaceDrag(on: action, from: startLocation, to: currentLocation)
  }

  // MARK: - Open Functions

  /**
   This is the standard action that is used by the handler
   when a gesture is performed on a certain action.

   这是处理程序在某个操作上执行手势时使用的标准动作。

   You can override this function to customize how actions
   should behave. By default, the standard action is used.

   您可以覆盖此函数，自定义操作的行为方式。默认情况下，使用标准动作。
   */
  open func action(for gesture: KeyboardGesture, on action: KeyboardAction) -> KeyboardAction.GestureAction? {
    if keyboardContext.keyboardType.isAlphabetic {
      return action.standardAction(for: gesture, processByRIME: false)
    }
    return action.standardAction(for: gesture)
  }

  /**
   Try to resolve a replacement keyboard action before the
   `gesture` is performed on the provided `action`.

   在对提供的某种 `action` 上执行的某种 `gesture` 之前，尝试解析替并替换键盘操作。

   You can override this function to customize how actions
   should be replaced.

   您可以覆盖此功能，自定义替换操作的方式。
   */
  open func replacementAction(for gesture: KeyboardGesture, on action: KeyboardAction) -> KeyboardAction? {
    guard gesture == .release else { return nil }

    // Apply proxy-based replacements, if any
    // 应用基于代理的替换（如果有）
//    if case let .character(char) = action,
//       let replacement = textDocumentProxy.preferredQuotationReplacement(
//         whenInserting: char,
//         for: keyboardContext.locale
//       )
//    {
//      return .character(replacement)
//    }

    return nil
  }

  /**
   Whether or not a feedback should be given for a certain
   gesture on a certain action.

   是否应对某个操作 `action` 上的某个手势 `gesture` 给出反馈。

   You can override this function to customize how actions
   trigger feedback.

   您可以覆盖此功能，自定义操作如何触发反馈。
   */
  open func shouldTriggerFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) -> Bool {
    // 注意：是重复手势状态下，光标前无内容时，或用户无代上屏文字时，不触发反馈
    if gesture == .repeatPress && action == .backspace {
      return !rimeContext.userInputKey.isEmpty || keyboardContext.textDocumentProxy.documentContextBeforeInput != nil
    }
    if gesture.isSwipe { return false }
    if gesture == .press && self.action(for: .release, on: action) != nil { return true }
    if gesture != .release && self.action(for: gesture, on: action) != nil { return true }
    return false
  }

  /**
   Trigger feedback for a certain `gesture` on an `action`,
   if ``shouldTriggerFeedback(for:on:)`` returns `true`.

   如果 ``shouldTriggerFeedback(for:on:)`` 返回 `true`，就会触发对某个操作的反馈。

   You can override this function to customize how actions
   trigger feedback.

   您可以覆盖此功能，自定义操作如何触发反馈。
   */
  open func triggerFeedback(for gesture: KeyboardGesture, on action: KeyboardAction) {
    guard shouldTriggerFeedback(for: gesture, on: action) else { return }
    keyboardFeedbackHandler.triggerFeedback(for: gesture, on: action)
  }

  /**
   Try to apply an `isAutocomplete` autocomplete suggestion
   before the `gesture` has been performed on the `action`.

   尝试在对特定操作 `action` 上执行某个手势 `gesture` 之前应用 `isAutocomplete` 自动完成 suggestion。
   */
  open func tryApplyAutocompleteSuggestion(before gesture: KeyboardGesture, on action: KeyboardAction) {
    if isSpaceCursorDrag(action) { return }
    if textDocumentProxy.isCursorAtNewWord { return }
    guard gesture == .release else { return }
    guard action.shouldApplyAutocompleteSuggestion else { return }
    guard let suggestion = (autocompleteContext.suggestions.first { $0.isAutocomplete }) else { return }
    textDocumentProxy.insertAutocompleteSuggestion(suggestion, tryInsertSpace: false)
  }

  /**
   Try to change `keyboardType` after a `gesture` has been
   performed on the provided `action`.

   在对所提供的操作 `action` 执行了手势 `gesture` 后，尝试更改 `keyboardType` 键盘类型。
   */
  open func tryChangeKeyboardType(after gesture: KeyboardGesture, on action: KeyboardAction) {
    guard keyboardBehavior.shouldSwitchToPreferredKeyboardType(after: gesture, on: action) else { return }
    let newType = keyboardBehavior.preferredKeyboardType(after: gesture, on: action)
    keyboardContext.setKeyboardType(newType)
  }

  /**
   Try to end the current sentence after the `gesture` has
   been performed on the provided `action`.

   在对所提供的 `action` 执行 `gesture` 后，尝试结束当前句子。
   */
  open func tryEndSentence(after gesture: KeyboardGesture, on action: KeyboardAction) {
    guard keyboardBehavior.shouldEndSentence(after: gesture, on: action) else { return }
    textDocumentProxy.endSentence()
  }

  /**
   Try to resolve and handle a replacement keyboard action
   before the `gesture` is performed on the `action`.

   在对某个 `action` 上执行的某个 `gesture` 之前，尝试解决并替换键盘操作。

   When this returns true, the caller should stop handling
   the provided action.

   返回 true 时，调用者应停止处理所提供的操作。
   */
  open func tryHandleReplacementAction(before gesture: KeyboardGesture, on action: KeyboardAction) -> Bool {
    guard let action = replacementAction(for: gesture, on: action) else { return false }
    handle(.release, on: action, replaced: true)
    return true
  }

  /**
   Try to register a certain emoji after the `gesture` has
   been performed on the provided `action`.

   在对提供的操作 `action` 上执行某个 `gesture` 后，尝试注册某个表情符号。
   */
  open func tryRegisterEmoji(after gesture: KeyboardGesture, on action: KeyboardAction) {
    guard gesture == .release else { return }
    switch action {
    case let .emoji(emoji): return EmojiCategory.frequentEmojiProvider.registerEmoji(emoji)
    default: return
    }
  }

  open func tryRegisterSymbol(after gesture: KeyboardGesture, on action: KeyboardAction) {
    guard gesture == .release else { return }
    switch action {
    case let .symbol(symbol): return SymbolCategory.frequentSymbolProvider.registerSymbol(symbol)
    default: return
    }
  }

  /**
   Try to reinsert an automatically removed space that was
   removed due to autocomplete after the provided `gesture`
   has been performed on the provided `action`.

   在对所提供的 `action` 执行所提供的 `gesture` 之后，
   尝试重新插入由于自动完成而自动删除的空格。
   */
  open func tryReinsertAutocompleteRemovedSpace(after gesture: KeyboardGesture, on action: KeyboardAction) {
    guard gesture == .release else { return }
    guard action.shouldReinsertAutocompleteInsertedSpace else { return }
    textDocumentProxy.tryReinsertAutocompleteRemovedSpace()
  }

  /**
   Try to removed an autocomplete inserted space after the
   `gesture` has been performed on the provided `action`.

   在对提供的 `action` 执行 `gesture` 手势操作后，尝试删除自动完成插入的空格。
   */
  open func tryRemoveAutocompleteInsertedSpace(before gesture: KeyboardGesture, on action: KeyboardAction) {
    guard gesture == .release else { return }
    guard action.shouldRemoveAutocompleteInsertedSpace else { return }
    textDocumentProxy.tryRemoveAutocompleteInsertedSpace()
  }
}

extension StandardKeyboardActionHandler {
  /// 拖动手势处理
  static func dragGestureHandler(
    keyboardController: KeyboardController,
    keyboardContext: KeyboardContext,
    keyboardFeedbackHandler: KeyboardFeedbackHandler,
    spaceDragSensitivity: SpaceDragSensitivity
  ) -> SpaceCursorDragGestureHandler {
    weak var controller = keyboardController
    weak var context = keyboardContext
    return .init(
      feedbackHandler: keyboardFeedbackHandler,
      sensitivity: spaceDragSensitivity,
      action: {
        let offset = context?.textDocumentProxy.spaceDragOffset(for: $0)
        controller?.adjustTextPosition(byCharacterOffset: offset ?? $0)
      }
    )
  }
}

private extension StandardKeyboardActionHandler {
  /// 是否为空格移动光标操作
  func isSpaceCursorDrag(_ action: KeyboardAction) -> Bool {
    guard action == .space else { return false }
    guard let handler = spaceDragGestureHandler as? SpaceCursorDragGestureHandler else { return false }
    return handler.currentDragTextPositionOffset != 0
  }

  /// 尝试处理空格拖动操作
  func tryHandleSpaceDrag(on action: KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint) {
    guard action == .space else { return }
    guard keyboardContext.spaceLongPressBehavior == .moveInputCursor else { return }
    guard isSpaceDragGestureActive else { return }
    let activationLocation = spaceDragActivationLocation ?? currentLocation
    spaceDragActivationLocation = activationLocation
    spaceDragGestureHandler.handleDragGesture(
      from: activationLocation,
      to: currentLocation
    )
  }

  /// 尝试更新空格拖动操作状态
  func tryUpdateSpaceDragState(for gesture: KeyboardGesture, on action: KeyboardAction) {
    guard action == .space else { return }
    switch gesture {
    case .press:
      isSpaceDragGestureActive = false
      spaceDragActivationLocation = nil
    case .longPress:
      isSpaceDragGestureActive = true
    default: return
    }
  }
}
