//
//  KeyboardContext.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-06-15.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Combine
import Foundation
import HamsterKit
import OSLog
import UIKit

/**
 This class provides keyboard extensions with contextual and
 observable information about the keyboard extension itself.

 该类为键盘扩展提供有关键盘扩展本身的上下文和可观测信息。

 You can use ``locale`` to get and set the raw locale of the
 keyboard or use the various `setLocale(...)` functions that
 support using both `Locale` and ``KeyboardLocale``. You can
 use ``locales`` to set all the available locales, then call
 ``selectNextLocale()`` to select the next available locale.

 您可以使用 ``locale`` 获取和设置键盘的本地化信息， 或者使用各种同时支持使用 `Locale` 和 `KeyboardLocale` 的 `setLocale(...)` 函数。
 可以使用 ``locales`` 设置所有可用的本地化语言，然后调用 ``selectNextLocale()`` 选择下一个可用的本地化语言。

 KeyboardKit automatically creates an instance of this class
 and binds the created instance to the keyboard controller's
 ``KeyboardInputViewController/keyboardContext``.

 KeyboardKit 会自动创建该类的实例，并将创建的实例绑定到 Keyboard Controller 的 ``KeyboardInputViewController/keyboardContext`` 中。
 */
public class KeyboardContext: ObservableObject {
  /**
   The property can be set to override auto-capitalization
   information provided by ``autocapitalizationType``.

   设置该属性可覆盖 ``autocapitalizationType`` 提供的自动大写信息。
   */
  @Published
  public var autocapitalizationTypeOverride: KeyboardAutocapitalizationType?

  /**
   The device type that is currently used.

   当前使用的设备类型。

   By default, this is ``DeviceType/current``, but you can
   change it to anything you like.

   默认情况下，这是 ``DeviceType/current``'，但您可以随意更改。
   */
  @Published
  public var deviceType: DeviceType = .current

  /**
   Whether or not the input controller has a dictation key.

   是否有听写按键。
   */
  @Published
  public var hasDictationKey: Bool = false

  /**
   Whether or not the extension has been given full access.

   扩展程序是否已被授予完全访问权限。
   */
  @Published
  public var hasFullAccess: Bool = false

  /**
   The current interface orientation.

   当前界面的方向。
   */
  @Published
  public var interfaceOrientation: InterfaceOrientation = .portrait

  /**
   Whether or not auto-capitalization is enabled.

   是否启用自动大写。

   You can set this to `false` to override the behavior of
   the text document proxy.

   您可以将其设置为 "false"，以覆盖 text document proxy 的行为。
   */
  @Published
  public var isAutoCapitalizationEnabled = true

  /**
   Whether or not the keyboard is in floating mode.

   键盘是否处于浮动模式。
   */
  @Published
  public var isKeyboardFloating = false

  /**
   An optional dictation replacement action, which will be
   used by some ``KeyboardLayoutProvider`` implementations.

   可选的听写替换操作，某些 ``KeyboardLayoutProvider`` 实现将使用该操作。

   > Warning: This will be deprecated and not used anymore
   in KeyboardKit 7.9.9, then eventually removed in 8.0. A
   replacement is to use a custom ``KeyboardLayoutProvider``
   instead, which allows greater configuration options.

   > 警告：在 KeyboardKit 7.9.9 中将被废弃并不再使用，最终将在 8.0 中移除。
   > 取而代之的是使用自定义的 ``KeyboardLayoutProvider`` ，它允许更多的配置选项。
   */
  @Published
  public var keyboardDictationReplacement: KeyboardAction?

  /**
   The keyboard type that is currently used.

   当前使用的键盘类型。默认中文26键
   */
  @Published
  public var keyboardType = KeyboardType.chinese(.lowercased)

  /**
   The locale that is currently being used.

   当前使用的本地语言。

   This uses `Locale` instead of ``KeyboardLocale``, since
   keyboards can use locales that are not in that enum.

   这将使用 `Locale` 而不是 `KeyboardLocale``，因为键盘可以使用不在该枚举中的本地语言。
   */
  @Published
  public var locale = Locale.current

  /**
   The locales that are currently enabled for the keyboard.

   键盘当前启用的本地语言列表。
   */
  @Published
  public var locales: [Locale] = [.current]

  /**
   An custom locale to use when displaying other locales.

   自定义本地语言，用于显示其他本地语言。

   If no locale is specified, the ``locale`` will be used.

   如果未指定 locale，则将使用 ``locale``。
   */
  @Published
  public var localePresentationLocale: Locale?

