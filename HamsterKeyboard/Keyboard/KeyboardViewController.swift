#if os(iOS)
import Combine
import Foundation
import KeyboardKit
import LibrimeKit
import UIKit

// 全局变量: 设置Rime是否首次启动标志
var isRimeFirstRun = true
// let globalRimeEngine = RimeEngine()
// let globalAppSettings = HamsterAppSettings()

// Hamster键盘Controller
open class HamsterKeyboardViewController: KeyboardInputViewController {
  private let log = Logger.shared.log
  public var rimeEngine = RimeEngine()
  public var appSettings = HamsterAppSettings()
  var cancellables = Set<AnyCancellable>()

  lazy var hamsterInputSetProvider: HamsterInputSetProvider = .init(
    keyboardContext: keyboardContext,
    appSettings: appSettings,
    rimeEngine: rimeEngine
  )

  override public func viewDidLoad() {
    self.log.info("viewDidLoad() begin")
    // 注意初始化的顺序

    // TODO: 动态设置 local
    self.keyboardContext.locale = Locale(identifier: "zh-Hans")
    //    self.log.info("local language: \(Locale.preferredLanguages[0])")
    //    self.log.info("local language: \(Locale.autoupdatingCurrent.identifier)")
    //    self.log.info("local language: \(Locale.autoupdatingCurrent.languageCode)")
    //    self.log.info("local language: \(Locale.current.identifier)")
    //    self.log.info("local language: \(Locale.current.languageCode)")

    // 外观
    self.keyboardAppearance = HamsterKeyboardAppearance(
      keyboardContext: self.keyboardContext,
      rimeEngine: self.rimeEngine,
      appSettings: self.appSettings
    )
    // 布局
    self.keyboardLayoutProvider = HamsterStandardKeyboardLayoutProvider(
      keyboardContext: self.keyboardContext,
      inputSetProvider: self.hamsterInputSetProvider,
      appSettings: self.appSettings,
      rimeEngine: self.rimeEngine
    )

    // 键盘默认行为: 这里可以做如改变键盘的类型
    self.keyboardBehavior = HamsterKeyboardBehavior(
      keyboardContext: self.keyboardContext,
      appSettings: self.appSettings,
      rimeEngine: self.rimeEngine
    )

    // 气泡功能设置
    self.calloutActionProvider = HamsterCalloutActionProvider(
      keyboardContext: self.keyboardContext,
      rimeEngine: self.rimeEngine
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
        actionHandler: keyboardActionHandler,
        actionProvider: calloutActionProvider
      ),
      input: InputCalloutContext(
        isEnabled: UIDevice.current.userInterfaceIdiom == .phone
      )
    )

    self.setupRimeEngine()
    self.setupAppSettings()

