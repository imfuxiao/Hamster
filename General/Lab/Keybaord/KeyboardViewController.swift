#if os(iOS)
import Combine
import Foundation
import KeyboardKit
import LibrimeKit
import os
import UIKit

/// TODO 键盘启动时间监控
// @available(iOS 15.0, *)
// let signposter = OSSignposter(subsystem: "com.ihsiao.app.hamster", category: "keybaord")
//
// @available(iOS 15.0, *)
// let signpostID = signposter.makeSignpostID()
//
// let name: StaticString = "keyboard"
//
//// Begin a signposted interval and keep a reference to the
//// returned interval state.
// @available(iOS 15.0, *)
// var state = signposter.beginInterval(name, id: signpostID, "keyboard start begin")

// Hamster键盘Controller
open class HamsterKeyboardViewController: KeyboardInputViewController {
  // MARK: - View Controller Lifecycle

//  @objc func keyboardWillShow(note: NSNotification) {
//
//  }

  override public func viewDidLoad() {
    self.log.info("viewDidLoad() begin")

    // 注册通知
    // NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

    // 注意初始化的顺序

    // TODO: 动态设置 local
//    self.keyboardContext.locale = Locale(identifier: "zh-Hans")
//    self.log.info("local language: \(Locale.preferredLanguages[0])")
//    self.log.info("local language: \(Locale.autoupdatingCurrent.identifier)")
//    self.log.info("local language: \(Locale.autoupdatingCurrent.languageCode)")
//    self.log.info("local language: \(Locale.current.identifier)")
//    self.log.info("local language: \(Locale.current.languageCode)")
    let identifier = String(Locale.current.identifier.split(separator: "_")[0])
    self.keyboardContext.locale = Locale(identifier: identifier)

    // 外观
    self.keyboardAppearance = HamsterKeyboardAppearance(
      keyboardContext: self.keyboardContext,
      rimeContext: self.rimeContext,
      appSettings: self.appSettings
    )
    // 布局
    self.keyboardLayoutProvider = HamsterStandardKeyboardLayoutProvider(
      keyboardContext: self.keyboardContext,
      inputSetProvider: self.hamsterInputSetProvider,
      appSettings: self.appSettings,
      rimeContext: self.rimeContext
    )

    // 键盘默认行为: 这里可以做如改变键盘的类型
    self.keyboardBehavior = HamsterKeyboardBehavior(
      keyboardContext: self.keyboardContext,
      appSettings: self.appSettings,
      rimeContext: self.rimeContext
    )

    // 气泡功能设置
    self.calloutActionProvider = HamsterCalloutActionProvider(
      keyboardContext: self.keyboardContext,
      rimeContext: self.rimeContext
    )

    // 键盘反馈设置
    self.keyboardFeedbackSettings = KeyboardFeedbackSettings(
      audioConfiguration: AudioFeedbackConfiguration(),
      hapticConfiguration: HapticFeedbackConfiguration()
    )
    self.keyboardFeedbackHandler = HamsterKeyboardFeedbackHandler(
      settings: self.keyboardFeedbackSettings,
      appSettings: self.appSettings
    )
    // 键盘Action处理
    self.keyboardActionHandler = HamsterKeyboardActionHandler(
      inputViewController: self,
      keyboardContext: self.keyboardContext,
      keyboardFeedbackHandler: self.keyboardFeedbackHandler
    )

    // Action 结束后可执行的动作
    self.calloutContext = KeyboardCalloutContext(
      action: HamsterActionCalloutContext(
        keyboardContext: keyboardContext,
        actionHandler: keyboardActionHandler,
        actionProvider: calloutActionProvider
      ),
      input: InputCalloutContext(
        isEnabled: UIDevice.current.userInterfaceIdiom == .phone
      )
    )
    self.setupAppSettings()
    super.viewDidLoad()
  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    DispatchQueue.global().async {
      self.setupRime()
    }
  }

  override public func viewDidDisappear(_ animated: Bool) {
    self.log.debug("viewDidDisappear()")
    Rime.shared.shutdown()
    super.viewDidDisappear(animated)

    // 取消监听
    // NotificationCenter.default.removeObserver(self)
  }

