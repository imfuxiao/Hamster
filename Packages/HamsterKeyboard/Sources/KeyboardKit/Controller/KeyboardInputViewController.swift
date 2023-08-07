//
//  KeyboardViewController.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2018-03-13.
//  Copyright © 2018-2023 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Combine
import UIKit

/**
 This class extends `UIInputViewController` with KeyboardKit
 specific functionality.

 该类扩展了 `UIInputViewController` 的 KeyboardKit 特定功能。

 When you use KeyboardKit, simply inherit this class instead
 of `UIInputViewController` to extend your controller with a
 set of additional lifecycle functions, properties, services
 etc. such as ``viewWillSetupKeyboard()``, ``keyboardContext``
 and ``keyboardActionHandler``.

 当您使用 KeyboardKit 时，只需继承该类而非 `UIInputViewController` 类，
 即可使用一组附加的生命周期函数、属性、服务等来扩展您的控制器，
 例如 `viewWillSetupKeyboard()``、`keyboardContext`` 和 `keyboardActionHandler``。

 You may notice that KeyboardKit's own views use initializer
 parameters instead of environment objects. It's intentional,
 to better communicate the dependencies of each view.

 您可能会注意到，KeyboardKit 自己的视图使用初始化器参数而非环境对象。这是有意为之，以便更好地传达每个视图的依赖关系。
 */
open class KeyboardInputViewController: UIInputViewController, KeyboardController {
  // MARK: - View Controller Lifecycle ViewController 生命周期

  override open func viewDidLoad() {
    super.viewDidLoad()
    setupInitialWidth()
    setupLocaleObservation()
    setupNextKeyboardBehavior()
    KeyboardUrlOpener.shared.controller = self
  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewWillSetupKeyboard()
    viewWillSyncWithContext()
  }

  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
//    viewWillHandleDictationResult()
  }

  override open func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    keyboardContext.syncAfterLayout(with: self)
  }

  override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    viewWillSyncWithContext()
    super.traitCollectionDidChange(previousTraitCollection)
  }

  // MARK: - Keyboard View Controller Lifecycle 键盘 ViewController 生命周期

  /**
   This function is called to handle any dictation results
   when returning from the main app.

   从主应用程序返回时，会调用此函数来处理任何听写结果。
   */
