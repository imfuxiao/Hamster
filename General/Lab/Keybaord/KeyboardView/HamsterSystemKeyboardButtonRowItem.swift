//
//  HamsterSystemKeyboardButtonContent.swift
//  Hamster
//
//  Created by morse on 8/5/2023.
//

import KeyboardKit
import SwiftUI

public struct HamsterSystemKeyboardButtonRowItem<Content: View>: View {
  /**
   Create a system keyboard button row item.

   - Parameters:
     - content: The content view to use within the item.
     - item: The layout item to use within the item.
     - actionHandler: The button style to apply.
     - keyboardContext: The keyboard context to which the item should apply.,
     - calloutContext: The callout context to affect, if any.
     - keyboardWidth: The total width of the keyboard.
     - inputWidth: The input width within the keyboard.
     - appearance: The appearance to apply to the item.
   */
  public init(
    content: Content,
    item: KeyboardLayoutItem,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?,
    keyboardWidth: CGFloat,
    inputWidth: CGFloat,
    appearance: KeyboardAppearance,
    isInScrollView: Bool = false,
    customButtonStyle: Bool = false,
    customUseDarkMode: Bool = false
  ) {
    self.content = content
    self.item = item
    self.actionHandler = actionHandler
    self._keyboardContext = ObservedObject(wrappedValue: keyboardContext)
    self.calloutContext = calloutContext
    self.keyboardWidth = keyboardWidth
    self.inputWidth = inputWidth
    self.appearance = appearance as! HamsterKeyboardAppearance
    self.isInScrollView = isInScrollView
    self.customButtonStyle = customButtonStyle
    self.customUseDarkMode = customUseDarkMode
  }

  private let content: Content
  private let item: KeyboardLayoutItem
  private let actionHandler: KeyboardActionHandler
  private let calloutContext: KeyboardCalloutContext?
  private let keyboardWidth: CGFloat
  private let inputWidth: CGFloat
  private let appearance: HamsterKeyboardAppearance
  private let isInScrollView: Bool
  private let customButtonStyle: Bool
  private let customUseDarkMode: Bool

  @ObservedObject
  private var keyboardContext: KeyboardContext

  @State
  private var isPressed = false

  public var body: some View {
    content
      .frame(maxWidth: .infinity)
      .frame(height: item.size.height - item.insets.top - item.insets.bottom)
      .rowItemWidth(for: item, totalWidth: keyboardWidth, referenceWidth: inputWidth)
      .systemKeyboardButtonStyle(
        buttonStyle,
        isPressed: isPressed
      )
      .padding(item.insets)
      .background(Color.clearInteractable)
      .hamsterKeyboardGestures(
        for: item.action,
        actionHandler: actionHandler,
        calloutContext: calloutContext,
        isInScrollView: isInScrollView,
        isPressed: $isPressed
      )
  }
}

private extension HamsterSystemKeyboardButtonRowItem {
  var isScrolling: Bool {
    if let actionHandler = actionHandler as? HamsterKeyboardActionHandler {
      return actionHandler.isScrolling
    }
    return false
  }

  var systemBackgroundColor: Color {
    if customUseDarkMode {
      return Color.hamsterStandardDarkButtonBackground(for: keyboardContext)
    }
    return Color.hamsterStandardButtonBackground(for: keyboardContext)
  }

  var systemForegroundColor: Color {
    if customUseDarkMode {
      return Color.hamsterStandardDarkButtonForeground(for: keyboardContext)
    }
    return Color.hamsterStandardButtonForeground(for: keyboardContext)
  }

  func backgroundColor(_ isPressed: Bool) -> Color {
    if isPressed {
      if customUseDarkMode {
        return .white
      }
      return .hamsterStandardDarkButtonBackground(for: keyboardContext)
    }
    guard let hamsterColorSchema = appearance.hamsterColorSchema else { return systemBackgroundColor }
    return hamsterColorSchema.backColor == .clear ? systemBackgroundColor : hamsterColorSchema.backColor
  }

  var foregroundColor: Color {
    guard let hamsterColorSchema = appearance.hamsterColorSchema else { return systemForegroundColor }
    return hamsterColorSchema.candidateTextColor == .clear ? systemForegroundColor : hamsterColorSchema.candidateTextColor
  }

  var buttonStyle: KeyboardButtonStyle {
    if !customButtonStyle {
      return item.action.isSpacer ? .spacer : appearance.buttonStyle(for: item.action, isPressed: isScrolling ? false : isPressed)
    } else {
      let action = KeyboardAction.primary(.done)
      return KeyboardButtonStyle(
        backgroundColor: backgroundColor(isPressed),
        foregroundColor: foregroundColor,
        font: appearance.buttonFont(for: action),
        cornerRadius: appearance.buttonCornerRadius(for: action),
        border: KeyboardButtonBorderStyle(color: appearance.hamsterColorSchema?.borderColor ?? Color.clear, size: 1),
        shadow: appearance.buttonShadowStyle(for: action)
      )
    }
  }
}

public extension View {
  /**
   Apply a certain layout width to the view, in a way that
   works with the rot item composition above.
   */
  @ViewBuilder
  func rowItemWidth(for item: KeyboardLayoutItem, totalWidth: CGFloat, referenceWidth: CGFloat) -> some View {
    if let width = rowItemWidthValue(for: item, totalWidth: totalWidth, referenceWidth: referenceWidth), width > 0 {
      frame(width: width)
    } else {
      frame(maxWidth: .infinity)
    }
  }

