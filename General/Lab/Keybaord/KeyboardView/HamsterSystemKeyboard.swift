//  SystemKeyboard.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-02.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Combine
import KeyboardKit
import SwiftUI

/**
 This keyboard can be used to create alphabetic, numeric and
 symbolic keyboards that mimic the native iOS keyboard.

 The keyboard will by default place an ``AutocompleteToolbar``
 above the keyboard, unless you tell it not to. It will also
 replace the keyboard with an ``EmojiCategoryKeyboard`` when
 ``KeyboardContext/keyboardType`` is ``KeyboardType/emojis``.

 There are several ways to create a system keyboard. Use the
 initializers without view builders to use a standard button
 view for each layout item, the `buttonView` initializers to
 customize the full layout item view, and the `buttonContent`
 initializers to customize the button content of each layout
 item, while keeping the standard button shape and style.

 To use the standard button and content views for some items
 when using any of these custom button view builders, simply
 use the ``SystemKeyboardButtonRowItem`` view as button view
 and ``SystemKeyboardButtonContent`` as button content.

 Since the keyboard layout depends on the available keyboard
 width, you must provide this view with a width if you don't
 use the `controller`-based initializers.
 */
public struct HamsterSystemKeyboard<ButtonView: View>: View {
  /**
   Create a system keyboard with custom button views.

   The provided `buttonView` builder will be used to build
   the full button view for every layout item.

   - Parameters:
     - layout: The keyboard layout to use.
     - appearance: The keyboard appearance to use.
     - actionHandler: The action handler to use.
     - autocompleteContext: The autocomplete context to use.
     - autocompleteToolbar: The autocomplete toolbar mode to use.
     - autocompleteToolbarAction: The action to trigger when tapping an autocomplete suggestion.
     - keyboardContext: The keyboard context to use.
     - calloutContext: The callout context to use.
     - width: The keyboard width.
     - buttonView: The keyboard button view builder.
   */
  public init(
    layout: KeyboardLayout,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?,
    appSettings: HamsterAppSettings,
    width: CGFloat,
    @ViewBuilder buttonView: @escaping ButtonViewBuilder
  ) {
    Logger.shared.log.debug("HamsterSystemKeyboard init")
    // 计算键盘总高度
    self.keyboardHeight = Double(layout.itemRows.count) * layout.idealItemHeight
//      + layout.idealItemInsets.top + layout.idealItemInsets.bottom + appSettings.candidateBarHeight
//      + appSettings.candidateBarHeight

    // 键盘高度+候选栏高度
    self.totalKeyboardHeight = keyboardHeight + appSettings.candidateBarHeight

    // 键盘宽度
    self.keyboardWidth = width

    self.layout = layout
    self.layoutConfig = .standard(for: keyboardContext)
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.buttonView = buttonView
    _keyboardContext = ObservedObject(wrappedValue: keyboardContext)
    _calloutContext = ObservedObject(wrappedValue: calloutContext ?? .disabled)
    _actionCalloutContext = ObservedObject(wrappedValue: calloutContext?.action ?? .disabled)
    _inputCalloutContext = ObservedObject(wrappedValue: calloutContext?.input ?? .disabled)
    _appSettings = ObservedObject(wrappedValue: appSettings)
  }

  /**
   Create a system keyboard with custom button content.

   The provided `buttonContent` will be used to create the
   button content for every layout item, while keeping the
   overall shape and style.

   - Parameters:
     - layout: The keyboard layout to use.
     - appearance: The keyboard appearance to use.
     - actionHandler: The action handler to use.
     - autocompleteContext: The autocomplete context to use.
     - autocompleteToolbar: The autocomplete toolbar mode to use.
     - autocompleteToolbarAction: The action to trigger when tapping an autocomplete suggestion.
     - keyboardContext: The keyboard context to use.
     - calloutContext: The callout context to use.
     - width: The keyboard width.
     - autocompleteToolbarMode: The display mode of the autocomplete toolbar, by default ``AutocompleteToolbarMode/automatic``.
     - buttonContent: The keyboard button content builder.
   */
  public init<ButtonContentView: View>(
    layout: KeyboardLayout,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?,
    appSettings: HamsterAppSettings,
    width: CGFloat,
    @ViewBuilder buttonContent: @escaping (KeyboardLayoutItem) -> ButtonContentView
  ) where ButtonView == HamsterSystemKeyboardButtonRowItem<ButtonContentView> {
    self.init(
      layout: layout,
      appearance: appearance,
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      appSettings: appSettings,
      width: width,
      buttonView: { item, keyboardWidth, inputWidth in
        HamsterSystemKeyboardButtonRowItem(
          content: buttonContent(item),
          item: item,
          actionHandler: actionHandler,
          keyboardContext: keyboardContext,
          calloutContext: calloutContext,
          keyboardWidth: keyboardWidth,
          inputWidth: inputWidth,
          appearance: appearance
        )
      }
    )
  }