//  open func viewWillHandleDictationResult() {
//    Task {
//      do {
//        try await dictationService.handleDictationResultInKeyboard()
//      } catch {
//        await MainActor.run {
//          dictationContext.lastError = error
//        }
//      }
//    }
//  }

  /**
   This function is called whenever the keyboard view must
   be created or updated.

   每当必须创建或更新键盘视图时，都会调用该函数。

   This will by default set up a ``SystemKeyboard`` as the
   main view, but you can override it to use a custom view.

   默认情况下，这将设置一个 "SystemKeyboard"（系统键盘）作为主视图，但你可以覆盖它以使用自定义视图。
   */
  open func viewWillSetupKeyboard() {
    // TODO:
//    setup { SystemKeyboard(controller: $0) }
  }

  /**
   This function is called whenever the controller must be
   synced with its ``keyboardContext``.

   每当 controller 必须与其 ``keyboardContext`` 同步时，就会调用此函数。

   This will by default sync with keyboard contexts if the
   ``isContextSyncEnabled`` is `true`. You can override it
   to customize syncing or sync with more contexts.

   如果 ``isContextSyncEnabled`` 为 `true`，默认情况下将与 KeyboardContext 同步。
   你可以覆盖它以自定义同步或与更多上下文同步。
   */
  open func viewWillSyncWithContext() {
    guard isContextSyncEnabled else { return }
    keyboardContext.sync(with: self)
    keyboardTextContext.sync(with: self)
  }

  // MARK: - Setup

  /**
   Setup KeyboardKit with a SwiftUI view.

   使用 SwiftUI 视图设置 KeyboardKit。

   Only use this setup function when the view doesn't need
   to refer to this controller, otherwise make sure to use
   the controller-based setup function instead.

   只有当视图不需要引用该 controller 时才使用此函数，
   否则请确保使用基于 controller 的设置函数。
   */
  open func setup<Content: UIView>(
    with view: @autoclosure @escaping () -> Content
  ) {
    // TODO:
//    setup(withRootView: KeyboardRootView(view))
  }

  /**
   Setup KeyboardKit with a SwiftUI view.

   使用 SwiftUI 视图设置 KeyboardKit。

   Only use this setup function when the view doesn't need
   to refer to this controller, otherwise make sure to use
   the controller-based setup function instead.

   只有当视图不需要引用该 controller 时才使用此设置函数，
   否则请确保使用基于 controller 的设置函数。
   */
  open func setup<Content: UIView>(
    with view: @escaping () -> Content
  ) {
    // TODO:
//    setup(withRootView: KeyboardRootView(view))
  }

  /**
   Setup KeyboardKit with a SwiftUI view.

   使用 SwiftUI 视图设置 KeyboardKit。

   Use this setup function when the view needs to refer to
   this controller, otherwise it's easy to create a memory
   leak when injecting the controller into the view.

   当视图需要引用该 controller 时，请使用此设置函数，否则在将 controller 注入视图时很容易造成内存泄漏。
   */
  open func setup<Content: UIView>(
    with view: @escaping (_ controller: KeyboardInputViewController) -> Content
  ) {
    // TODO:
//    setup(withRootView: KeyboardRootView { [unowned self] in
//      view(self)
//    })
  }

  /**
   This function is shared by all setup functions.

   该功能函数由所有设置函数共享。
   */
  func setup<Content: UIView>(withRootView view: Content) {
    children.forEach { $0.removeFromParent() }

    self.view.subviews.forEach { $0.removeFromSuperview() }
    // TODO: 设置键盘的View
//    let view = view
//      .environmentObject(autocompleteContext)
//      .environmentObject(calloutContext)
//      .environmentObject(dictationContext)
//      .environmentObject(keyboardContext)
//      .environmentObject(keyboardFeedbackSettings)
//      .environmentObject(keyboardTextContext)
//    let host = KeyboardHostingController(rootView: view)
//    host.add(to: self)
  }

  // MARK: - Combine

  var cancellables = Set<AnyCancellable>()

  // MARK: - Properties

  /**
   The original text document proxy that was used to start
   the keyboard extension.

   用于启动键盘扩展程序的原生文本文档代理。

   This stays the same even if a ``textInputProxy`` is set,
   which makes ``textDocumentProxy`` return the custom one
   instead of the original one.

   即使设置了 ``textInputProxy`` 也不会改变，这将使 ``textDocumentProxy`` 返回自定义的文档，而不是原始文档。
   */
  open var mainTextDocumentProxy: UITextDocumentProxy {
    super.textDocumentProxy
  }

  /**
   The text document proxy to use, which can either be the
   original text input proxy or the ``textInputProxy``, if
   it is set to a custom value.

   要使用的 document proxy，可以是原生的文本输入代理，也可以是 ``textInputProxy``（如果设置为自定义值）。
   */
  override open var textDocumentProxy: UITextDocumentProxy {
    textInputProxy ?? mainTextDocumentProxy
  }

  /**
   A custom text input proxy to which text can be routed.

   自定义文本输入代理，可将文本传送到该代理。

   Setting the property makes ``textDocumentProxy`` return
   the custom proxy instead of the original one.

   设置该属性可使 ``textDocumentProxy`` 返回自定义代理，而不是原始代理。
   */
  public var textInputProxy: TextInputProxy? {
    didSet { viewWillSyncWithContext() }
  }

  // MARK: - Observables

  /**
   The default, observable autocomplete context.

   默认的、可观察的自动完成上下文。

   This context is used as global state for the keyboard's
   autocomplete, e.g. the current suggestions.

   该上下文用作键盘自动完成的全局状态，例如当前建议。
   */
  public lazy var autocompleteContext = AutocompleteContext()

  /**
   The default, observable callout context.

   默认的可观察呼出上下文。

   This is used as global state for the callouts that show
   the currently typed character.

   这将作为显示当前键入字符的呼出的全局状态。
   */
  public lazy var calloutContext = KeyboardCalloutContext(
    action: ActionCalloutContext(
      actionHandler: keyboardActionHandler,
      actionProvider: calloutActionProvider
    ),
    input: InputCalloutContext(
      isEnabled: UIDevice.current.userInterfaceIdiom == .phone)
  )

  /**
   The default, observable dictation context.

   默认的, 可观测听写上下文。

   This is used as global dictation state and will be used
   to communicate between an app and its keyboard.

   这是全局听写状态，将用于应用程序与其键盘之间的通信。
   */
  // public lazy var dictationContext = DictationContext()

  /**
   The default, observable keyboard context.

   默认的, 可观察键盘上下文。

   This is used as global state for the keyboard's overall
   state and configuration like locale, device, screen etc.

   这是键盘整体状态和配置（如本地、设备、屏幕等）的全局状态。
   */
  public lazy var keyboardContext = KeyboardContext(controller: self)

  /**
   The default, observable feedback settings.

   默认的，可观察的反馈设置。

   This property is used as a global configuration for the
   keyboard's feedback, e.g. audio and haptic feedback.

   该属性用作键盘反馈（如音频和触觉反馈）的全局配置。
   */
  public lazy var keyboardFeedbackSettings = KeyboardFeedbackSettings()

  /**
   The default, observable keyboard text context.

   默认的、可观察到的键盘文本上下文。

   This is used as global state to let you observe text in
   the ``textDocumentProxy``.

   这将作为全局状态，让您观察 ``textDocumentProxy`` 中的文本。
   */
  public lazy var keyboardTextContext = KeyboardTextContext()

  // MARK: - Services

  /**
   The autocomplete provider that is used to provide users
   with autocomplete suggestions.

   用于向用户提供自动完成建议的自动完成 provider。

   You can replace this with a custom implementation.

   您可以用自定义实现来替代它。
   */
  public lazy var autocompleteProvider: AutocompleteProvider = DisabledAutocompleteProvider()

  /**
   The callout action provider that is used to provide the
   keyboard with secondary callout actions.

   用于为键盘提供辅助呼出操作的呼出操作 provider。

   You can replace this with a custom implementation.

   您可以用自定义实现来替代它。
   */
  public lazy var calloutActionProvider: CalloutActionProvider = StandardCalloutActionProvider(
    keyboardContext: keyboardContext
  ) {
    didSet { refreshProperties() }
  }

  /**
   The dictation service that is used to perform dictation
   operation between the keyboard and the main app.

   用于在键盘和主应用程序之间执行听写操作的听写服务。

   You can replace this with a custom implementation.

   您可以用自定义实现来替代它。
   */