  /**
   Whether or not the keyboard should (must) have a switch
   key for selecting the next keyboard.

   键盘是否应该（必须）有用于选择下一个键盘的切换键。
   */
  @Published
  public var needsInputModeSwitchKey = false

  /**
   Whether or not the context prefers autocomplete.

   上下文是否偏好自动完成。

   The property is set every time the proxy syncs with the
   controller. You can ignore it if you want.

   proxy 每次与 controller 同步时都会设置该属性。如果需要，可以忽略它。
   */
  @Published
  public var prefersAutocomplete = true

  /**
   The primary language that is currently being used.

   目前使用的主要语言。
   */
  @Published
  public var primaryLanguage: String?

  /**
   The screen size, which is used by some library features.

   屏幕尺寸，用于某些 Library 功能。
   */
  @Published
  public var screenSize = CGSize.zero

  /**
   The space long press behavior to use.

   空格长按的行为。
   */
  @Published
  public var spaceLongPressBehavior = SpaceLongPressBehavior.moveInputCursor

  /**
   The main text document proxy.
   */
  @Published
  public var mainTextDocumentProxy: UITextDocumentProxy = PreviewTextDocumentProxy()

  /**
   The text document proxy that is currently active.

   当前激活的 text document proxy。
   */
  @Published
  public var textDocumentProxy: UITextDocumentProxy = PreviewTextDocumentProxy()

  /**
   The text input mode of the input controller.

   controler 的文本输入模式。
   */
  @Published
  public var textInputMode: UITextInputMode?

  /**
   The input controller's current trait collection.

   controller 的当前特质集合。
   */
  @Published
  public var traitCollection = UITraitCollection()

  /// 是否首次加载空格
  public var firstLoadingSpace = true

  /**
   仓输入法配置
   */
  public var hamsterConfig: HamsterConfiguration? = nil {
    didSet {
      cacheHamsterKeyboardColor = nil
    }
  }

  /// 输入法配色方案缓存
  /// 为计算属性 `hamsterKeyboardColor` 提供缓存
  private var cacheHamsterKeyboardColor: HamsterKeyboardColor?

  /// 候选区域状态
  @Published
  public var candidatesViewState: CandidateBarView.State = .collapse
  public var candidatesViewStatePublished: AnyPublisher<CandidateBarView.State, Never> {
    $candidatesViewState.eraseToAnyPublisher()
  }

  /**
   Create a context instance.

   创建 context 实例
   */
  public init() {}

  /**
   Create a context instance that is initially synced with
   the provided `controller` and that sets `screenSize` to
   the main screen size.

   创建一个 context 实例，初始时与提供的 `controller` 同步，并将 `screenSize` 设置为主屏幕尺寸。

   - Parameters:
     - controller: The controller with which the context should sync, if any.
                   Context 应与之同步的 controller（如果有）。
   */
  public convenience init(
    controller: KeyboardInputViewController?
  ) {
    self.init()
    guard let controller = controller else { return }
    self.hamsterConfig = controller.hamsterConfiguration
    self.handleInputModeBuilder = { from, with in
      controller.handleInputModeList(from: from, with: with)
    }
    needsInputModeSwitchKey = controller.needsInputModeSwitchKey
    sync(with: controller)
  }

  var handleInputModeBuilder: ((_ from: UIView, _ with: UIEvent) -> Void)?
  @objc func handleInputModeListFromView(from: UIView, with: UIEvent) {
    handleInputModeBuilder?(from, with)
  }
}

// MARK: - Public iOS/tvOS Properties

public extension KeyboardContext {
  /**
   The current trait collection's color scheme.

   当前特征集合中的配色方案。
   */
  var colorScheme: UIUserInterfaceStyle {
    traitCollection.userInterfaceStyle
  }

  /**
   The current keyboard appearance, with `.light` fallback.

   当前键盘外观，使用 `.light` 后备。
   */
  var keyboardAppearance: UIKeyboardAppearance {
    textDocumentProxy.keyboardAppearance ?? .default
  }
}

// MARK: - Public Properties

public extension KeyboardContext {
  /**
   The standard auto-capitalization type that will be used
   by the keyboard.

   键盘将使用的标准自动大写类型。

   This is by default fetched from the text document proxy
   for iOS and tvOS and is `.none` for all other platforms.
   You can set ``autocapitalizationTypeOverride`` to set a
   custom value that overrides the default one.

   默认情况下，iOS 和 tvOS 会从 documentProxy 获取该值，所有其他平台则为 `.none`。
   你可以设置 ``autocapitalizationTypeOverride`` 来设置一个覆盖默认值的自定义值。
   */
  var autocapitalizationType: KeyboardAutocapitalizationType? {
    autocapitalizationTypeOverride ?? textDocumentProxy.autocapitalizationType?.keyboardType
  }