  init(
    layout: KeyboardLayout,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?,
    appSettings: HamsterAppSettings,
    width: CGFloat
  ) where ButtonView == HamsterSystemKeyboardButtonRowItem<HamsterKeyboardButtonContent> {
    self.init(
      layout: layout,
      appearance: appearance,
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      appSettings: appSettings,
      width: width,
      buttonContent: { item in
        HamsterKeyboardButtonContent(
          action: item.action,
          appearance: appearance,
          keyboardContext: keyboardContext
        )
      }
    )
  }

  /**
   Create a system keyboard with custom button content.

   The provided `buttonContent` will be used to create the
   button content for every layout item, while keeping the
   overall shape and style.

   - Parameters:
     - controller: The controller to use to resolve required properties.
     - autocompleteToolbar: The display mode of the autocomplete toolbar, by default ``AutocompleteToolbarMode/automatic``.
     - autocompleteToolbarAction: The action to trigger when tapping an autocomplete suggestion, by default ``KeyboardInputViewController/insertAutocompleteSuggestion(_:)``.
     - width: The keyboard width, by default the width of the controller's view.
     - buttonContent: The keyboard button content builder.
   */
  public init<ButtonContentView: View>(
    controller: KeyboardInputViewController,
    width: CGFloat? = nil,
    @ViewBuilder buttonContent: @escaping (KeyboardLayoutItem) -> ButtonContentView
  ) where ButtonView == HamsterSystemKeyboardButtonRowItem<ButtonContentView> {
    self.init(
      layout: controller.keyboardLayoutProvider.keyboardLayout(for: controller.keyboardContext),
      appearance: controller.keyboardAppearance,
      actionHandler: controller.keyboardActionHandler,
      keyboardContext: controller.keyboardContext,
      calloutContext: controller.calloutContext,
      appSettings: (controller as! HamsterKeyboardViewController).appSettings,
      width: width ?? controller.view.frame.width,
      buttonContent: buttonContent
    )
  }

  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let buttonView: ButtonViewBuilder
  private let keyboardWidth: CGFloat
  private let keyboardHeight: CGFloat
  private let totalKeyboardHeight: CGFloat

  private let layout: KeyboardLayout
  private let layoutConfig: KeyboardLayoutConfiguration

  public typealias ButtonViewBuilder = (KeyboardLayoutItem, KeyboardWidth, KeyboardItemWidth) -> ButtonView
  public typealias KeyboardWidth = CGFloat
  public typealias KeyboardItemWidth = CGFloat

  private var actionCalloutStyle: KeyboardActionCalloutStyle {
    var style = appearance.actionCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = CGSize(width: insets.leading, height: insets.top)
    return style
  }

  private var inputCalloutStyle: KeyboardInputCalloutStyle {
    var style = appearance.inputCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = CGSize(width: insets.leading, height: insets.top)
    return style
  }

  @ObservedObject
  private var actionCalloutContext: ActionCalloutContext

  @ObservedObject
  private var calloutContext: KeyboardCalloutContext

  @ObservedObject
  private var inputCalloutContext: InputCalloutContext

  @ObservedObject
  private var keyboardContext: KeyboardContext

  @ObservedObject
  private var appSettings: HamsterAppSettings

  @EnvironmentObject
  private var rimeContext: RimeContext

  // 动态计算键盘尺寸
  @State
  private var keyboardSize: CGSize = .zero

  // MARK: 计算属性

  // 输入按钮宽度, 因单手键盘，改为计算属性
  private var inputWidth: CGFloat {
    layout.inputWidth(for: realKeyboardWidth)
  }

  // 判断是否可以开启单手模式
  var canEnableOneHand: Bool {
    keyboardContext.isPortrait && keyboardContext.deviceType == .phone
  }

  // 在iphone上单手模式切换面板宽度
  var handModeChangePaneWidth: CGFloat {
    (canEnableOneHand && appSettings.enableKeyboardOneHandMode) ? appSettings.keyboardOneHandWidth : 0
  }

  // 根据是否开启单手模式计算键盘宽度
  var realKeyboardWidth: CGFloat {
    keyboardWidth - handModeChangePaneWidth
  }

  public var body: some View {
    ZStack(alignment: .bottom) {
      autocompleteToolbar
        .frame(width: realKeyboardWidth, height: totalKeyboardHeight)

      keyboardView
        .frame(width: realKeyboardWidth)
        .opacity(appSettings.keyboardStatus == .normal ? 1 : 0)
        .overlay(GeometryReader { proxy in Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size) })
    }
    .frame(width: realKeyboardWidth)
    .background(appearance.backgroundStyle.backgroundView)
    .onPreferenceChange(SizePreferenceKey.self) { value in keyboardSize = value }
    .oneHandKeyboard(enable: canEnableOneHand, realKeyboardWidth: realKeyboardWidth, oneHandWidth: handModeChangePaneWidth)
  }
}

