import Combine
import Foundation
import KeyboardKit
import LibrimeKit
import Plist
import UIKit

/// 键盘ViewController
open class HamsterKeyboardViewController: KeyboardInputViewController {
  public var rimeEngine = RimeEngine.shared
  public var appSettings = HamsterAppSettings()

  @PlistWrapper(path: Bundle.main.url(forResource: "DefaultSkinExtend", withExtension: "plist")!)
  public var skinExtend: Plist

  @PlistWrapper(path: Bundle.main.url(forResource: "DefaultAction", withExtension: "plist")!)
  public var actionExtend: Plist

  var cancel = Set<AnyCancellable>()

  override public func viewDidLoad() {
    #if DEBUG
      NSLog("viewDidLoad() begin")
    #endif

    do {
      try RimeEngine.syncAppGroupSharedSupportDirectory()
      try RimeEngine.initUserDataDirectory()
      try RimeEngine.syncAppGroupUserDataDirectory(override: self.appSettings.rimeNeedOverrideUserDataDirectory)
    } catch {
      // TODO: RIME 异常启动处理
      print("create rime directory error: ")
      print(error.localizedDescription)
    }

    self.rimeEngine.setupRime(
      sharedSupportDir: RimeEngine.sharedSupportDirectory.path,
      userDataDir: RimeEngine.userDataDirectory.path
    )
    self.rimeEngine.startRime()

    self.appSettings.$switchTraditionalChinese
      .receive(on: RunLoop.main)
      .sink {
        print("-----------\n combine traditionalMode \($0)")
        _ = self.rimeEngine.simplifiedChineseMode($0)
      }
      .store(in: &self.cancel)

    self.appSettings.$showKeyPressBubble
      .receive(on: RunLoop.main)
      .sink {
        print("-----------\n combine showKeyPressBubble \($0)")
        self.calloutContext.input.isEnabled = $0
      }
      .store(in: &self.cancel)

    self.appSettings.$rimeNeedOverrideUserDataDirectory
      .receive(on: RunLoop.main)
      .sink {
        if $0 {
          do {
            try RimeEngine.syncAppGroupUserDataDirectory(override: true)
          } catch {
            print(error)
          }
          self.rimeEngine.deploy(fullCheck: false)
        }
      }
      .store(in: &self.cancel)

    self.appSettings.$rimeInputSchema
      .receive(on: RunLoop.main)
      .sink {
        if !$0.isEmpty {
          if !self.rimeEngine.setSchema($0) {
            print("rime engine set schema false")
          }
        }
      }
      .store(in: &self.cancel)

    
    // 注意初始化的顺序
    self.keyboardAppearance = HamsterKeyboardAppearance(
      keyboardContext: self.keyboardContext,
      appSettings: self.appSettings,
      rimeEngine: self.rimeEngine
    )

    self.keyboardLayoutProvider = HamsterStandardKeyboardLayoutProvider(
      keyboardContext: self.keyboardContext,
      inputSetProvider: self.inputSetProvider
    )

    self.keyboardBehavior = HamsterKeyboardBehavior(keyboardContext: self.keyboardContext)
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
    
    self.keyboardActionHandler = HamsterKeyboardActionHandler(inputViewController: self)
    self.calloutContext = KeyboardCalloutContext(
      action: HamsterActionCalloutContext(
        actionHandler: keyboardActionHandler,
        actionProvider: calloutActionProvider
      ),
      input: InputCalloutContext(
        isEnabled: UIDevice.current.userInterfaceIdiom == .phone)
    )

    // TODO: 动态设置 local
    self.keyboardContext.locale = Locale(identifier: "zh-Hans")

    super.viewDidLoad()
  }

  override public func viewDidDisappear(_ animated: Bool) {
    #if DEBUG
      NSLog("viewDidDisappear() begin")
    #endif
  }

  override public func viewWillSetupKeyboard() {
    #if DEBUG
      NSLog("viewWillSetupKeyboard() begin")
    #endif

    let alphabetKeyboard = AlphabetKeyboard(keyboardInputViewController: self)
      .environmentObject(self.rimeEngine)
      .environmentObject(self.appSettings)

    setup(with: alphabetKeyboard)
    //        setup(with: HamsterKeyboard(controler: self))

    //        alphabetKeyboard.observer()
  }
}

extension Plist {
  var strDict: [String: String] {
    var extend: [String: String] = [:]
    if let dict = dict {
      for (key, value) in dict {
        if let value = value as? String {
          extend[(key as! String).lowercased()] = value
        }
      }
    }
    return extend
  }
}

public extension HamsterKeyboardViewController {
  //    func insertAutocompleteSuggestion(_ suggestion: AutocompleteSuggestion) {
  //        textDocumentProxy.insertAutocompleteSuggestion(suggestion)
  //        keyboardActionHandler.handle(.release, on: .character(""))
  //    }

  func setHamsterKeyboardType(_ type: KeyboardType) {
    // TODO: 切换九宫格
    //        if case .numeric = type {
    //            keyboardContext.keyboardType = .custom(named: KeyboardConstant.keyboardType.NumberGrid)
    //            return
    //        }
    keyboardContext.keyboardType = type
  }
}