    super.viewDidLoad()
  }

  override public func viewWillSetupKeyboard() {
    super.viewWillSetupKeyboard()
    self.log.debug("viewWillSetupKeyboard() begin")

    // 初始键盘类型
    if let keyboardType = self.textDocumentProxy.keyboardType {
      switch keyboardType {
      // 数字键盘
      case .numberPad, .numbersAndPunctuation, .phonePad, .decimalPad, .asciiCapableNumberPad:
        self.keyboardContext.keyboardType = .numeric
      // 默认键盘
      default:
        break
      }
    }
    
    let hamsterKeyboard = HamsterKeyboard(keyboardInputViewController: self)
      .environmentObject(self.rimeEngine)
      .environmentObject(self.appSettings)
    setup(with: hamsterKeyboard)
  }

  override public func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.log.debug("HamsterKeyboardViewController viewDidDisappear")
  }

  public func dealloc() {
    self.log.debug("HamsterKeyboardViewController dealloc")
  }

  private func setupAppSettings() {
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
        if (keyboard == .numeric || keyboard == .symbolic) && self.appSettings.enableNumberNineGrid {
          self.calloutContext.input.isEnabled = false
          return
        }
        self.calloutContext.input.isEnabled = self.appSettings.showKeyPressBubble
      }
      .store(in: &self.cancellables)

    // 候选字最大数量
    self.appSettings.$rimeMaxCandidateSize
      .receive(on: RunLoop.main)
      .sink { [weak self] rimeMaxCandidateSize in
        guard let self = self else { return }
        self.log.info("combine $rimeMaxCandidateSize: \(rimeMaxCandidateSize)")
        self.rimeEngine.maxCandidateCount = rimeMaxCandidateSize
      }
      .store(in: &self.cancellables)

    // 候选栏如果启用内嵌模式，则监听userInputKey的变化
    if self.appSettings.enableInputEmbeddedMode {
      self.rimeEngine.$userInputKey
        .receive(on: DispatchQueue.main)
        .sink { [weak self] userInputKey in
          guard let self = self else { return }
          self.log.debug("combine $userInputKey: \(userInputKey)")
          self.textDocumentProxy.setMarkedText(
            userInputKey, selectedRange: NSMakeRange(userInputKey.count, 0)
          )
        }
        .store(in: &self.cancellables)
    }
  }

  private func setupRimeEngine() {
    do {
//      TODO: AppGroup下SharedSupport目录共享
//      try RimeEngine.syncAppGroupSharedSupportDirectory(
//        override: self.appSettings.rimeNeedOverrideUserDataDirectory)
      Logger.shared.log.debug("rime syncAppGroupUserDataDirectory: \(self.appSettings.rimeNeedOverrideUserDataDirectory)")

      // 如果有写权限直接使用AppGroup下目录
      try RimeEngine.syncAppGroupUserDataDirectory(
        override: self.appSettings.rimeNeedOverrideUserDataDirectory)
    } catch {
      self.log.error("create rime directory error: \(error), \(error.localizedDescription)")
    }

    // TODO: 使用AppGroup下的SharedSupport目录
    let traits = self.rimeEngine.createTraits(
      sharedSupportDir: RimeEngine.appGroupSharedSupportDirectoryURL.path,
      userDataDir: RimeEngine.userDataDirectory.path
    )

    // setupRime不能重复调用, 否则会触发panic
    // utilities.cc:365] Check failed: !IsGoogleLoggingInitialized() You called InitGoogleLogging() twice!
    // rimeEngine是ViewController的成员变量, 每次启动都会被初始化
    // 所以内部的是否首次启动标志不起作用, 这里在ViewController外部定义了全局变量, 用来标记是否首次启动.
    if isRimeFirstRun {
      isRimeFirstRun = false
      self.rimeEngine.setupRime(traits)
    }
    self.rimeEngine.startRime(
      nil, fullCheck: false
    )
    if self.appSettings.rimeNeedOverrideUserDataDirectory {
      self.appSettings.rimeNeedOverrideUserDataDirectory = false
    }
    self.rimeEngine.createSession()
    Logger.shared.log.debug("rime session: \(self.rimeEngine.session)")
    self.changeRimeInputSchema()
    self.changeRimeColorSchema()
    self.rimeEngine.reset()
    self.rimeEngine.maxCandidateCount = self.appSettings.rimeMaxCandidateSize
  }

  // MARK: - Text And Selection Change

  override open func selectionWillChange(_ textInput: UITextInput?) {
    super.selectionWillChange(textInput)
    Logger.shared.log.debug("keyboardViewController: selectionWillChange")
  }

  override open func selectionDidChange(_ textInput: UITextInput?) {
    super.selectionDidChange(textInput)
    Logger.shared.log.debug("keyboardViewController: selectionDidChange")
  }

  override open func textWillChange(_ textInput: UITextInput?) {
    super.textWillChange(textInput)
    Logger.shared.log.debug("keyboardViewController: textWillChange")
  }

  override open func textDidChange(_ textInput: UITextInput?) {
    super.textDidChange(textInput)
    Logger.shared.log.debug("keyboardViewController: textDidChange")

    // TODO: 这里添加英文自动转大写功能, 参考: KeyboardContext.preferredAutocapitalizedKeyboardType

    // fix: 输出栏点击右侧x形按钮后, 输入法候选栏内容没有跟随输入栏一同清空
    if !self.textDocumentProxy.hasText {
      self.rimeEngine.reset()
    }
  }

  // MARK: - KeyboardController

  override open func insertText(_ text: String) {
    // 是否英文模式
    if self.rimeEngine.isAsciiMode() {
      textDocumentProxy.insertText(text)
      return
    }

    // 调用输入法引擎
    self.inputCharacter(key: text)
  }

  override open func deleteBackward() {
    _ = self.inputRimeKeycode(keycode: XK_BackSpace)
  }

  override open func setKeyboardType(_ type: KeyboardType) {
    // TODO: 添加shift通配符功能
    keyboardContext.keyboardType = type
  }
}

extension HamsterKeyboardViewController {
  // 设置用户输入方案
  func changeRimeInputSchema() {
    let setInputSchemaHandle = self.rimeEngine.setSchema(self.appSettings.rimeInputSchema)
    self.log.info(
      "self.rimeEngine set schema: \(self.appSettings.rimeInputSchema), setInputSchemaHandle = \(setInputSchemaHandle)"
    )
  }

  // 设置Rime颜色方案
  func changeRimeColorSchema() {
    let enableColorSchema = self.appSettings.enableRimeColorSchema
    let rimeColorSchemaName = self.appSettings.rimeColorSchema
    self.log.info(
      "enableRimeColorSchema and rimeInputSchema: \(enableColorSchema), \(rimeColorSchemaName)")
    if enableColorSchema {
      DispatchQueue.main.async {
        self.rimeEngine.currentColorSchema = self.getCurrentColorSchema()
      }
    }
  }

  // 简繁切换
  func switchTraditionalSimplifiedChinese() {
    self.rimeEngine.simplifiedChineseMode.toggle()
    _ = self.rimeEngine.simplifiedChineseMode(self.rimeEngine.simplifiedChineseMode)
  }