  /**
   Whether or not the context specifies that we should use
   a dark color scheme.
   */
  var hasDarkColorScheme: Bool {
    colorScheme == .dark
  }

  /**
   Try to map the current ``locale`` to a keyboard locale.

   尝试将当前的 ``locale`` 映射到键盘的 locale。
   */
//  var keyboardLocale: KeyboardLocale? {
//    KeyboardLocale.allCases.first { $0.localeIdentifier == locale.identifier }
//  }
}

// MARK: - Public Functions

public extension KeyboardContext {
  /**
   Whether or not the context has multiple locales.

   上下文是否有多个本地语言。
   */
  var hasMultipleLocales: Bool {
    locales.count > 1
  }

  /**
   Whether or not the context has a certain locale.

   上下文是否具有特定的语言。
   */
//  func hasKeyboardLocale(_ locale: KeyboardLocale) -> Bool {
//    self.locale.identifier == locale.localeIdentifier
//  }

  /**
   Whether or not the context has a certain keyboard type.

   是否有特定的键盘类型。
   */
  func hasKeyboardType(_ type: KeyboardType) -> Bool {
    keyboardType == type
  }

  /**
   Select the next locale in ``locales``, depending on the
   ``locale``. If ``locale`` is last in ``locales`` or not
   in the list, the first list locale is selected.

   根据 ``locale`` 选择 ``locales`` 中的下一个本地语言。如果 ``locale`` 是 ``locales`` 中的最后一个或不在列表中，则选择列表中的第一个 locale。
   */
  func selectNextLocale() {
    let fallback = locales.first ?? locale
    guard let currentIndex = locales.firstIndex(of: locale) else { return locale = fallback }
    let nextIndex = currentIndex.advanced(by: 1)
    guard locales.count > nextIndex else { return locale = fallback }
    locale = locales[nextIndex]
  }

  /**
   Set ``keyboardType`` to the provided `type`.

   设置键盘类型
   */
  func setKeyboardType(_ type: KeyboardType) {
    keyboardType = type
  }

  /**
   Set ``locale`` to the provided `locale`.

   设置当前语言
   */
  func setLocale(_ locale: Locale) {
    self.locale = locale
  }

  /**
   Set ``locale`` to the provided keyboard `locale`.

   根据 KeyboardLocale 类型设置当前语言
   */
//  func setLocale(_ locale: KeyboardLocale) {
//    self.locale = locale.locale
//  }

  /**
   Set ``locales`` to the provided `locales`.
   */
  func setLocales(_ locales: [Locale]) {
    self.locales = locales
  }

  /**
   Set ``locales`` to the provided keyboard `locales`.
   */
//  func setLocales(_ locales: [KeyboardLocale]) {
//    self.locales = locales.map { $0.locale }
//  }
}

// MARK: - iOS/tvOS syncing

extension KeyboardContext {
  /**
   Sync the context with the current state of the keyboard
   input view controller.

   将上下文与键盘输入视图控制器的当前状态同步。
   */
  func sync(with controller: KeyboardInputViewController) {
    DispatchQueue.main.async {
      self.syncAfterAsync(with: controller)
    }
  }

  /**
   Perform this after an async delay, to make sure that we
   have the latest information.

   将上下文与键盘输入视图控制器的当前状态同步。
   */
  func syncAfterAsync(with controller: KeyboardInputViewController) {
    if hasDictationKey != controller.hasDictationKey {
      hasDictationKey = controller.hasDictationKey
    }
    if hasFullAccess != controller.hasFullAccess {
      hasFullAccess = controller.hasFullAccess
    }
//    if needsInputModeSwitchKey != controller.needsInputModeSwitchKey {
//      needsInputModeSwitchKey = controller.needsInputModeSwitchKey
//    }
    if primaryLanguage != controller.primaryLanguage {
      primaryLanguage = controller.primaryLanguage
    }
    if interfaceOrientation != controller.orientation {
      interfaceOrientation = controller.orientation
    }

    let newPrefersAutocomplete = keyboardType.prefersAutocomplete && (textDocumentProxy.keyboardType?.prefersAutocomplete ?? true)
    if prefersAutocomplete != newPrefersAutocomplete {
      prefersAutocomplete = newPrefersAutocomplete
    }

    if screenSize != controller.screenSize {
      screenSize = controller.screenSize
    }

    if mainTextDocumentProxy === controller.mainTextDocumentProxy {} else {
      mainTextDocumentProxy = controller.mainTextDocumentProxy
    }
    if textDocumentProxy === controller.textDocumentProxy {} else {
      textDocumentProxy = controller.textDocumentProxy
    }
    if textInputMode != controller.textInputMode {
      textInputMode = controller.textInputMode
    }
    if traitCollection != controller.traitCollection {
      traitCollection = controller.traitCollection
    }
  }