//  public lazy var dictationService: KeyboardDictationService = DisabledKeyboardDictationService(
//    context: dictationContext
//  )

  /**
   The input set provider that is used to define the input
   keys of the keyboard.

   输入集提供程序，用于定义键盘的输入键。

   You can replace this with a custom implementation.

   您可以用自定义实现来替代它。
   */
  public lazy var inputSetProvider: InputSetProvider = StandardInputSetProvider(
    keyboardContext: keyboardContext
  ) {
    didSet { refreshProperties() }
  }

  /**
   The action handler that will be used by the keyboard to
   handle keyboard actions.

   用于处理按键 action 的 action 处理程序。

   You can replace this with a custom implementation.

   您可以用自定义实现来替代它。
   */
  public lazy var keyboardActionHandler: KeyboardActionHandler = StandardKeyboardActionHandler(inputViewController: self) {
    didSet { refreshProperties() }
  }

  /**
   The appearance that is used to customize the keyboard's
   design, such as its colors, fonts etc.

   You can replace this with a custom implementation.
   */
  public lazy var keyboardAppearance: KeyboardAppearance = StandardKeyboardAppearance(
    keyboardContext: keyboardContext)

  /**
   The behavior that is used to determine how the keyboard
   should behave when certain things happen.

   You can replace this with a custom implementation.
   */
  public lazy var keyboardBehavior: KeyboardBehavior = StandardKeyboardBehavior(
    keyboardContext: keyboardContext)

  /**
   The feedback handler that is used to trigger haptic and
   audio feedback.

   You can replace this with a custom implementation.
   */
  public lazy var keyboardFeedbackHandler: KeyboardFeedbackHandler = StandardKeyboardFeedbackHandler(
    settings: keyboardFeedbackSettings)

  /**
   This keyboard layout provider that is used to setup the
   complete set of keys and their layout.

   You can replace this with a custom implementation.
   */
  public lazy var keyboardLayoutProvider: KeyboardLayoutProvider = StandardKeyboardLayoutProvider(
    keyboardContext: keyboardContext,
    inputSetProvider: inputSetProvider
  )

  // MARK: - Text And Selection Change

  override open func selectionWillChange(_ textInput: UITextInput?) {
    super.selectionWillChange(textInput)
    resetAutocomplete()
  }

  override open func selectionDidChange(_ textInput: UITextInput?) {
    super.selectionDidChange(textInput)
    resetAutocomplete()
  }

  override open func textWillChange(_ textInput: UITextInput?) {
    super.textWillChange(textInput)
    if keyboardContext.textDocumentProxy === textDocumentProxy { return }
    keyboardContext.textDocumentProxy = textDocumentProxy
  }

  override open func textDidChange(_ textInput: UITextInput?) {
    super.textDidChange(textInput)
    performAutocomplete()
    performTextContextSync()
    tryChangeToPreferredKeyboardTypeAfterTextDidChange()
  }

  // MARK: - KeyboardController

  open func adjustTextPosition(byCharacterOffset offset: Int) {
    textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
  }

  open func deleteBackward() {
    textDocumentProxy.deleteBackward(range: keyboardBehavior.backspaceRange)
  }

  open func deleteBackward(times: Int) {
    textDocumentProxy.deleteBackward(times: times)
  }

  open func insertText(_ text: String) {
    textDocumentProxy.insertText(text)
  }

  open func selectNextKeyboard() {
    keyboardContext.selectNextLocale()
  }

  open func selectNextLocale() {
    keyboardContext.selectNextLocale()
  }

  open func setKeyboardType(_ type: KeyboardType) {
    keyboardContext.keyboardType = type
  }

  open func openUrl(_ url: URL?) {
    let selector = sel_registerName("openURL:")
    var responder = self as UIResponder?
    while let r = responder, !r.responds(to: selector) {
      responder = r.next
    }
    _ = responder?.perform(selector, with: url)
  }

  // MARK: - Syncing

  /**
   Whether or not context syncing is enabled.

   By default, context sync is enabled as long as the text
   text document proxy isn't reading full document context.
   */
  open var isContextSyncEnabled: Bool {
    !textDocumentProxy.isReadingFullDocumentContext
  }

  /**
   Perform a text context sync.

   This is performed anytime the text is changed to ensure
   that ``keyboardTextContext`` is synced with the current
   text document context content.
   */
  open func performTextContextSync() {
    guard isContextSyncEnabled else { return }
    keyboardTextContext.sync(with: self)
  }

  // MARK: - Autocomplete

  /**
   The text that is provided to the ``autocompleteProvider``
   when ``performAutocomplete()`` is called.

   By default, the text document proxy's current word will
   be used. You can override this property to change that.
   */
  open var autocompleteText: String? {
    textDocumentProxy.currentWord
  }

  /**
   Insert an autocomplete suggestion into the document.

   By default, this call the `insertAutocompleteSuggestion`
   in the text document proxy, and then triggers a release
   in the keyboard action handler.
   */
  open func insertAutocompleteSuggestion(_ suggestion: AutocompleteSuggestion) {
    textDocumentProxy.insertAutocompleteSuggestion(suggestion)
    keyboardActionHandler.handle(.release, on: .character(""))
  }

  /**
   Whether or not autocomple is enabled.

   By default, autocomplete is enabled as long as the text
   document proxy isn't reading full document context, and
   ``AutocompleteContext/isEnabled`` is `true`.
   */
  open var isAutocompleteEnabled: Bool {
    autocompleteContext.isEnabled && !textDocumentProxy.isReadingFullDocumentContext
  }

  /**
   Perform an autocomplete operation.

   You can override this function to extend or replace the
   default logic. By default, it uses the `currentWord` of
   the ``textDocumentProxy`` to perform autocomplete using
   the current ``autocompleteProvider``.
   */
  open func performAutocomplete() {
    guard isAutocompleteEnabled else { return }
    guard let text = autocompleteText else { return resetAutocomplete() }
    autocompleteProvider.autocompleteSuggestions(for: text) { [weak self] result in
      self?.updateAutocompleteContext(with: result)
    }
  }

  /**
   Reset the current autocomplete state.

   You can override this function to extend or replace the
   default logic. By default, it resets the suggestions in
   the ``autocompleteContext``.
   */
  open func resetAutocomplete() {
    autocompleteContext.reset()
  }

  // MARK: - Dictation

  /**
   The configuration to use when performing dictation from
   the keyboard extension.

   By default, this uses the `appGroupId` and `appDeepLink`
   properties from ``dictationContext``, so make sure that
   you call ``DictationContext/setup(with:)`` before using
   the dictation features in your keyboard extension.
   */
  public var dictationConfig: KeyboardDictationConfiguration {
    .init(
      appGroupId: dictationContext.appGroupId ?? "",
      appDeepLink: dictationContext.appDeepLink ?? ""
    )
  }

  /**
   Perform a keyboard-initiated dictation operation.

   > Important: ``DictationContext/appDeepLink`` must have
   been set before this is called. The link must open your
   app and start dictation. See the docs for more info.
   */
  public func performDictation() {
    Task {
      do {
        try await dictationService.startDictationFromKeyboard(with: dictationConfig)
      } catch {
        await MainActor.run {
          dictationContext.lastError = error
        }
      }
    }
  }
}

