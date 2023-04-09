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
  lazy var hamsterInputSetProvider: HamsterInputSetProvider = .init(keyboardContext: keyboardContext)
  
  private func setupAppSettings() {
    // 简中切换
//    self.appSettings.$switchTraditionalChinese
//      .receive(on: RunLoop.main)
//      .sink { [weak self] in
//        guard let self = self else { return }
//        self.log.info("combine $switchTraditionalChinese \($0)")
//        _ = self.rimeEngine.simplifiedChineseMode($0)
//      }
//      .store(in: &self.cancellables)
    
    // 按键气泡
    self.appSettings.$showKeyPressBubble
      .receive(on: RunLoop.main)
      .sink { [weak self] in
        guard let self = self else { return }
        self.log.info("combine $showKeyPressBubble \($0)")
        self.calloutContext.input.isEnabled = $0
      }
      .store(in: &self.cancellables)
    
//     是否重置用户数据目录
//    self.appSettings.$rimeNeedOverrideUserDataDirectory
//      .receive(on: RunLoop.main)
//      .sink { [weak self] in
//        self?.log.info("combine $rimeNeedOverrideUserDataDirectory \($0)")
//        if $0 {
//          do {
//            try RimeEngine.syncAppGroupSharedSupportDirectory(override: true)
//            try RimeEngine.syncAppGroupUserDataDirectory(override: true)
//          } catch {
//            self?.log.error("rime syncAppGroupUserDataDirectory error \(error), \(error.localizedDescription)")
//          }
//          self?.rimeEngine.deploy(fullCheck: true)
//          self?.rimeEngine.restSession()
//        }
//      }
//      .store(in: &self.cancellables)
    
    // 输入方案变更
    self.appSettings.$rimeInputSchema
      .receive(on: RunLoop.main)
      .sink { [weak self] schema in
        guard let self = self else { return }
        self.log.info("combine $rimeInputSchema: \(schema)")
        self.changeInputSchema(schema)
      }
      .store(in: &self.cancellables)
    
    // 配色方案变更
    self.appSettings.$enableRimeColorSchema
      .combineLatest(self.appSettings.$rimeColorSchema)
      .receive(on: RunLoop.main)
      .sink { [weak self] enable, schemaName in
        guard let self = self else { return }
        self.log.info("combine $enableRimeColorSchema and $rimeInputSchema: \(enable), \(schemaName)")
        if enable {
          self.rimeEngine.currentColorSchema = self.getCurrentColorSchema()
        }
      }
      .store(in: &self.cancellables)
  }
  
  private func setupRimeEngine() {
    do {
      try RimeEngine.syncAppGroupSharedSupportDirectory(override: self.appSettings.rimeNeedOverrideUserDataDirectory)
      try RimeEngine.initUserDataDirectory()
      try RimeEngine.syncAppGroupUserDataDirectory(override: self.appSettings.rimeNeedOverrideUserDataDirectory)
      if self.appSettings.rimeNeedOverrideUserDataDirectory {
        self.appSettings.rimeNeedOverrideUserDataDirectory = false
      }
    } catch {
      self.log.error("create rime directory error: \(error), \(error.localizedDescription)")
    }
    
    let traits = self.rimeEngine.createTraits(
      sharedSupportDir: RimeEngine.sharedSupportDirectory.path,
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
    self.rimeEngine.startRime(traits, fullCheck: false)
    self.rimeEngine.rest()
  }
  
  override public func viewDidLoad() {
    self.log.info("viewDidLoad() begin")
    // 注意初始化的顺序
    
    // TODO: 动态设置 local
    self.keyboardContext.locale = Locale(identifier: "zh-Hans")
    
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
      appSettings: self.appSettings
    )
    self.keyboardBehavior = HamsterKeyboardBehavior(keyboardContext: self.keyboardContext)
    // TODO: 长按按钮设置
    self.calloutActionProvider = DisabledCalloutActionProvider() // 禁用长按按钮
    self.keyboardFeedbackSettings = KeyboardFeedbackSettings(
      audioConfiguration: AudioFeedbackConfiguration(),
      hapticConfiguration: HapticFeedbackConfiguration(
        tap: .mediumImpact,
        doubleTap: .mediumImpact,
        longPress: .mediumImpact,
        longPressOnSpace: .mediumImpact
      )
    )
    self.keyboardFeedbackHandler = HamsterKeyboardFeedbackHandler(
      settings: self.keyboardFeedbackSettings,
      appSettings: self.appSettings
    )
    self.keyboardActionHandler = HamsterKeyboardActionHandler(
      inputViewController: self,
      keyboardContext: self.keyboardContext,
      keyboardFeedbackHandler: self.keyboardFeedbackHandler
    )
    self.calloutContext = KeyboardCalloutContext(
      action: HamsterActionCalloutContext(
        actionHandler: keyboardActionHandler,
        actionProvider: calloutActionProvider
      ),
      input: InputCalloutContext(
        isEnabled: UIDevice.current.userInterfaceIdiom == .phone)
    )
    
    self.setupRimeEngine()
    self.setupAppSettings()
    
    // 修改当前inputShcema
    // self.changeInputSchema(self.appSettings.rimeInputSchema)
    
    super.viewDidLoad()
  }
  
  override public func viewWillSetupKeyboard() {
    self.log.debug("viewWillSetupKeyboard() begin")
    let alphabetKeyboard = AlphabetKeyboard(keyboardInputViewController: self)
      .environmentObject(self.rimeEngine)
      .environmentObject(self.appSettings)
    setup(with: alphabetKeyboard)
  }
  
  override public func viewDidDisappear(_ animated: Bool) {
    self.log.debug("HamsterKeyboardViewController viewDidDisappear")
  }
  
  public func dealloc() {
    self.log.debug("HamsterKeyboardViewController dealloc")
    self.rimeEngine.shutdownRime()
  }
  
  // MARK: - KeyboardController

  override open func insertText(_ text: String) {
    // TODO: 特殊符号处理
    switch text {
    /// A carriage return character.
    case .carriageReturn, .tab:
      textDocumentProxy.insertText(text)
      return // 注意: 这里直接return
    // 空格候选字上屏
    case .space:
      if !candidateTextOnScreen() {
        textDocumentProxy.insertText(text)
      }
      return // 注意: 这里直接return
    // 回车用户输入key上屏
    case .newline:
      if !userInputOnScreen() {
        textDocumentProxy.insertText(text)
      }
      return // 注意: 这里直接return
    default:
      break
    }
    
    // TODO: 自定义键处理
    
    if self.rimeEngine.isAsciiMode() {
      textDocumentProxy.insertText(text)
      return
    }
    
    var callResult = false
    /// 判断如果用户点击了候选栏, 则传递的为候选字的索引
    if let index = Int(text) {
      callResult = self.rimeEngine.selectCandidate(index: index)
      if !callResult {
        Logger.shared.log.warning("call rime select candidate is false. index = \(index)")
      }
    } else {
      callResult = self.rimeEngine.inputKey(text)
    }

    // 调用输入法引擎
    if callResult {
      // 唯一码直接上屏
      let commitText = self.rimeEngine.getCommitText()
      if !commitText.isEmpty {
        self.rimeEngine.rest()
        self.textDocumentProxy.insertText(commitText)
        return
      }

      // 查看输入法状态
      let status = self.rimeEngine.status()
      // 如不存在候选字,则重置输入法
      if !status.isComposing {
        self.rimeEngine.rest()
      } else {
        self.rimeEngine.contextReact()
      }
      return
    } else {
      Logger.shared.log.error("rime engine input character \(text) error.")
      self.rimeEngine.rest()
    }
    
    textDocumentProxy.insertText(text)
  }
  
  override open func deleteBackward() {
    if !self.rimeEngine.userInputKey.isEmpty {
      if self.rimeEngine.inputKeyCode(KeyboardConstant.KeySymbol.Backspace.rawValue) {
        self.rimeEngine.contextReact()
      } else {
        Logger.shared.log.error("rime engine input backspace key error")
        self.rimeEngine.rest()
      }
      return
    }
    textDocumentProxy.deleteBackward(range: keyboardBehavior.backspaceRange)
  }

  override open func setKeyboardType(_ type: KeyboardType) {
    // TODO: 添加shift通配符功能
    keyboardContext.keyboardType = type
  }
}

