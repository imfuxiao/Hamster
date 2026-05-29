//
//  KeyboardRootView.swift
//
//
//  Created by morse on 2023/8/14.
//

import Combine
import HamsterKit
import HamsterUIKit
import OSLog
import UIKit

/**
 键盘根视图
 */
class KeyboardRootView: NibLessView {
  public typealias KeyboardWidth = CGFloat
  public typealias KeyboardItemWidth = CGFloat

  // MARK: - Properties

  private let keyboardLayoutProvider: KeyboardLayoutProvider
  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let layoutConfig: KeyboardLayoutConfiguration
  private var actionCalloutContext: ActionCalloutContext
  private var calloutContext: KeyboardCalloutContext
  private var inputCalloutContext: InputCalloutContext
  private var keyboardContext: KeyboardContext
  private var rimeContext: RimeContext

  private var subscriptions = Set<AnyCancellable>()

  /// 当前键盘类型
  private var currentKeyboardType: KeyboardType

  /// 当前屏幕方向
  private var interfaceOrientation: InterfaceOrientation

  /// 当前界面样式
  private var userInterfaceStyle: UIUserInterfaceStyle

  /// 键盘是否浮动
  private var isKeyboardFloating: Bool

  /// 工具栏收起时约束
  private var toolbarCollapseDynamicConstraints = [NSLayoutConstraint]()

  /// 工具栏展开时约束
  private var toolbarExpandDynamicConstraints = [NSLayoutConstraint]()

  /// 工具栏高度约束
  private var toolbarHeightConstraint: NSLayoutConstraint?

  /// 候选文字视图状态
  private var candidateViewState: CandidateBarView.State

  /// 是否显示设置面板
  private var isShowingSettingsPanel = false

  /// 是否显示文本回放面板
  private var isShowingTextPlaybackPanel = false

  /// 是否显示 GIF 面板
  private var isShowingGifPanel = false

  /// 是否显示 AI 建议面板
  private var isShowingAISuggestionsPanel = false

  /// 非主键盘的临时键盘Cache
  // private var tempKeyboardViewCache: [KeyboardType: UIView] = [:]

  // MARK: - 计算属性

//  private var actionCalloutStyle: KeyboardActionCalloutStyle {
//    var style = appearance.actionCalloutStyle
//    let insets = layoutConfig.buttonInsets
//    style.callout.buttonInset = insets
//    return style
//  }

//  private var inputCalloutStyle: KeyboardInputCalloutStyle {
//    var style = appearance.inputCalloutStyle
//    let insets = layoutConfig.buttonInsets
//    style.callout.buttonInset = insets
//    return style
//  }

  // MARK: - subview

