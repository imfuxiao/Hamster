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

  override public func viewDidLoad() {
    self.log.info("viewDidLoad() begin")
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
  }

  override public func viewWillSetupKeyboard() {
//    super.viewWillSetupKeyboard()
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

    self.setup {
      let ivc = $0 as! HamsterKeyboardViewController

      // let screenWidth = UIScreen.main.bounds.size.width
      // Logger.shared.log.debug("screenWidth: \(screenWidth)")
      // let screenWidthInPixels = screenWidth * UIScreen.main.scale
      // Logger.shared.log.debug("screenWidthInPixels: \(screenWidthInPixels)")
      // Logger.shared.log.debug("ivc.view.frame.width: \(ivc.view.frame.width)")

      // fix: 横向状态下 ivc.view.frame.width 与 UIScreen.main.bounds.size.width 相等，导致键盘显示溢出
      // 150 为键盘两边切换按钮和听写区域宽度
      // 812 - 662 = 150
      var width = ivc.view.frame.width
      if !ivc.keyboardContext.isPortrait && width == UIScreen.main.bounds.size.width && ivc.keyboardContext.isFullScreen {
        width -= 150
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

  private let log = Logger.shared.log
  public var rimeContext = RimeContext()
  public var appSettings = HamsterAppSettings()
  var cancellables = Set<AnyCancellable>()

  lazy var hamsterInputSetProvider: HamsterInputSetProvider = .init(
    keyboardContext: keyboardContext,
    appSettings: appSettings,
    rimeContext: rimeContext
  )

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
    self.rimeContext.maxCandidateCount = Int(self.appSettings.rimeMaxCandidateSize)

    // TODO: 添加监听可能导致用户键盘输入异常
//    // 需要重新覆盖更新方案,重启RIME
//    self.appSettings.$rimeNeedOverrideUserDataDirectory
//      .receive(on: RunLoop.main)
//      .sink(receiveValue: { [weak self] needOverrideUserDataDirectory in
//        if !needOverrideUserDataDirectory {
//          return
//        }
//        guard let self = self else { return }
//
//        do {
//          Logger.shared.log.info("rime syncAppGroupUserDataDirectory: \(self.appSettings.rimeNeedOverrideUserDataDirectory)")
//          try RimeEngine.syncAppGroupUserDataDirectory(override: self.appSettings.rimeNeedOverrideUserDataDirectory)
//        } catch {
//          self.log.error("create rime directory error: \(error), \(error.localizedDescription)")
//        }
//
//        self.rimeEngine.shutdownRime()
//        self.rimeEngine.initialize()
//      })
//      .store(in: &self.cancellables)
  }

  private func setupRime() {
    // 判断是否对AppGroups目录有写入权限，如果没有则将方案复制到 Sandbox 目录下
    var useSandboxUserDataDirectory = false
    do {
      if !FileManager.default.isWritableFile(atPath: RimeContext.appGroupInstallationYaml.path) {
        useSandboxUserDataDirectory = true
      }
      Logger.shared.log.info("rime syncAppGroupUserDataDirectory: \(self.appSettings.rimeNeedOverrideUserDataDirectory), useSandboxUserDataDirectory: \(useSandboxUserDataDirectory)")
      if useSandboxUserDataDirectory {
        try RimeContext.syncAppGroupUserDataDirectoryToSandbox(override: self.appSettings.rimeNeedOverrideUserDataDirectory)
        if self.appSettings.rimeNeedOverrideUserDataDirectory {
          DispatchQueue.main.async {
            self.appSettings.rimeNeedOverrideUserDataDirectory = false
          }
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
    self.changeRimeInputSchema()
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
      textDocumentProxy.insertText(text)
      return
    }

    // 调用输入法引擎
    self.inputCharacter(key: text)
  }

  override open func deleteBackward() {
    _ = self.inputRimeKeyCode(keyCode: XK_BackSpace)
  }

  override open func setKeyboardType(_ type: KeyboardType) {
    // TODO: 添加shift通配符功能
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

  // 简繁切换
  func switchTraditionalSimplifiedChinese() {
    self.rimeContext.simplifiedChineseMode.toggle()
    _ = Rime.shared.simplifiedChineseMode(self.rimeContext.simplifiedChineseMode)
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
        self.inputTextPatch(key)
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
      self.textDocumentProxy.insertText("\r\n")
    case .deleteInputKey:
      self.rimeContext.reset()
    case .selectColorSchema:
      // TODO: 颜色方案切换
      break
    case .switchLastInputSchema:
      if !self.appSettings.lastUseRimeInputSchema.isEmpty {
        let handled = Rime.shared.setSchema(self.appSettings.lastUseRimeInputSchema)
        Logger.shared.log.debug("switch last use input schema \(self.appSettings.lastUseRimeInputSchema), handled = \(handled)")
        // 交换两个值
        let lastUseRimeInputSchema = self.appSettings.lastUseRimeInputSchema
        self.appSettings.lastUseRimeInputSchema = self.appSettings.rimeInputSchema
        self.appSettings.rimeInputSchema = lastUseRimeInputSchema
        self.rimeContext.reset()
      }
    case .onehandOnLeft:
      self.changeStateOfOnehandOnLeft()
    case .onehandOnRight:
      self.changeStateOfOneHandOnRight()
    case .rimeSwitcher:
      // TODO: 这里需要改为动态从RIME中读取Switcher切换键
      _ = self.inputRimeKeyCode(keyCode: XK_F4)
    default:
      return false
    }

    return true
  }

  func inputTextPatch(_ text: String) {
    if self.appSettings.enableInputEmbeddedMode {
      // 这使用utf16计数，以避免表情符号和类似的问题。
      self.textDocumentProxy.setMarkedText(text, selectedRange: NSRange(location: text.utf16.count, length: 0))
      self.textDocumentProxy.unmarkText()
    } else {
      self.textDocumentProxy.insertText(text)
    }
  }
}
#endif