  override open func viewDidLayoutSubviews() {
    self.log.debug("viewDidLayoutSubviews()")

    super.viewDidLayoutSubviews()

    // 过滤掉不合理的 view width
    guard self.view.frame.width > 0 else {
      return
    }

    // 在 iPad 浮动键盘里强制显示 iPhone 布局
    let deviceTypeToUse = DeviceType.current == .pad && self.keyboardContext.isKeyboardFloating ? DeviceType.phone : DeviceType.current
    if self.keyboardContext.deviceType != deviceTypeToUse {
      self.keyboardContext.deviceType = deviceTypeToUse
      viewWillSetupKeyboard()
    }
  }

  override public func viewWillSetupKeyboard() {
//    super.viewWillSetupKeyboard()
    self.log.debug("viewWillSetupKeyboard() begin")

    // 初始键盘类型
    if let keyboardType = self.textDocumentProxy.keyboardType, keyboardType.isNumberType {
      self.keyboardContext.keyboardType = keyboardCustomType.numberNineGrid.keyboardType
    }

    self.setup {
      let ivc = $0 as! HamsterKeyboardViewController

//      let screenWidth = UIScreen.main.bounds.size.width
//      Logger.shared.log.debug("screenWidth: \(screenWidth)")
//      let screenWidthInPixels = screenWidth * UIScreen.main.scale
//      Logger.shared.log.debug("screenWidthInPixels: \(screenWidthInPixels)")
//      Logger.shared.log.debug("ivc.view.frame.width: \(ivc.view.frame.width)")
//      Logger.shared.log.debug("ivc.view.frame.safeAreaLayoutGuide: \(ivc.view.safeAreaLayoutGuide)")
//      Logger.shared.log.debug("ivc.view.frame.safeAreaLayoutGuide: \(ivc.view.bounds.size.width)")

      // fix: 横向状态下 ivc.view.frame.width 与 UIScreen.main.bounds.size.width 相等，导致键盘显示溢出
      // 150 为键盘两边切换按钮和听写区域宽度
      // 812 - 662 = 150
      var width = ivc.view.frame.width
      if !ivc.keyboardContext.isPortrait && width == UIScreen.main.bounds.size.width && ivc.keyboardContext.isFullScreen {
        if width > 900 {
          width -= 230
        } else {
          width -= 150
        }
      }

      return HamsterSystemKeyboard(
        layout: ivc.keyboardLayoutProvider.keyboardLayout(for: ivc.keyboardContext),
        appearance: ivc.keyboardAppearance,
        actionHandler: ivc.keyboardActionHandler,
        keyboardContext: ivc.keyboardContext,
        calloutContext: ivc.calloutContext,
        appSettings: ivc.appSettings,
        width: width
      )
      .environmentObject(ivc.rimeContext)
      .environmentObject(ivc.appSettings)
      .environmentObject(ivc.keyboardActionHandler as! HamsterKeyboardActionHandler)
//      .onAppear {
//        if #available(iOS 15.0, *) {
//          signposter.endInterval(name, state, "keyboard start end")
//        }
//      }
    }
  }

  // MARK: fields

  private let log = Logger.shared.log
  public var rimeContext = RimeContext()
  public var appSettings = HamsterAppSettings()
  public var defaultCustomFilePath = RimeContext.appGroupUserDataDefaultCustomYaml.path
  var cancellables = Set<AnyCancellable>()
  var pairsSymbols = [String: String]()

  lazy var hamsterInputSetProvider: HamsterInputSetProvider = .init(
    keyboardContext: keyboardContext,
    appSettings: appSettings,
    rimeContext: rimeContext
  )