  /// 26键键盘，包含默认中文26键及英文26键
  /// 注意：计算属性， 在 primaryKeyboardView 闭包中按需创建
  private var standerSystemKeyboard: StanderSystemKeyboard {
    let view = StanderSystemKeyboard(
      keyboardLayoutProvider: keyboardLayoutProvider,
      appearance: appearance,
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      rimeContext: rimeContext,
      calloutContext: calloutContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// 中文九宫格键盘
  /// 注意：计算属性， 在 primaryKeyboardView 闭包中按需创建
  private var chineseNineGridKeyboardView: ChineseNineGridKeyboard {
    let view = ChineseNineGridKeyboard(
      keyboardLayoutProvider: keyboardLayoutProvider,
      actionHandler: actionHandler,
      appearance: appearance,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      rimeContext: rimeContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// 数字九宫格键盘
  /// 注意：计算属性
  private var numericNineGridKeyboardView: UIView {
    let view = NumericNineGridKeyboard(
      actionHandler: actionHandler,
      appearance: appearance,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      rimeContext: rimeContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// 符号分类键盘
  /// 注意：计算属性
  private var classifySymbolicKeyboardView: ClassifySymbolicKeyboard {
    let view = ClassifySymbolicKeyboard(
      actionHandler: actionHandler,
      appearance: appearance,
      layoutProvider: keyboardLayoutProvider,
      keyboardContext: keyboardContext
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// emoji键盘
  /// 注意：计算属性
  private var emojisKeyboardView: UIView {
    // TODO:
    let view = UIView()
    view.backgroundColor = .red
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  /// 工具栏
  private lazy var toolbarView: KeyboardToolbarView = {
    let view = KeyboardToolbarView(appearance: appearance, actionHandler: actionHandler, keyboardContext: keyboardContext, rimeContext: rimeContext)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.onSettingsButtonTapped = { [weak self] in
      self?.toggleSettingsPanel()
    }
    view.onTextPlaybackButtonTapped = { [weak self] in
      self?.toggleTextPlaybackPanel()
    }
    view.onGifButtonTapped = { [weak self] in
      self?.toggleGifPanel()
    }
    view.onAISuggestionsButtonTapped = { [weak self] in
      self?.toggleAISuggestionsPanel()
    }
    view.onBackToKeyboardTapped = { [weak self] in
      self?.backToKeyboard()
    }
    return view
  }()

  /// 设置面板
  private lazy var settingsPanelView: SettingsPanelView = {
    let view = SettingsPanelView(style: appearance.candidateBarStyle)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  /// 文本回放面板
  private lazy var textPlaybackPanelView: TextPlaybackPanelView = {
    let view = TextPlaybackPanelView(style: appearance.candidateBarStyle)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    view.onPlay = { [weak self] text, isMultiTrack in
      self?.handleTextPlayback(text, isMultiTrack: isMultiTrack)
    }
    return view
  }()

  /// GIF 面板
  private lazy var gifPanelView: GifPanelView = {
    let view = GifPanelView(style: appearance.candidateBarStyle)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    view.onSearch = { [weak self] searchText in
      self?.handleGifSearch(searchText)
    }
    view.onTagTapped = { [weak self] tag in
      self?.handleGifTagTapped(tag)
    }
    view.onGifSelected = { [weak self] emoji in
      self?.handleGifSelected(emoji)
    }
    return view
  }()

  /// AI 建议面板
  private lazy var aiSuggestionsPanelView: AISuggestionsPanelView = {
    let view = AISuggestionsPanelView(style: appearance.candidateBarStyle)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    view.onCopySuggestion = { [weak self] text in
      self?.handleCopySuggestion(text)
    }
    view.onSendSuggestion = { [weak self] text in
      self?.handleSendSuggestion(text)
    }
    view.onRegenerate = { [weak self] in
      self?.handleRegenerateSuggestions()
    }
    return view
  }()

  /// 主键盘
  private lazy var primaryKeyboardView: UIView = {
    if let view = chooseKeyboard(keyboardType: keyboardContext.keyboardType) {
      return view
    }
    return standerSystemKeyboard
  }()

  // MARK: - Initializations

  /**
   Create a system keyboard with custom button views.

   The provided `buttonView` builder will be used to build
   the full button view for every layout item.

   - Parameters:
     - keyboardLayoutProvider: The keyboard layout provider to use.
     - appearance: The keyboard appearance to use.
     - actionHandler: The action handler to use.
     - autocompleteContext: The autocomplete context to use.
     - autocompleteToolbar: The autocomplete toolbar mode to use.
     - autocompleteToolbarAction: The action to trigger when tapping an autocomplete suggestion.
     - keyboardContext: The keyboard context to use.
     - calloutContext: The callout context to use.
     - width: The keyboard width.
   */
  public init(
    keyboardLayoutProvider: KeyboardLayoutProvider,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?,
    rimeContext: RimeContext
  ) {
    self.keyboardLayoutProvider = keyboardLayoutProvider
    self.layoutConfig = .standard(for: keyboardContext)
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.keyboardContext = keyboardContext
    self.calloutContext = calloutContext ?? .disabled
    self.actionCalloutContext = calloutContext?.action ?? .disabled
    self.inputCalloutContext = calloutContext?.input ?? .disabled
    self.rimeContext = rimeContext
    self.candidateViewState = keyboardContext.candidatesViewState
    self.currentKeyboardType = keyboardContext.keyboardType
    self.interfaceOrientation = keyboardContext.interfaceOrientation
    self.isKeyboardFloating = keyboardContext.isKeyboardFloating
    self.userInterfaceStyle = keyboardContext.colorScheme

    super.init(frame: .zero)

    // Test
//    let view = UIView()
//    view.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
//    view.backgroundColor = .yellow
//    addSubview(view)

    constructViewHierarchy()
    activateViewConstraints()
    setupAppearance()

    combine()
  }

  deinit {
    subviews.forEach { $0.removeFromSuperview() }
  }

  override func setupAppearance() {
    backgroundColor = appearance.backgroundStyle.backgroundColor
    contentMode = .redraw
  }

  // MARK: - Layout

  /// 构建视图层次
  override func constructViewHierarchy() {
    if keyboardContext.enableToolbar {
      addSubview(toolbarView)
      addSubview(settingsPanelView)
      addSubview(textPlaybackPanelView)
      addSubview(gifPanelView)
      addSubview(aiSuggestionsPanelView)
      addSubview(primaryKeyboardView)
    } else {
      addSubview(primaryKeyboardView)
    }
  }

  /// 激活约束
  override func activateViewConstraints() {
    if keyboardContext.enableToolbar {
      // 工具栏高度约束，可随配置调整高度
      toolbarHeightConstraint = toolbarView.heightAnchor.constraint(equalToConstant: keyboardContext.heightOfToolbar)

      // 工具栏静态约束
      let toolbarStaticConstraint = createToolbarStaticConstraints()

      // 工具栏收缩时动态约束
      toolbarCollapseDynamicConstraints = createToolbarCollapseDynamicConstraints()

      // 工具栏展开时动态约束
      toolbarExpandDynamicConstraints = createToolbarExpandDynamicConstraints()

      // 设置面板约束
      let settingsPanelConstraints = createSettingsPanelConstraints()

      // 文本回放面板约束
      let textPlaybackPanelConstraints = createTextPlaybackPanelConstraints()

      // GIF 面板约束
      let gifPanelConstraints = createGifPanelConstraints()

      // AI 建议面板约束
      let aiSuggestionsPanelConstraints = createAISuggestionsPanelConstraints()

      NSLayoutConstraint.activate(toolbarStaticConstraint + toolbarCollapseDynamicConstraints + [toolbarHeightConstraint!] + settingsPanelConstraints + textPlaybackPanelConstraints + gifPanelConstraints + aiSuggestionsPanelConstraints)
    } else {
      NSLayoutConstraint.activate(createNoToolbarConstraints())
    }
  }

  /// 工具栏静态约束（不会发生变动）
  func createToolbarStaticConstraints() -> [NSLayoutConstraint] {
    return [
      toolbarView.topAnchor.constraint(equalTo: topAnchor),
      toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
      toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ]
  }

  /// 工具栏展开时动态约束
  func createToolbarExpandDynamicConstraints() -> [NSLayoutConstraint] {
    return [
      toolbarView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ]
  }

  /// 工具栏收缩时动态约束
  func createToolbarCollapseDynamicConstraints() -> [NSLayoutConstraint] {
    return [
      primaryKeyboardView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
      primaryKeyboardView.bottomAnchor.constraint(equalTo: bottomAnchor),
      primaryKeyboardView.leadingAnchor.constraint(equalTo: leadingAnchor),
      primaryKeyboardView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ]
  }

  /// 无工具栏时约束
  func createNoToolbarConstraints() -> [NSLayoutConstraint] {
    return [
      primaryKeyboardView.topAnchor.constraint(equalTo: topAnchor),
      primaryKeyboardView.bottomAnchor.constraint(equalTo: bottomAnchor),
      primaryKeyboardView.leadingAnchor.constraint(equalTo: leadingAnchor),
      primaryKeyboardView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ]
  }

  /// 设置面板约束
  func createSettingsPanelConstraints() -> [NSLayoutConstraint] {
    return [
      settingsPanelView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
      settingsPanelView.bottomAnchor.constraint(equalTo: bottomAnchor),
      settingsPanelView.leadingAnchor.constraint(equalTo: leadingAnchor),
      settingsPanelView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ]
  }

  /// 文本回放面板约束
  func createTextPlaybackPanelConstraints() -> [NSLayoutConstraint] {
    return [
      textPlaybackPanelView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
      textPlaybackPanelView.bottomAnchor.constraint(equalTo: bottomAnchor),
      textPlaybackPanelView.leadingAnchor.constraint(equalTo: leadingAnchor),
      textPlaybackPanelView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ]
  }

  /// GIF 面板约束
  func createGifPanelConstraints() -> [NSLayoutConstraint] {
    return [
      gifPanelView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
      gifPanelView.bottomAnchor.constraint(equalTo: bottomAnchor),
      gifPanelView.leadingAnchor.constraint(equalTo: leadingAnchor),
      gifPanelView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ]
  }

  /// AI 建议面板约束
  func createAISuggestionsPanelConstraints() -> [NSLayoutConstraint] {
    return [
      aiSuggestionsPanelView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
      aiSuggestionsPanelView.bottomAnchor.constraint(equalTo: bottomAnchor),
      aiSuggestionsPanelView.leadingAnchor.constraint(equalTo: leadingAnchor),
      aiSuggestionsPanelView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ]
  }

  /// 切换设置面板显示
  func toggleSettingsPanel() {
    isShowingSettingsPanel.toggle()
    settingsPanelView.isHidden = !isShowingSettingsPanel
    primaryKeyboardView.isHidden = isShowingSettingsPanel
    textPlaybackPanelView.isHidden = true
    aiSuggestionsPanelView.isHidden = true
    isShowingTextPlaybackPanel = false
    isShowingAISuggestionsPanel = false
    
    if isShowingSettingsPanel {
      toolbarView.showBackToKeyboardButton()
    } else {
      toolbarView.hideBackToKeyboardButton()
    }
  }

  /// 切换文本回放面板显示
  func toggleTextPlaybackPanel() {
    isShowingTextPlaybackPanel.toggle()
    textPlaybackPanelView.isHidden = !isShowingTextPlaybackPanel
    primaryKeyboardView.isHidden = isShowingTextPlaybackPanel
    settingsPanelView.isHidden = true
    gifPanelView.isHidden = true
    aiSuggestionsPanelView.isHidden = true
    isShowingSettingsPanel = false
    isShowingGifPanel = false
    isShowingAISuggestionsPanel = false
    
    if isShowingTextPlaybackPanel {
      toolbarView.showBackToKeyboardButton()
    } else {
      toolbarView.hideBackToKeyboardButton()
    }
  }

  /// 切换 GIF 面板显示
  func toggleGifPanel() {
    isShowingGifPanel.toggle()
    gifPanelView.isHidden = !isShowingGifPanel
    primaryKeyboardView.isHidden = isShowingGifPanel
    settingsPanelView.isHidden = true
    textPlaybackPanelView.isHidden = true
    aiSuggestionsPanelView.isHidden = true
    isShowingSettingsPanel = false
    isShowingTextPlaybackPanel = false
    isShowingAISuggestionsPanel = false
    
    if isShowingGifPanel {
      toolbarView.showBackToKeyboardButton()
    } else {
      toolbarView.hideBackToKeyboardButton()
    }
  }

  /// 切换 AI 建议面板显示
  func toggleAISuggestionsPanel() {
    isShowingAISuggestionsPanel.toggle()
    aiSuggestionsPanelView.isHidden = !isShowingAISuggestionsPanel
    primaryKeyboardView.isHidden = isShowingAISuggestionsPanel
    settingsPanelView.isHidden = true
    textPlaybackPanelView.isHidden = true
    isShowingSettingsPanel = false
    isShowingTextPlaybackPanel = false
    
    if isShowingAISuggestionsPanel {
      toolbarView.showBackToKeyboardButton()
    } else {
      toolbarView.hideBackToKeyboardButton()
    }
  }
  
  /// 返回键盘
  func backToKeyboard() {
    isShowingSettingsPanel = false
    isShowingTextPlaybackPanel = false
    isShowingGifPanel = false
    isShowingAISuggestionsPanel = false
    
    settingsPanelView.isHidden = true
    textPlaybackPanelView.isHidden = true
    gifPanelView.isHidden = true
    aiSuggestionsPanelView.isHidden = true
    primaryKeyboardView.isHidden = false
    
    toolbarView.hideBackToKeyboardButton()
  }

  // MARK: - AI 建议处理

  /// 处理复制建议
  func handleCopySuggestion(_ text: String) {
    // 文本已经在 AISuggestionItemView 中复制到剪贴板
    // 这里可以添加额外的反馈，比如显示提示
  }

  /// 处理发送建议
  func handleSendSuggestion(_ text: String) {
    // 将文本插入到输入框
    // TODO: 需要通过 actionHandler 将文本发送到输入框
    // 暂时先返回键盘
    backToKeyboard()
  }

  /// 处理重新生成建议
  func handleRegenerateSuggestions() {
    // TODO: 调用 AI API 重新生成建议
    // 暂时使用示例数据
    let newSuggestions = [
      "我觉得这个想法很有前景！",
      "完全同意你的观点。",
      "这个方向确实值得探索。"
    ]
    aiSuggestionsPanelView.updateSuggestions(newSuggestions)
  }

  // MARK: - GIF 面板处理

  /// 处理 GIF 搜索
  func handleGifSearch(_ searchText: String) {
    // TODO: 调用 GIF API 搜索
    // 暂时使用示例数据
    let newEmojis = ["🤣", "😜", "🥳", "😇", "🤩", "😍", "🤗", "😊", "🤭"]
    gifPanelView.updateGifEmojis(newEmojis)
  }

  /// 处理 GIF 标签点击
  func handleGifTagTapped(_ tag: String) {
    // TODO: 根据标签搜索 GIF
    // 暂时使用示例数据
    if tag.hasPrefix("AI") {
      let aiEmojis = ["🙏", "🤝", "👏", "💪", "🌟", "✨", "🎊", "🎁", "🏆"]
      gifPanelView.updateGifEmojis(aiEmojis)
    } else {
      let randomEmojis = ["😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "😉", "😊"]
      gifPanelView.updateGifEmojis(randomEmojis)
    }
  }

  /// 处理 GIF 选择
  func handleGifSelected(_ emoji: String) {
    // 将 emoji 复制到剪贴板
    UIPasteboard.general.string = emoji
    // 返回键盘
    backToKeyboard()
  }

  // MARK: - 文本回放处理

  /// 处理文本回放
  func handleTextPlayback(_ text: String, isMultiTrack: Bool) {
    guard !text.isEmpty else { return }
    // TODO: 调用钢琴音播放功能
    // 暂时显示提示
    print("播放文本: \(text), 多轨叠加: \(isMultiTrack)")
  }

  func combine() {
    // 在开启工具栏的状态下，根据候选状态调节候选栏区域大小
    if keyboardContext.enableToolbar {
      keyboardContext.$candidatesViewState
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
          guard candidateViewState != $0 else { return }
          setNeedsLayout()
        }
        .store(in: &subscriptions)
    }

    // 跟踪 UIUserInterfaceStyle 变化
    keyboardContext.$traitCollection
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        guard userInterfaceStyle != $0.userInterfaceStyle else { return }
        userInterfaceStyle = $0.userInterfaceStyle
        setupAppearance()
        if keyboardContext.enableToolbar {
          toolbarView.setNeedsLayout()
        }
        primaryKeyboardView.setNeedsLayout()
      }
      .store(in: &subscriptions)

    // 屏幕方向改变调整按键高度及按键内距
    keyboardContext.$interfaceOrientation
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        guard $0 != self.interfaceOrientation else { return }
        self.interfaceOrientation = $0
        self.primaryKeyboardView.setNeedsLayout()
      }
      .store(in: &subscriptions)

    // iPad 浮动模式开启
    keyboardContext.$isKeyboardFloating
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        guard self.isKeyboardFloating != $0 else { return }
        self.isKeyboardFloating = $0
        self.primaryKeyboardView.setNeedsLayout()
      }
      .store(in: &subscriptions)

    // 跟踪键盘类型变化
    keyboardContext.keyboardTypePublished
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        guard $0 != currentKeyboardType else { return }
        currentKeyboardType = $0

        Logger.statistics.debug("KeyboardRootView keyboardType combine: \($0.yamlString)")

        guard let keyboardView = chooseKeyboard(keyboardType: $0) else {
          Logger.statistics.error("\($0.yamlString) cannot find keyboardView.")
          return
        }

        if keyboardContext.enableToolbar {
          // NSLayoutConstraint.deactivate(toolbarCollapseDynamicConstraints)
          toolbarCollapseDynamicConstraints.removeAll(keepingCapacity: true)
          toolbarExpandDynamicConstraints.removeAll(keepingCapacity: true)

          primaryKeyboardView.subviews.forEach { $0.removeFromSuperview() }
          primaryKeyboardView.removeFromSuperview()

          primaryKeyboardView = keyboardView
          addSubview(primaryKeyboardView)

          // 工具栏收缩时约束
          toolbarCollapseDynamicConstraints = createToolbarCollapseDynamicConstraints()

          // 工具栏展开时约束
          toolbarExpandDynamicConstraints = createToolbarExpandDynamicConstraints()

          NSLayoutConstraint.activate(toolbarCollapseDynamicConstraints)
        } else {
          NSLayoutConstraint.deactivate(constraints)
          primaryKeyboardView.removeFromSuperview()
          primaryKeyboardView = keyboardView
          addSubview(primaryKeyboardView)
          NSLayoutConstraint.activate(createNoToolbarConstraints())
        }
      }
      .store(in: &subscriptions)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // Logger.statistics.debug("KeyboardRootView: layoutSubviews()")

    // 检测候选栏状态是否发生变化
    guard candidateViewState != keyboardContext.candidatesViewState else { return }
    candidateViewState = keyboardContext.candidatesViewState

    // 候选栏收起
    if candidateViewState.isCollapse() {
      // 键盘显示
      toolbarHeightConstraint?.constant = keyboardContext.heightOfToolbar
      addSubview(primaryKeyboardView)
      NSLayoutConstraint.deactivate(toolbarExpandDynamicConstraints)
      NSLayoutConstraint.activate(toolbarCollapseDynamicConstraints)
    } else {
      // 键盘隐藏
      let toolbarHeight = primaryKeyboardView.bounds.height + keyboardContext.heightOfToolbar
      primaryKeyboardView.removeFromSuperview()

      toolbarHeightConstraint?.constant = toolbarHeight
      NSLayoutConstraint.deactivate(toolbarCollapseDynamicConstraints)
      NSLayoutConstraint.activate(toolbarExpandDynamicConstraints)
    }
  }

  /// 根据键盘类型选择键盘
  func chooseKeyboard(keyboardType: KeyboardType) -> UIView? {
//    // 从 cache 中获取键盘
//    if let tempKeyboardView = tempKeyboardViewCache[keyboardType] {
//      return tempKeyboardView
//    }

    // 生成临时键盘
    var tempKeyboardView: UIView? = nil
    switch keyboardType {
    case .numericNineGrid:
      tempKeyboardView = numericNineGridKeyboardView
    case .classifySymbolic:
      tempKeyboardView = classifySymbolicKeyboardView
    case .emojis:
      tempKeyboardView = emojisKeyboardView
    case .alphabetic, .numeric, .symbolic, .chinese, .chineseNumeric, .chineseSymbolic, .custom:
      tempKeyboardView = standerSystemKeyboard
    case .chineseNineGrid:
      tempKeyboardView = chineseNineGridKeyboardView
    default:
      // 注意：非临时键盘类型外的类型直接 return
      Logger.statistics.error("keyboardType: \(keyboardType.yamlString) not match tempKeyboardType")
      return nil
    }

    // 保存 cache
//    tempKeyboardViewCache[keyboardType] = tempKeyboardView
    return tempKeyboardView
  }
}