  func syncAfterLayout(with controller: KeyboardInputViewController) {
    syncIsFloating(with: controller)
    if controller.orientation == interfaceOrientation { return }
    sync(with: controller)
  }

  /**
   Perform a sync to check if the keyboard is floating.
   */
  func syncIsFloating(with controller: KeyboardInputViewController) {
    let isFloating = controller.view.frame.width < screenSize.width / 2
    if isKeyboardFloating == isFloating { return }
    isKeyboardFloating = isFloating
  }
}

private extension UIInputViewController {
  var orientation: InterfaceOrientation {
    view.window?.screen.interfaceOrientation ?? .portrait
  }

  var screenSize: CGSize {
    view.window?.screen.bounds.size ?? .zero
  }
}

// MARK: - Hamster Configuration

public extension KeyboardContext {
  /// 用户设置的键盘类型
  var selectKeyboard: KeyboardType {
    hamsterConfig?.keyboard?.useKeyboardType?.keyboardType ?? .chinese(.lowercased)
  }

  /// 是否启用分号键
  var displaySemicolonButton: Bool {
    hamsterConfig?.keyboard?.displaySemicolonButton ?? false
  }

  /// 是否启用分类符号按键
  var displayClassifySymbolButton: Bool {
    hamsterConfig?.keyboard?.displayClassifySymbolButton ?? true
  }

  /// 是否启用中英切换键
  var displayChineseEnglishSwitchButton: Bool {
    hamsterConfig?.keyboard?.displayChineseEnglishSwitchButton ?? true
  }

  /// 空格左侧自定义按键
  var displaySpaceLeftButton: Bool {
    hamsterConfig?.keyboard?.displaySpaceLeftButton ?? false
  }

  var spaceLeftButtonProcessByRIME: Bool {
    hamsterConfig?.keyboard?.spaceLeftButtonProcessByRIME ?? true
  }

  /// 空格左侧按键键值
  var keyValueOfSpaceLeftButton: String {
    hamsterConfig?.keyboard?.keyValueOfSpaceLeftButton ?? ""
  }

  /// 空格右侧自定义按键
  var displaySpaceRightButton: Bool {
    hamsterConfig?.keyboard?.displaySpaceRightButton ?? false
  }

  var spaceRightButtonProcessByRIME: Bool {
    hamsterConfig?.keyboard?.spaceRightButtonProcessByRIME ?? true
  }

  /// 空格右侧按键键值
  var keyValueOfSpaceRightButton: String {
    hamsterConfig?.keyboard?.keyValueOfSpaceRightButton ?? ""
  }

  /// 中英切换键是否位于空格左侧
  var chineseEnglishSwitchButtonIsOnLeftOfSpaceButton: Bool {
    hamsterConfig?.keyboard?.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton ?? true
  }

  /// 是否开启工具栏
  var enableToolbar: Bool {
    hamsterConfig?.toolbar?.enableToolbar ?? true
  }

  /// 是否开启按键气泡
  var displayButtonBubbles: Bool {
    (hamsterConfig?.keyboard?.displayButtonBubbles ?? false) && keyboardType.displayButtonBubbles
  }

  /// 工具栏应用图标按钮
  var displayAppIconButton: Bool {
    hamsterConfig?.toolbar?.displayAppIconButton ?? false
  }

  /// 工具栏键盘 dismiss 按键
  var displayKeyboardDismissButton: Bool {
    hamsterConfig?.toolbar?.displayKeyboardDismissButton ?? false
  }

  /// 数字九宫格符号列表
  var symbolsOfNumericNineGridKeyboard: [String] {
    hamsterConfig?.keyboard?.symbolsOfGridOfNumericKeyboard ?? []
  }

  /// 中文九宫格符号
  var symbolsOfChineseNineGridKeyboard: [String] {
    hamsterConfig?.keyboard?.symbolsOfChineseNineGridKeyboard ?? []
  }

  /// 工具栏高度
  var heightOfToolbar: CGFloat {
    CGFloat(hamsterConfig?.toolbar?.heightOfToolbar ?? 55)
  }