  private func setupAppSettings() {
    self.pairsSymbols = self.appSettings.pairsOfSymbols.reduce([String: String]()) {
      let pair = $1.trimmingCharacters(in: .whitespacesAndNewlines).chars
      guard pair.count == 2 else { return $0 }
      guard $0[pair[0]] == nil else { return $0 }
      var result = $0
      result[pair[0]] = $1
      return result
    }

    // 按键气泡
    self.appSettings.$showKeyPressBubble
      .receive(on: RunLoop.main)
      .sink { [weak self] in
        guard let self = self else { return }
        self.log.info("combine $showKeyPressBubble \($0)")
        self.calloutContext.input.isEnabled = $0
      }
      .store(in: &self.cancellables)

    // 数字九宫格不显示按键气泡
    self.keyboardContext.$keyboardType
      .receive(on: RunLoop.main)
      .sink { [weak self] keyboard in
        guard let self = self else { return }

        if keyboard.isNumberNineGrid {
          self.calloutContext.input.isEnabled = false
          return
        }

        self.calloutContext.input.isEnabled = self.appSettings.showKeyPressBubble
      }
      .store(in: &self.cancellables)

    // 候选字最大数量
    self.rimeContext.maxCandidateCount = Int(self.appSettings.rimeMaxCandidateSize)
  }

  private func setupRime() {
    // 判断是否对AppGroups目录有写入权限，如果没有则将方案复制到 Sandbox 目录下
    var useSandboxUserDataDirectory = false
    do {
      if !FileManager.default.isWritableFile(atPath: RimeContext.appGroupInstallationYaml.path) {
        useSandboxUserDataDirectory = true
      } else {
        // appGroup 补充 default.custom.yaml
        self.defaultCustomFilePath = RimeContext.appGroupUserDataDefaultCustomYaml.path
        if !FileManager.default.fileExists(atPath: self.defaultCustomFilePath) {
          let handled = FileManager.default.createFile(atPath: self.defaultCustomFilePath, contents: nil)
          Logger.shared.log.debug("create file \(self.defaultCustomFilePath), handled: \(handled)")
        }
      }

      Logger.shared.log.info("rime syncAppGroupUserDataDirectory: \(self.appSettings.rimeNeedOverrideUserDataDirectory), useSandboxUserDataDirectory: \(useSandboxUserDataDirectory)")

      if useSandboxUserDataDirectory {
        try RimeContext.syncAppGroupUserDataDirectoryToSandbox(override: self.appSettings.rimeNeedOverrideUserDataDirectory)
        if self.appSettings.rimeNeedOverrideUserDataDirectory {
          DispatchQueue.main.async {
            self.appSettings.rimeNeedOverrideUserDataDirectory = false
          }
        }

        // Sandbox 补充 default.custom.yaml
        self.defaultCustomFilePath = RimeContext.sandboxUserDataDefaultCustomYaml.path
        if !FileManager.default.fileExists(atPath: self.defaultCustomFilePath) {
          let handled = FileManager.default.createFile(atPath: self.defaultCustomFilePath, contents: nil)
          Logger.shared.log.debug("create file \(self.defaultCustomFilePath), handled: \(handled)")
        }
      }
    } catch {
      self.log.error("create rime directory error: \(error), \(error.localizedDescription)")
    }

    DispatchQueue.main.async {
      self.rimeContext.reset()
    }

    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: RimeContext.appGroupSharedSupportDirectoryURL.path,
      userDataDir: useSandboxUserDataDirectory ? RimeContext.sandboxUserDataDirectory.path : RimeContext.appGroupUserDataDirectoryURL.path
    ))

    // 设置输入方案
    self.changeRimeInputSchema()

    // 中文简繁状态切换
    self.syncTraditionalSimplifiedChineseMode()

    // 中英状态同步
    DispatchQueue.main.async {
      self.rimeContext.asciiMode = Rime.shared.isAsciiMode()
    }

    // 内嵌模式
    if self.appSettings.enableInputEmbeddedMode {
      self.rimeContext.$userInputKey
        .receive(on: DispatchQueue.main)
        .sink { [weak self] inputKey in
          guard let self = self else { return }

          // fix: 部分App(如 bilibili app 端的评论)上屏不会触发
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            self.textDocumentProxy.setMarkedText(inputKey, selectedRange: NSRange(location: inputKey.count, length: 0))
          }
        }
        .store(in: &self.cancellables)
    }

    // 加载Switcher切换键
    let hotKeys = Rime.shared.getHotkeys().split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
    if !hotKeys.isEmpty {
      self.rimeContext.hotKeys = hotKeys
    }
    Logger.shared.log.debug("hotkeys: \(self.rimeContext.hotKeys)")

    // 输入方案切换状态同步
    Rime.shared.setLoadingSchemaCallback(callback: { [weak self] loadSchema in
      guard let self = self else { return }
      let chars = loadSchema.split(separator: "/").map { String($0) }
      if !chars.isEmpty {
        if self.appSettings.rimeInputSchema != chars[0] {
          DispatchQueue.main.async {
            self.appSettings.lastUseRimeInputSchema = self.appSettings.rimeInputSchema
            self.appSettings.rimeInputSchema = chars[0]
          }
        }
        Logger.shared.log.debug("loading schema callback: rimeInputSchema = \(self.appSettings.rimeInputSchema), lastUseRimeInputSchema = \(self.appSettings.lastUseRimeInputSchema)")
      }
    })

    // mode切换同步
    Rime.shared.setChangeModeCallback(callback: { [weak self] mode in
      guard let self = self else { return }
      if mode.hasSuffix("ascii_mode") {
        DispatchQueue.main.async {
          self.rimeContext.asciiMode = !mode.hasPrefix("!")
          Logger.shared.log.debug("loading setChangeModeCallback asciiMode = \(self.rimeContext.asciiMode)")
        }
      }
    })
  }

  // MARK: - Text And Selection Change

  override open func selectionWillChange(_ textInput: UITextInput?) {
    super.selectionWillChange(textInput)
  }

  override open func selectionDidChange(_ textInput: UITextInput?) {
    super.selectionDidChange(textInput)
  }

  override open func textWillChange(_ textInput: UITextInput?) {
    super.textWillChange(textInput)
  }

  override open func textDidChange(_ textInput: UITextInput?) {
    super.textDidChange(textInput)

    // TODO: 这里添加英文自动转大写功能, 参考: KeyboardContext.preferredAutocapitalizedKeyboardType

    // fix: 输出栏点击右侧x形按钮后, 输入法候选栏内容没有跟随输入栏一同清空
    if !self.textDocumentProxy.hasText {
      self.rimeContext.reset()
    }
  }

  // MARK: - KeyboardController

  override open func insertText(_ text: String) {
    // 功能指令处理
    if self.functionalInstructionsHandled(text) {
      return
    }

    // 是否英文模式
    if self.rimeContext.asciiMode {
      self.inputTextPatch(text, false)
      // textDocumentProxy.insertText(text)
      return
    }

    // 调用输入法引擎
    self.inputCharacter(key: text)
  }

  override open func deleteBackward() {
    _ = self.inputRimeKeyCode(keyCode: XK_BackSpace)
  }

  override open func setKeyboardType(_ type: KeyboardType) {
    Logger.shared.log.debug("set keyboard: \(type)")
    keyboardContext.keyboardType = type
  }
}

