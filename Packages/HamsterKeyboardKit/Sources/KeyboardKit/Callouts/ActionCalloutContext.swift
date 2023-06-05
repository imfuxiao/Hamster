//
//  ActionCalloutContext.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Combine
import UIKit

/**
 This context can be used to handle callouts that show a set
 of secondary actions for various keyboard actions.
 
 该上下文可用于处理为各种键盘操作显示一组辅助操作的呼出。
  
 You can inherit this class and override any open properties
 and functions to customize the standard behavior.
 
 您可以继承该类，并覆盖任何 open 权限属性和函数，以自定义标准行为。
 */
open class ActionCalloutContext: ObservableObject {
  public static let coordinateSpace = "com.keyboardkit.coordinate.ActionCallout"
  
  // MARK: - Dependencies 依赖
    
  /// The action handler to use when tapping buttons.
  ///
  /// 点击按键时使用的 Action 处理程序。
  public let actionHandler: KeyboardActionHandler

  /// The action provider to use for resolving callout actions.
  ///
  /// 用于解析呼出操作的 Action 提供程序。
  public let actionProvider: CalloutActionProvider
    
  // MARK: - Published Properties
    
  /**
   The action that are currently active for the context.
   
   当前上下文处于激活状态的操作列表。
   */
  @Published
  public private(set) var actions: [KeyboardAction] = []
    
  /**
   The callout bubble alignment.
   
   呼出气泡的对齐方式。
   */
  @Published
  public private(set) var alignment: NSRectAlignment = .leading
    
  /**
   The frame of the currently pressed keyboard button.
   
   当前按下的键盘按键的 frame。
   */
  @Published
  public private(set) var buttonFrame: CGRect = .zero
    
  /**
   The currently selected action index.
   
   当前选择的 action 索引。
   */
  @Published
  public private(set) var selectedIndex: Int = -1
  
  // MARK: - Properties
    
  /**
   Whether or not the context has a selected action.
   
   是否有选定的操作。
   */
  public var hasSelectedAction: Bool { selectedAction != nil }
    
  /**
   Whether or not the context has any current actions.
   
   上下文中是否有任何当前的操作。
   */
  public var isActive: Bool { !actions.isEmpty }
    
  /**
   Whether or not the action callout alignment is leading.
   
   操作呼出对齐方式是否为 leading
   */
  public var isLeading: Bool { !isTrailing }
    
  /**
   Whether or not the action callout alignment is trailing.
   
   操作呼出对齐方式是否为 trailing
   */
  public var isTrailing: Bool { alignment == .trailing }
    
  /**
   The currently selected callout action, which updates as
   the user swipes left and right.
   
   获取用户当前选择的呼出操作，此操作在用户左右划动时会更新。
   */
  public var selectedAction: KeyboardAction? {
    isIndexValid(selectedIndex) ? actions[selectedIndex] : nil
  }

  // MARK: - Initialization
    
  /**
   Create a new action callout context instance.
     
   - Parameters:
     - actionHandler: The action handler to use when tapping buttons.
     - actionProvider: The action provider to use for resolving callout actions.
   */
  public init(
    actionHandler: KeyboardActionHandler,
    actionProvider: CalloutActionProvider
  ) {
    self.actionHandler = actionHandler
    self.actionProvider = actionProvider
  }
  
  // MARK: - Functions
    
  /**
   Handle the end of the drag gesture, which should commit
   the selected action and reset the context.
   
   处理拖动手势的结束，即提交所选 action 并重置上下文。
   */
  open func endDragGesture() {
    handleSelectedAction()
    reset()
  }
    
  /**
   Handle the selected action, if any. By default, it will
   be handled by the context's action handler.
   
   处理选定的操作（如果有）。
   默认情况下，将由上下文的 actionHandler 来处理。
   */
  open func handleSelectedAction() {
    guard let action = selectedAction else { return }
    actionHandler.handle(.release, on: action)
  }
    
  /**
   Reset the context, which will reset all state and cause
   any callouts to dismiss.
   
   重置上下文，这将重置所有状态，并导致所有呼出取消。
   */
  open func reset() {
    actions = []
    selectedIndex = -1
    buttonFrame = .zero
  }
    
  /**
   Trigger a haptic feedback for selection change. You can
   override this to change or disable the haptic feedback.
   
   在选择更改时触发触觉反馈。您可以覆盖此选项，更改或禁用触觉反馈。
   */
  open func triggerHapticFeedbackForSelectionChange() {
    // TODO: 添加触觉反馈逻辑
    // HapticFeedback.selectionChanged.trigger()
  }
    
  /**
   Update the input actions for a certain keyboard action.
   
   更新某个键盘操作的输入操作。
   */
//  open func updateInputs(for action: KeyboardAction?, in geo: GeometryProxy, alignment: HorizontalAlignment? = nil) {
//    guard let action = action else { return reset() }
//    let actions = actionProvider.calloutActions(for: action)
//    buttonFrame = geo.frame(in: .named(Self.coordinateSpace))
//    self.alignment = alignment ?? getAlignment(for: geo)
//    self.actions = isLeading ? actions : actions.reversed()
//    selectedIndex = startIndex
//    guard isActive else { return }
//    triggerHapticFeedbackForSelectionChange()
//  }

  /**
   Update the selected input action when a drag gesture is
   changed by a drag gesture.
   
   当拖动手势被拖动手势改变时，更新选定的输入操作。
   */
//  open func updateSelection(with dragTranslation: CGSize?) {
//    guard let value = dragTranslation, buttonFrame != .zero else { return }
//    if shouldReset(for: value) { return reset() }
//    guard shouldUpdateSelection(for: value) else { return }
//    let translation = value.width
//    let standardStyle = KeyboardActionCalloutStyle.standard
//    let maxButtonSize = standardStyle.maxButtonSize
//    let buttonSize = buttonFrame.size.limited(to: maxButtonSize)
//    let indexWidth = 0.9 * buttonSize.width
//    let offset = Int(abs(translation) / indexWidth)
//    let index = isLeading ? offset : actions.count - offset - 1
//    let currentIndex = selectedIndex
//    let newIndex = isIndexValid(index) ? index : startIndex
//    if currentIndex != newIndex { triggerHapticFeedbackForSelectionChange() }
//    selectedIndex = newIndex
//  }
}

// MARK: - Public functionality

public extension ActionCalloutContext {
  static var disabled: ActionCalloutContext {
    ActionCalloutContext(
      actionHandler: PreviewKeyboardActionHandler(),
      actionProvider: DisabledCalloutActionProvider()
    )
  }
}

// MARK: - Private functionality

private extension ActionCalloutContext {
  var startIndex: Int {
    isLeading ? 0 : actions.count - 1
  }
    
  func isIndexValid(_ index: Int) -> Bool {
    index >= 0 && index < actions.count
  }
    
//  func getAlignment(for geo: GeometryProxy) -> HorizontalAlignment {
//    #if os(iOS)
//    let center = UIScreen.main.bounds.size.width / 2
//    let isTrailing = buttonFrame.origin.x > center
//    return isTrailing ? .trailing : .leading
//    #else
//    return .leading
//    #endif
//  }

  func shouldReset(for dragTranslation: CGSize) -> Bool {
    dragTranslation.height > buttonFrame.height
  }
    
  func shouldUpdateSelection(for dragTranslation: CGSize) -> Bool {
    let translation = dragTranslation.width
    if translation == 0 { return true }
    return isLeading ? translation > 0 : translation < 0
  }
}