  /// 工具栏编码区高度
  var heightOfCodingArea: CGFloat {
    CGFloat(hamsterConfig?.toolbar?.heightOfCodingArea ?? 15)
  }

  /// 数字九宫格符号是否直接上屏
  var enterDirectlyOnScreenByNineGridOfNumericKeyboard: Bool {
    hamsterConfig?.keyboard?.enterDirectlyOnScreenByNineGridOfNumericKeyboard ?? true
  }

  /// 分类符号键盘状态
  var classifySymbolKeyboardLockState: Bool {
    get {
      UserDefaults.standard.bool(forKey: "com.ihsiao.apps.hamster.keyboard.classifySymbolKeyboard.lockState")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "com.ihsiao.apps.hamster.keyboard.classifySymbolKeyboard.lockState")
    }
  }

  /// 内置键盘划动配置
  var keyboardSwipe: [KeyboardSwipe] {
    hamsterConfig?.swipe?.keyboardSwipe ?? []
  }

  /// 关闭划动显示文本
  var disableSwipeLabel: Bool {
    hamsterConfig?.keyboard?.disableSwipeLabel ?? false
  }

  /// 上划显示在左侧
  var upSwipeOnLeft: Bool {
    hamsterConfig?.keyboard?.upSwipeOnLeft ?? true
  }

  /// 划动上下布局
  var swipeLabelUpAndDownLayout: Bool {
    hamsterConfig?.keyboard?.swipeLabelUpAndDownLayout ?? false
  }

  /// 划动上下不规则布局
  var swipeLabelUpAndDownIrregularLayout: Bool {
    hamsterConfig?.keyboard?.swipeLabelUpAndDownIrregularLayout ?? false
  }

  /// 自定义键盘
  var keyboards: [Keyboard] {
    hamsterConfig?.keyboards ?? []
  }

  /// 是否启用内嵌输入模式
  var enableEmbeddedInputMode: Bool {
    hamsterConfig?.keyboard?.enableEmbeddedInputMode ?? false
  }

  /// Shift 状态锁定
  var lockShiftState: Bool {
    hamsterConfig?.keyboard?.lockShiftState ?? true
  }

  /// 光标回退
  func cursorBackOfSymbols(key: String) -> Bool {
    if hamsterConfig?.keyboard?.symbolsOfCursorBack?.contains(key) ?? false {
      return true
    }
    return false
  }

  /// 成对上屏符号
  func getPairSymbols(_ key: String) -> String {
    if let pairValue = hamsterConfig?.keyboard?.pairsOfSymbols?.first(where: { $0.hasPrefix(key) }) {
      return pairValue
    }
    return key
  }

  /// 返回主键盘
  func returnToPrimaryKeyboardOfSymbols(key: String) -> Bool {
    hamsterConfig?.keyboard?.symbolsOfReturnToMainKeyboard?.contains(key) ?? false
  }

  /// 划动阈值
  var distanceThreshold: CGFloat {
    CGFloat(hamsterConfig?.swipe?.distanceThreshold ?? 20)
  }

  /// 滑动角度正切阈值
  var tangentThreshold: CGFloat {
    hamsterConfig?.swipe?.tangentThreshold ?? 0.268
  }

  /// 长按延迟时间
  var longPressDelay: Double? {
    hamsterConfig?.swipe?.longPressDelay
  }

  // 是否启用空格加载文本
  var enableLoadingTextForSpaceButton: Bool {
    hamsterConfig?.keyboard?.enableLoadingTextForSpaceButton ?? false
  }

  // 空格按钮加载文本
  var loadingTextForSpaceButton: String {
    hamsterConfig?.keyboard?.loadingTextForSpaceButton ?? ""
  }

  // 空格按钮长显文本
  var labelTextForSpaceButton: String {
    hamsterConfig?.keyboard?.labelTextForSpaceButton ?? ""
  }

  // 空格按钮长显为当前输入方案
  // 当开启此选项后，labelForSpaceButton 设置的值无效
  var showCurrentInputSchemaNameForSpaceButton: Bool {
    hamsterConfig?.keyboard?.showCurrentInputSchemaNameForSpaceButton ?? false
  }

  // 空格按钮加载文字显示当前输入方案
  // 当开启此选项后， loadingTextForSpaceButton 设置的值无效
  var showCurrentInputSchemaNameOnLoadingTextForSpaceButton: Bool {
    hamsterConfig?.keyboard?.showCurrentInputSchemaNameOnLoadingTextForSpaceButton ?? false
  }
}