extension HamsterKeyboardViewController {
  // 设置用户输入方案
  func changeRimeInputSchema() {
    let setInputSchemaHandle = Rime.shared.setSchema(self.appSettings.rimeInputSchema)
    self.log.info(
      "self.rimeEngine set schema: \(self.appSettings.rimeInputSchema), setInputSchemaHandle = \(setInputSchemaHandle)"
    )
  }

  // 同步中文简繁状态
  func syncTraditionalSimplifiedChineseMode() {
    let simplifiedModeKey = self.appSettings.rimeSimplifiedAndTraditionalSwitcherKey

    // 获取运行时状态
    let simplifiedModeValue = Rime.shared.simplifiedChineseMode(key: simplifiedModeKey)

    // 获取文件中保存状态
    let value = Rime.shared.API().getCustomize("patch/\(simplifiedModeKey)") ?? ""
    if !value.isEmpty {
      let handled = Rime.shared.setSimplifiedChineseMode(key: simplifiedModeKey, value: (value as NSString).boolValue)
      Logger.shared.log.debug("syncTraditionalSimplifiedChineseMode set runtime state. key: \(simplifiedModeKey), value: \(value), handled: \(handled)")
    } else {
      // 首次加载保存简繁状态
      let handled = Rime.shared.API().customize(simplifiedModeKey, stringValue: String(simplifiedModeValue))
      Logger.shared.log.debug("syncTraditionalSimplifiedChineseMode first save. key: \(simplifiedModeKey), value: \(simplifiedModeValue), handled: \(handled)")
    }
  }