extension HamsterKeyboardViewController {
  // 简繁切换
  func switchTraditionalSimplifiedChinese() {
    self.rimeEngine.simplifiedChineseMode.toggle()
    _ = self.rimeEngine.simplifiedChineseMode(self.rimeEngine.simplifiedChineseMode)
  }
  
  // 中英切换
  func switchEnglishChinese() {
    self.rimeEngine.asciiMode.toggle()
  }
  
  /// 次选上屏
  func secondCandidateTextOnScreen() -> Bool {
    let status = self.rimeEngine.status()
    if status.isComposing {
      let candidates = self.rimeEngine.suggestions
      if candidates.isEmpty {
        return false
      }
      if candidates.count >= 2 {
        self.textDocumentProxy.insertText(candidates[1].text)
        self.rimeEngine.rest()
        return true
      }
    }
    return false
  }
  
  /// 首选候选字上屏
  func candidateTextOnScreen() -> Bool {
    let status = self.rimeEngine.status()
    if status.isComposing {
      let candidates = self.rimeEngine.suggestions
      if candidates.isEmpty {
        return false
      }
      self.textDocumentProxy.insertText(candidates[0].text)
      self.rimeEngine.rest()
      return true
    }
    return false
  }
  
  /// 用户输入键直接上屏
  func userInputOnScreen() -> Bool {
    if !self.rimeEngine.userInputKey.isEmpty {
      let text = self.rimeEngine.userInputKey
      textDocumentProxy.insertText(text)
      self.rimeEngine.rest()
      return true
    }
    return false
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
    if self.rimeEngine.inputKeyCode(KeyboardConstant.KeySymbol.PageUp.rawValue) {
      self.rimeEngine.contextReact()
    } else {
      Logger.shared.log.warning("rime input pageup result error")
    }
  }
  
  // 候选字下一页
  func nextPageOfCandidates() {
    if self.rimeEngine.inputKeyCode(KeyboardConstant.KeySymbol.PageDown.rawValue) {
      self.rimeEngine.contextReact()
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
    guard let colorSchema = self.rimeEngine.colorSchema().first(where: { $0.schemaName == name }) else {
      return schema
    }
    Logger.shared.log.info("call getCurrentColorSchema, schameName = \(colorSchema.schemaName)")
    return colorSchema
  }
  
  // 修改输入方案
  func changeInputSchema(_ schema: String) {
    Logger.shared.log.info("rime set schema: \(schema)")
    if !schema.isEmpty {
      // 输入方案切换
      if self.rimeEngine.setSchema(schema) {
        Logger.shared.log.info("rime engine set schema \(schema) success")
      } else {
        Logger.shared.log.error("rime engine set schema \(schema) error")
      }
    }
  }
}
#endif