private extension HamsterSystemKeyboard {
  @ViewBuilder
  var autocompleteToolbar: some View {
    if shouldAddAutocompleteToolbar {
      HamsterAutocompleteToolbar(appearance: appearance, style: appearance.autocompleteToolbarStyle, keyboardSize: $keyboardSize)
    }
  }

  var keyboardView: some View {
    keyboardViewContent
      .hamsterKeyboardActionCallout(
        calloutContext: actionCalloutContext,
        keyboardContext: keyboardContext,
        style: actionCalloutStyle,
        emojiKeyboardStyle: .standard(for: keyboardContext)
      )
      .hamsterKeyboardInputCallout(
        calloutContext: inputCalloutContext,
        keyboardContext: keyboardContext,
        style: inputCalloutStyle
      )
  }

  @ViewBuilder
  var keyboardViewContent: some View {
    switch keyboardContext.keyboardType {
    case .emojis: emojiKeyboard
    case .custom(let name):
      let customKeyboard = keyboardCustomType(rawValue: name)
      switch customKeyboard {
      case .numberNineGrid: numNineGridKeyboard
      default: systemKeyboard
      }
    default: systemKeyboard
    }
  }

  var shouldAddAutocompleteToolbar: Bool {
    if !appSettings.enableCandidateBar {
      return false
    }
    if keyboardContext.keyboardType == .emojis { return false }
//    switch autocompleteToolbarMode {
//    case .automatic: return true
//    case .none: return false
//    }
    return true
  }
}

private extension HamsterSystemKeyboard {
  var emojiKeyboard: some View {
    EmojiCategoryKeyboard(
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      appearance: appearance,
      style: .standard(for: keyboardContext)
    ).padding(.top)
  }

  var numNineGridKeyboard: some View {
    NumNineGridKeyboard(
      layout: layout,
      appearance: appearance,
      actionHandler: actionHandler,
      calloutContext: calloutContext,
      keyboardContext: keyboardContext,
      appSettings: appSettings,
      width: keyboardWidth,
      height: keyboardHeight
    )
  }

  var systemKeyboard: some View {
    VStack(spacing: 0) {
      itemRows(for: layout)
    }
    .padding(appearance.keyboardEdgeInsets)
    .environment(\.layoutDirection, .leftToRight)
  }
}

private extension HamsterSystemKeyboard {
  func itemRows(for layout: KeyboardLayout) -> some View {
    ForEach(Array(layout.itemRows.enumerated()), id: \.offset) {
      items(for: layout, itemRow: $0.element)
    }
  }

  func items(for layout: KeyboardLayout, itemRow: KeyboardLayoutItemRow) -> some View {
    HStack(spacing: 0) {
      ForEach(Array(itemRow.enumerated()), id: \.offset) { _, element in
        buttonView(element, realKeyboardWidth, inputWidth)
      }.id(keyboardContext.locale.identifier)
    }
  }
}

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

//
/// **
// `IMPORTANT` In previews, you must provide a custom width to
// get buttons to show up, since there is no shared controller.
// */
// struct HamsterSystemKeyboard_Previews: PreviewProvider {
//  static var controller = KeyboardInputViewController.preview
//
//  @ViewBuilder
//  static func previewButton(
//    item: KeyboardLayoutItem,
//    keyboardWidth: CGFloat,
//    inputWidth: CGFloat
//  ) -> some View {
//    switch item.action {
//    case .space:
//      Text("This is a space bar replacement")
//        .frame(maxWidth: .infinity)
//        .multilineTextAlignment(.center)
//    default:
//      SystemKeyboardButtonRowItem(
//        content: previewButtonContent(item: item),
//        item: item,
//        actionHandler: .preview,
//        keyboardContext: controller.keyboardContext,
//        calloutContext: controller.calloutContext,
//        keyboardWidth: keyboardWidth,
//        inputWidth: inputWidth,
//        appearance: controller.keyboardAppearance
//      )
//    }
//  }
//
//  @ViewBuilder
//  static func previewButtonContent(
//    item: KeyboardLayoutItem
//  ) -> some View {
//    switch item.action {
//    case .backspace:
//      Image(systemName: "trash").foregroundColor(Color.red)
//    default:
//      SystemKeyboardButtonContent(
//        action: item.action,
//        appearance: .preview,
//        keyboardContext: controller.keyboardContext
//      )
//    }
//  }
//
//  static var previews: some View {
//    VStack(spacing: 10) {
//      // A standard system keyboard
//      HamsterSystemKeyboard(
//        controller: controller,
//        width: UIScreen.main.bounds.width
//      )
//
//      // A keyboard that replaces the button content
//      HamsterSystemKeyboard(
//        controller: controller,
//        width: UIScreen.main.bounds.width,
//        buttonContent: previewButtonContent
//      )
//
//      // A keyboard that replaces entire button views
//      HamsterSystemKeyboard(
//        controller: controller,
//        width: UIScreen.main.bounds.width,
//        buttonView: previewButton
//      )
//    }.background(Color.yellow)
//  }
// }