  // rime 中文简繁状态切换
  func switchTraditionalSimplifiedChinese() {
    let simplifiedModeKey = self.appSettings.rimeSimplifiedAndTraditionalSwitcherKey
    let simplifiedModeValue = Rime.shared.simplifiedChineseMode(key: simplifiedModeKey)

    // 设置运行时状态
    var handled = Rime.shared.setSimplifiedChineseMode(key: simplifiedModeKey, value: !simplifiedModeValue)
    Logger.shared.log.debug("switchTraditionalSimplifiedChinese key: \(simplifiedModeKey), value: \(!simplifiedModeValue), handled: \(handled)")

    // 保存运行时状态
    handled = Rime.shared.API().customize(simplifiedModeKey, stringValue: String(!simplifiedModeValue))
    Logger.shared.log.debug("switchTraditionalSimplifiedChinese save file state. key: \(simplifiedModeKey), value: \(!simplifiedModeValue), handled: \(handled)")
  }

  // 中英切换
  func switchEnglishChinese() {
    //    中文模式下, 在已经有候选字的情况下, 切换英文模式.
    //
    //    情况1. 清空中文输入, 开始英文输入
    //    self.rimeEngine.reset()

    //    情况2. 候选栏字母上屏, 并开启英文输入
    var userInputKey = self.rimeContext.userInputKey
    if !userInputKey.isEmpty {
      userInputKey.removeAll(where: { $0 == " " })
      self.textDocumentProxy.insertText(userInputKey)
    }
    self.rimeContext.reset()
    //    情况3. 首选候选字上屏, 并开启英文输入
    //    _ = self.candidateTextOnScreen()
    self.rimeContext.asciiMode.toggle()
    let handled = Rime.shared.asciiMode(self.rimeContext.asciiMode)
    Logger.shared.log.debug("rime set ascii_mode handled \(handled)")
  }

  /// 三选上屏
  func thirdlyCandidateTextOnScreen() -> Bool {
    return self.selectCandidateIndex(index: 2)
  }

  /// 次选上屏
  func secondCandidateTextOnScreen() -> Bool {
    return self.selectCandidateIndex(index: 1)
  }

  /// 首选候选字上屏
  func candidateTextOnScreen() -> Bool {
    return self.selectCandidateIndex(index: 0)
  }

  func changeStateOfOnehandOnLeft() {
    let oldValue = self.appSettings.keyboardOneHandOnRight
    self.appSettings.keyboardOneHandOnRight = false
    if !oldValue {
      self.appSettings.enableKeyboardOneHandMode = !self.appSettings.enableKeyboardOneHandMode
    }
  }

  func changeStateOfOneHandOnRight() {
    let oldValue = self.appSettings.keyboardOneHandOnRight
    self.appSettings.keyboardOneHandOnRight = true
    if oldValue {
      self.appSettings.enableKeyboardOneHandMode = !self.appSettings.enableKeyboardOneHandMode
    }
  }

  // 光标移动句首
  func moveBeginOfSentence() {
    if let beforInput = self.textDocumentProxy.documentContextBeforeInput {
      if let lastIndex = beforInput.lastIndex(of: "\n") {
        let offset = beforInput[lastIndex ..< beforInput.endIndex].count - 1
        if offset > 0 {
          self.textDocumentProxy.adjustTextPosition(byCharacterOffset: -offset)
        }
      } else {
        self.textDocumentProxy.adjustTextPosition(byCharacterOffset: -beforInput.count)
      }
    }
  }

  // 光标移动句尾
  func moveEndOfSentence() {
    let offset = self.textDocumentProxy.documentContextAfterInput?.count ?? 0
    if offset > 0 {
      self.textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
    }
  }

  // 光标回退
  func cursorBackOfSymbols(key: String) -> Bool {
    if self.appSettings.cursorBackOfSymbols.contains(key) {
      self.textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
      return true
    }
    return false
  }

  // 成对上屏符号
  func getPairSymbols(_ key: String) -> String {
    if let pairValue = self.pairsSymbols[key] {
      return pairValue
    }
    return key
  }