  func shouldApplyLocaleContextMenu(
    for action: KeyboardAction,
    context: KeyboardContext
  ) -> Bool {
    switch action {
    case .nextLocale: return true
    case .space: return context.spaceLongPressBehavior == .openLocaleContextMenu
    default: return false
    }
  }

  @ViewBuilder
  func hamsterKeyboardGestures(
    for action: KeyboardAction,
    actionHandler: KeyboardActionHandler,
    calloutContext: KeyboardCalloutContext?,
    isInScrollView: Bool = false,
    isPressed: Binding<Bool> = .constant(false)
  ) -> some View {
    if action == .nextKeyboard {
      self
    } else {
      hamsterKeyboardGestures(
        action: action,
        calloutContext: calloutContext,
        isInScrollView: isInScrollView,
        isPressed: isPressed,
        doubleTapAction: { actionHandler.handle(.doubleTap, on: action) },
        longPressAction: { actionHandler.handle(.longPress, on: action) },
        pressAction: { actionHandler.handle(.press, on: action) },
        releaseAction: { actionHandler.handle(.release, on: action) },
        repeatAction: { actionHandler.handle(.repeatPress, on: action) },
        dragAction: { start, current in actionHandler.handleDrag(on: action, from: start, to: current) }
      )
    }
  }

  /**
   Apply keyboard-specific gestures to the view, using the
   provided action blocks.

   - Parameters:
     - action: The keyboard action to trigger, by deafult `nil`.
     - calloutContext: The callout context to affect, if any.
     - isInScrollView: Whether or not the gestures are used in a scroll view, by default `false`, by deafult `false`.
     - isPressed: An optional binding that can be used to observe the button pressed state, by deafult `false`.
     - doubleTapAction: The action to trigger when the button is double tapped, by deafult `nil`.
     - longPressAction: The action to trigger when the button is long pressed, by deafult `nil`.
     - pressAction: The action to trigger when the button is pressed, by deafult `nil`.
     - releaseAction: The action to trigger when the button is released, regardless of where the gesture ends, by deafult `nil`.
     - repeatAction: The action to trigger when the button is pressed and held, by deafult `nil`.
     - dragAction: The action to trigger when the button is dragged, by deafult `nil`.
   */
  @ViewBuilder
  func hamsterKeyboardGestures(
    action: KeyboardAction? = nil,
    calloutContext: KeyboardCalloutContext?,
    isInScrollView: Bool = false,
    isPressed: Binding<Bool> = .constant(false),
    doubleTapAction: KeyboardGestureAction? = nil,
    longPressAction: KeyboardGestureAction? = nil,
    pressAction: KeyboardGestureAction? = nil,
    releaseAction: KeyboardGestureAction? = nil,
    repeatAction: KeyboardGestureAction? = nil,
    dragAction: KeyboardDragGestureAction? = nil
  ) -> some View {
    HamsterKeyboardGestures(
      view: self,
      action: action,
      calloutContext: calloutContext,
      isInScrollView: isInScrollView,
      isPressed: isPressed,
      doubleTapAction: doubleTapAction,
      longPressAction: longPressAction,
      pressAction: pressAction,
      releaseAction: releaseAction,
      repeatAction: repeatAction,
      dragAction: dragAction
    )
  }
}

private extension View {
  func rowItemWidthValue(for item: KeyboardLayoutItem, totalWidth: Double, referenceWidth: Double) -> Double? {
    let insets = item.insets.leading + item.insets.trailing
    switch item.size.width {
    case .available: return nil
    case .input: return referenceWidth - insets
    case .inputPercentage(let percent): return percent * referenceWidth - insets
    case .percentage(let percent): return percent * totalWidth - insets
    case .points(let points): return points - insets
    }
  }
}

// struct SystemKeyboardButtonRowItem_Previews: PreviewProvider {
//  static let context: KeyboardContext = {
//    let context = KeyboardContext()
//    context.locales = KeyboardLocale.allCases.map { $0.locale }
//    context.localePresentationLocale = KeyboardLocale.swedish.locale
//    context.spaceLongPressBehavior = .openLocaleContextMenu
//    return context
//  }()
//
//  static func previewItem(
//    _ action: KeyboardAction,
//    width: KeyboardLayoutItemWidth
//  ) -> some View {
//    SystemKeyboardButtonRowItem(
//      content: SystemKeyboardButtonContent(
//        action: action,
//        appearance: .preview,
//        keyboardContext: context
//      ),
//      item: KeyboardLayoutItem(
//        action: action,
//        size: KeyboardLayoutItemSize(
//          width: width,
//          height: 100
//        ),
//        insets: .horizontal(0, vertical: 0)
//      ),
//      actionHandler: .preview,
//      keyboardContext: context,
//      calloutContext: .preview,
//      keyboardWidth: 320,
//      inputWidth: 30,
//      appearance: .preview
//    )
//  }
//
//  static var previews: some View {
//    HStack {
//      previewItem(.character("1"), width: .inputPercentage(0.5))
//      previewItem(.nextKeyboard, width: .input)
//      previewItem(.nextLocale, width: .available)
//      previewItem(.space, width: .percentage(0.1))
//      previewItem(.character("5"), width: .points(20))
//    }
//  }
// }