  // 中英切换
  func switchEnglishChinese(_ imageName: String = "") {
    //    中文模式下, 在已经有候选字的情况下, 切换英文模式.
    //
    //    情况1. 清空中文输入, 开始英文输入
    //    self.rimeEngine.reset()

    //    情况2. 候选栏字母上屏, 并开启英文输入
    var userInputKey = self.rimeEngine.userInputKey
    if !userInputKey.isEmpty {
      userInputKey.removeAll(where: { $0 == " " })
      self.inputTextPatch(userInputKey)
    }
    self.rimeEngine.reset()
    //    情况3. 首选候选字上屏, 并开启英文输入
    //    _ = self.candidateTextOnScreen()
    self.rimeEngine.asciiMode.toggle()
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

  // 候选字上一页
  func previousPageOfCandidates() {
    if self.rimeEngine.inputKeyCode(XK_Page_Up) {
      self.rimeEngine.syncContext()
    } else {
      Logger.shared.log.warning("rime input pageup result error")
    }
  }

  // 候选字下一页
  func nextPageOfCandidates() {
    if self.rimeEngine.inputKeyCode(XK_Page_Down) {
      self.rimeEngine.syncContext()
    } else {
      Logger.shared.log.debug("rime input pageDown result error")
    }
  }

  // 当前颜色
  func getCurrentColorSchema() -> ColorSchema {
    Logger.shared.log.info("call getCurrentColorSchema()")
    let schema = ColorSchema()

    if !self.appSettings.enableRimeColorSchema {
      return schema
    }
    let name = self.appSettings.rimeColorSchema
    if name.isEmpty {
      return schema
    }
    guard let colorSchema = self.rimeEngine.colorSchema(appSettings.rimeUseSquirrelSettings).first(where: { $0.schemaName == name })
    else {
      return schema
    }
    Logger.shared.log.info("call getCurrentColorSchema, schemaName = \(colorSchema.schemaName)")
    return colorSchema
  }

  /// 根据索引选择候选字
  func selectCandidateIndex(index: Int) -> Bool {
    let handled = self.rimeEngine.selectCandidate(index: index)
    self.updateRimeEngine(handled)
    return handled
  }

  /// 字符输入
  func inputCharacter(key: String) {
    // 功能指令处理
    if self.functionalInstructionsHandled(key) {
      return
    }

    // 由rime处理全部符号
    var handled = false
    let keyUTF8 = key.utf8
    if keyUTF8.count == 1, let first = keyUTF8.first {
      handled = self.inputRimeKeycode(keycode: Int32(first))
    }

    // 符号键直接上屏
    if !handled {
      // 符号顶码上屏
      _ = self.candidateTextOnScreen()
      self.inputTextPatch(key)
    }
  }

  /// 转为RimeCode
  func inputRimeKeycode(keycode: Int32, modifier: Int32 = 0) -> Bool {
    var handled = self.rimeEngine.inputKeyCode(keycode, modifier: modifier)
    if !handled {
      // 特殊功能键处理
      switch keycode {
      case XK_Return:
        self.textDocumentProxy.insertText(.newline)
        handled = true
      case XK_BackSpace: // 退格
        self.textDocumentProxy.deleteBackward()
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
    let commitText = self.rimeEngine.getCommitText()
    if !commitText.isEmpty {
      self.inputTextPatch(commitText)
    }

    // 查看输入法状态
    let status = self.rimeEngine.status()

    // 如不存在候选字,则重置输入法
    if !status.isComposing {
      self.rimeEngine.reset()
      return
    }

    if handled {
      self.rimeEngine.syncContext()
    }
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
      self.textDocumentProxy.insertText("\r\n")
    case .deleteInputKey:
      self.rimeEngine.reset()
    case .selectColorSchema:
      // TODO: 颜色方案切换
      break
    case .switchLastInputSchema:
      let currentInputSchema = (self.rimeEngine.currentSchema()?.schemaId) ?? ""
      if !self.appSettings.lastUseRimeInputSchema.isEmpty {
        let handled = self.rimeEngine.setSchema(self.appSettings.lastUseRimeInputSchema)
        Logger.shared.log.debug("switch last use input schema \(self.appSettings.lastUseRimeInputSchema), handled = \(handled)")
        // 注意：这里lastUseRimeInputSchema的值会在rimeInputSchema的值的willSet时期变动。
        // 所以不需要在交换两个值
        self.appSettings.rimeInputSchema = self.appSettings.lastUseRimeInputSchema
        self.rimeEngine.reset()
      }
    default:
      return false
    }

    return true
  }

  func inputTextPatch(_ text: String) {
    if self.appSettings.enableInputEmbeddedMode {
      guard let _ = self.textDocumentProxy.selectedText else {
        self.textDocumentProxy.insertText(text)
        return
      }
      // fix: 部分App候选文字内嵌模式下上屏异常
      self.textDocumentProxy.setMarkedText(
        text, selectedRange: NSRange(location: text.count, length: 0)
      )
      self.textDocumentProxy.unmarkText()
    } else {
      self.textDocumentProxy.insertText(text)
    }
  }
}
#endif