  // 返回主键盘
  func returnToPrimaryKeyboardOfSymbols(key: String) -> Bool {
    self.appSettings.returnToPrimaryKeyboardOfSymbols.contains(key)
  }

  // 候选字上一页
  func previousPageOfCandidates() {
    if Rime.shared.inputKeyCode(XK_Page_Up) {
      self.syncContext()
    } else {
      Logger.shared.log.warning("rime input pageup result error")
    }
  }

  // 候选字下一页
  func nextPageOfCandidates() {
    if Rime.shared.inputKeyCode(XK_Page_Down) {
      self.syncContext()
    } else {
      Logger.shared.log.debug("rime input pageDown result error")
    }
  }

  /// 根据索引选择候选字
  func selectCandidateIndex(index: Int) -> Bool {
    let handled = Rime.shared.selectCandidate(index: index)
    self.updateRimeEngine(handled)
    return handled
  }

  /// 字符输入
  func inputCharacter(key: String) {
    // 由rime处理全部符号
    var handled = false
    let keyUTF8 = key.utf8
    if keyUTF8.count == 1, let first = keyUTF8.first {
      handled = self.inputRimeKeyCode(keyCode: Int32(first))
    }

    // 符号键直接上屏
    if !handled {
      // 符号顶码上屏
      _ = self.candidateTextOnScreen()
      DispatchQueue.main.async {
        self.inputTextPatch(key, false)
      }
    }
  }

  /// 转为RimeCode
  func inputRimeKeyCode(keyCode: Int32, modifier: Int32 = 0) -> Bool {
    var handled = Rime.shared.inputKeyCode(keyCode, modifier: modifier)
    if !handled {
      // 特殊功能键处理
      switch keyCode {
      case XK_Return:
        self.textDocumentProxy.insertText(.newline)
        handled = true
      case XK_BackSpace: // 退格
        let beforeInput = self.textDocumentProxy.documentContextBeforeInput ?? ""
        let afterInput = self.textDocumentProxy.documentContextAfterInput ?? ""
        // 光标可以居中的符号，成对删除
        if self.appSettings.cursorBackOfSymbols.contains(String(beforeInput.suffix(1) + afterInput.prefix(1))) {
          self.textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
          self.textDocumentProxy.deleteBackward(times: 2)
        } else {
          self.textDocumentProxy.deleteBackward()
        }
        handled = true
      case XK_Tab:
        self.textDocumentProxy.insertText(.tab)
        handled = true
      case XK_space:
        self.textDocumentProxy.insertText(.space)
        handled = true
      default:
        break
      }
    }
    self.updateRimeEngine(handled)
    return handled
  }

  private func updateRimeEngine(_ handled: Bool) {
    // 唯一码直接上屏
    let commitText = Rime.shared.getCommitText()
    if !commitText.isEmpty {
      self.inputTextPatch(commitText)
    }

    // 查看输入法状态
    let status = Rime.shared.status()

    // 如不存在候选字,则重置输入法
    if !status.isComposing {
      self.rimeContext.reset()
      return
    }

    if handled {
      self.syncContext()
    }
  }

  // 同步context: 主要是获取当前引擎提供的候选文字, 同时更新rime published属性 userInputKey
  func syncContext() {
    let context = Rime.shared.context()

    if context.composition != nil {
      self.rimeContext.userInputKey = context.composition.preedit ?? ""
    }

    // 获取候选字
    self.rimeContext.suggestions = self.rimeContext.candidateListLimit()
  }