// MARK: - Private Functions

private extension KeyboardInputViewController {
  func refreshProperties() {
    refreshLayoutProvider()
    refreshCalloutActionContext()
  }

  func refreshCalloutActionContext() {
    calloutContext.action = ActionCalloutContext(
      actionHandler: keyboardActionHandler,
      actionProvider: calloutActionProvider
    )
  }

  func refreshLayoutProvider() {
    keyboardLayoutProvider.register(
      inputSetProvider: inputSetProvider
    )
  }

  /**
   Set up an initial width to avoid broken SwiftUI layouts.
   */
  func setupInitialWidth() {
    view.frame.size.width = UIScreen.main.bounds.width
  }

  /**
   Setup locale observation to handle locale-based changes.
   */
  func setupLocaleObservation() {
    keyboardContext.$locale.sink { [weak self] in
      guard let self = self else { return }
      let locale = $0
      self.primaryLanguage = locale.identifier
      self.autocompleteProvider.locale = locale
    }.store(in: &cancellables)
  }

  /**
   Set up the standard next keyboard button behavior.
   */
  func setupNextKeyboardBehavior() {
    NextKeyboardController.shared = self
  }

  func tryChangeToPreferredKeyboardTypeAfterTextDidChange() {
    let context = keyboardContext
    let shouldSwitch = keyboardBehavior.shouldSwitchToPreferredKeyboardTypeAfterTextDidChange()
    guard shouldSwitch else { return }
    setKeyboardType(context.preferredKeyboardType)
  }

  /**
   Update the autocomplete context with a certain result.

   This is performed async to avoid that any network-based
   operations update the context from a background thread.
   */
  func updateAutocompleteContext(with result: AutocompleteResult) {
    DispatchQueue.main.async { [weak self] in
      guard let context = self?.autocompleteContext else { return }
      switch result {
      case .failure(let error): context.lastError = error
      case .success(let result): context.suggestions = result
      }
    }
  }
}
#endif