  // TODO: 以#开头为功能
  /// 功能指令处理
  /// 返回值, 指令是否执行成功
  func functionalInstructionsHandled(_ instruction: String) -> Bool {
    if !instruction.hasPrefix("#") {
      return false
    }

    let function = FunctionalInstructions(rawValue: instruction)
    switch function {
    case .simplifiedTraditionalSwitch:
      self.switchTraditionalSimplifiedChinese()
    case .switchChineseOrEnglish:
      self.switchEnglishChinese()
    case .selectSecond:
      _ = self.secondCandidateTextOnScreen()
    case .thirdlySecond:
      _ = self.thirdlyCandidateTextOnScreen()
    case .beginOfSentence:
      self.moveBeginOfSentence()
    case .endOfSentence:
      self.moveEndOfSentence()
    case .selectInputSchema:
      self.appSettings.keyboardStatus = .switchInputSchema
    case .newLine:
      self.textDocumentProxy.insertText("\r")
    case .deleteInputKey:
      self.rimeContext.reset()
    case .selectColorSchema:
      // TODO: 颜色方案切换
      break
    case .switchLastInputSchema:
      if !self.appSettings.lastUseRimeInputSchema.isEmpty {
        let handled = Rime.shared.setSchema(self.appSettings.lastUseRimeInputSchema)
        // 两个值的交换在加载inputSchema的回调函数中处理: setLoadingSchemaCallback
//        let lastUseRimeInputSchema = self.appSettings.lastUseRimeInputSchema
//        self.appSettings.lastUseRimeInputSchema = self.appSettings.rimeInputSchema
//        self.appSettings.rimeInputSchema = lastUseRimeInputSchema
        self.rimeContext.reset()
        Logger.shared.log.debug("switch last input schema: rimeInputSchema = \(self.appSettings.rimeInputSchema), lastUseRimeInputSchema = \(self.appSettings.lastUseRimeInputSchema), handled = \(handled)")
      }
    case .onehandOnLeft:
      self.changeStateOfOnehandOnLeft()
    case .onehandOnRight:
      self.changeStateOfOneHandOnRight()
    case .rimeSwitcher:
      // 从RIME中读取Switcher切换键
      if !self.rimeContext.hotKeys.isEmpty {
        let hotkey = self.rimeContext.hotKeys[0] // 取第一个
        let hotKeyCode = RimeContext.hotKeyCodeMapping[hotkey, default: XK_F4]
        let hotKeyModifier = RimeContext.hotKeyCodeModifiersMapping[hotkey, default: Int32(0)]
        Logger.shared.log.debug("rimeSwitcher hotkey = \(hotkey), hotkeyCode = \(hotKeyCode), modifier = \(hotKeyModifier)")
        _ = self.inputRimeKeyCode(keyCode: hotKeyCode, modifier: hotKeyModifier)
      }
    case .emojiKeyboard:
      (calloutContext.action as? HamsterActionCalloutContext)?.calloutAction = {
        Logger.shared.log.debug("change keyboard: emojiKeyboard")
        $0.keyboardType = .emojis
      }
    case .symbolKeyboard:
      (calloutContext.action as? HamsterActionCalloutContext)?.calloutAction = {
        Logger.shared.log.debug("change keyboard: symbolKeyboard")
        $0.keyboardType = keyboardCustomType.symbol.keyboardType
      }
    default:
      return false
    }

    return true
  }

  // 上屏补丁
  func inputTextPatch(_ text: String, _ rimeHandled: Bool = true) {
    let pairKeys = self.getPairSymbols(text)
    if rimeHandled, self.appSettings.enableInputEmbeddedMode, !self.rimeContext.asciiMode {
      let selectText = self.textDocumentProxy.selectedText ?? ""

      // 这使用utf16计数，以避免表情符号和类似的问题。
      self.textDocumentProxy.setMarkedText(pairKeys, selectedRange: NSRange(location: pairKeys.utf16.count, length: 0))
      self.textDocumentProxy.unmarkText()
      DispatchQueue.main.async {
        if self.cursorBackOfSymbols(key: pairKeys), !selectText.isEmpty, self.rimeContext.userInputKey.isEmpty {
          self.textDocumentProxy.insertText(selectText)
          self.textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
        }
      }
    } else {
      let selectText = self.textDocumentProxy.selectedText ?? ""
      self.textDocumentProxy.insertText(pairKeys)
      if self.cursorBackOfSymbols(key: pairKeys), !selectText.isEmpty {
        self.textDocumentProxy.insertText(selectText)
        self.textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
      }
    }
  }
}

extension UIKeyboardType {
  var isNumberType: Bool {
    switch self {
    // 数字键盘
    case .numberPad, .numbersAndPunctuation, .phonePad, .decimalPad, .asciiCapableNumberPad: return true
    default: return false
    }
  }
}

#endif
