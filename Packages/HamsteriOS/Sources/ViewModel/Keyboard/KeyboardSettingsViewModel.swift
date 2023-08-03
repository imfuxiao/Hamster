//
//  KeyboardSettingsViewModel.swift
//
//
//  Created by morse on 2023/7/12.
//

import Combine
import HamsterModel
import ProgressHUD
import UIKit

public enum KeyboardSettingsSubView {
  case toolbar
  case numberNineGrid
  case symbols
  case symbolKeyboard
}

public enum NumberNineGridTabView {
  case settings
  case symbols
}

public class KeyboardSettingsViewModel: ObservableObject {
  // MARK: properties

  public var displayButtonBubbles: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayButtonBubbles = displayButtonBubbles
    }
  }

  public var enableEmbeddedInputMode: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableEmbeddedInputMode = enableEmbeddedInputMode
    }
  }

  public var autoLowerCaseOfKeyboard: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.autoLowerCaseOfKeyboard = autoLowerCaseOfKeyboard
    }
  }

  public var displaySpaceLeftButton: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displaySpaceLeftButton = displaySpaceLeftButton
    }
  }

  public var keyValueOfSpaceLeftButton: String {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.keyValueOfSpaceLeftButton = keyValueOfSpaceLeftButton
    }
  }

  public var displaySpaceRightButton: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displaySpaceRightButton = displaySpaceRightButton
    }
  }

  public var keyValueOfSpaceRightButton: String {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.keyValueOfSpaceRightButton = keyValueOfSpaceRightButton
    }
  }

  public var displayChineseEnglishSwitchButton: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayChineseEnglishSwitchButton = displayChineseEnglishSwitchButton
    }
  }

  public var chineseEnglishSwitchButtonIsOnLeftOfSpaceButton: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = chineseEnglishSwitchButtonIsOnLeftOfSpaceButton
    }
  }

  @Published
  public var enableToolbar: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.enableToolbar = enableToolbar
    }
  }

  public var displaySemicolonButton: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displaySemicolonButton = displaySemicolonButton
    }
  }

  @Published
  public var enableNineGridOfNumericKeyboard: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableNineGridOfNumericKeyboard = enableNineGridOfNumericKeyboard
    }
  }

  public var enterDirectlyOnScreenByNineGridOfNumericKeyboard: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enterDirectlyOnScreenByNineGridOfNumericKeyboard = enterDirectlyOnScreenByNineGridOfNumericKeyboard
    }
  }

  @Published
  public var enableSymbolKeyboard: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableSymbolKeyboard = enableSymbolKeyboard
    }
  }

  public var candidateWordFontSize: Int {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.candidateWordFontSize = candidateWordFontSize
    }
  }

  public var heightOfToolbar: Int {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.heightOfToolbar = heightOfToolbar
    }
  }

  public var heightOfCodingArea: Int {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.heightOfCodingArea = heightOfCodingArea
    }
  }

  public var codingAreaFontSize: Int {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.codingAreaFontSize = codingAreaFontSize
    }
  }

  public var candidateCommentFontSize: Int {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.candidateCommentFontSize = candidateCommentFontSize
    }
  }

  public var displayKeyboardDismissButton: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.displayKeyboardDismissButton = displayKeyboardDismissButton
    }
  }

  public var displayIndexOfCandidateWord: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.displayIndexOfCandidateWord = displayIndexOfCandidateWord
    }
  }

  public var maximumNumberOfCandidateWords: Int {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.rime?.maximumNumberOfCandidateWords = maximumNumberOfCandidateWords
    }
  }

  @Published
  public var symbolsOfGridOfNumericKeyboard: [String] {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfGridOfNumericKeyboard = symbolsOfGridOfNumericKeyboard
    }
  }

  @Published
  public var pairsOfSymbols: [String] {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.pairsOfSymbols = pairsOfSymbols
    }
  }

  @Published
  public var symbolsOfCursorBack: [String] {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfCursorBack = symbolsOfCursorBack
    }
  }

  @Published
  public var symbolsOfReturnToMainKeyboard: [String] {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfReturnToMainKeyboard = symbolsOfReturnToMainKeyboard
    }
  }

  private var resetSignSubject = PassthroughSubject<Bool, Never>()
  public var resetSignPublished: AnyPublisher<Bool, Never> {
    resetSignSubject.eraseToAnyPublisher()
  }

  /// 键盘设置选项
  lazy var keyboardSettingsItems: [SettingSectionModel] = [
    .init(
      footer: Self.enableKeyboardAutomaticallyLowercaseRemark,
      items: [
        .init(
          text: "显示按键气泡",
          type: .toggle,
          toggleValue: displayButtonBubbles,
          toggleHandled: { [unowned self] in
            displayButtonBubbles = $0
          }),
        .init(
          text: "启用内嵌模式",
          type: .toggle,
          toggleValue: enableEmbeddedInputMode,
          toggleHandled: { [unowned self] in
            enableEmbeddedInputMode = $0
          }),
        .init(
          text: "Shift自动转小写",
          type: .toggle,
          toggleValue: autoLowerCaseOfKeyboard,
          toggleHandled: { [unowned self] in
            autoLowerCaseOfKeyboard = $0
          })
      ]),
    .init(
      items: [
        .init(
          text: "启用空格左侧按键",
          type: .toggle,
          toggleValue: displaySpaceLeftButton,
          toggleHandled: { [unowned self] in
            displaySpaceLeftButton = $0
          }),
        .init(
          icon: UIImage(systemName: "square.and.pencil"),
          placeholder: "左侧按键键值",
          type: .textField,
          textValue: keyValueOfSpaceLeftButton,
          textHandled: { [unowned self] in
            keyValueOfSpaceLeftButton = $0
          }),
        .init(
          text: "启用空格右侧按键",
          type: .toggle,
          toggleValue: displaySpaceRightButton,
          toggleHandled: { [unowned self] in
            displaySpaceRightButton = $0
          }),
        .init(
          icon: UIImage(systemName: "square.and.pencil"),
          placeholder: "右侧按键键值",
          type: .textField,
          textValue: keyValueOfSpaceRightButton,
          textHandled: { [unowned self] in
            keyValueOfSpaceRightButton = $0
          })
      ]),

    .init(
      footer: "选项“按键位于空格左侧”：关闭状态则位于空格右侧，开启则位于空格左侧",
      items: [
        .init(
          text: "启用中英切换按键",
          type: .toggle,
          toggleValue: displayChineseEnglishSwitchButton,
          toggleHandled: { [unowned self] in
            displayChineseEnglishSwitchButton = $0
          }),
        .init(
          text: "按键位于空格左侧",
          type: .toggle,
          toggleValue: chineseEnglishSwitchButtonIsOnLeftOfSpaceButton,
          toggleHandled: { [unowned self] in
            chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = $0
          })
      ]),
    .init(
      items: [
        .init(
          text: "候选工具栏设置",
          accessoryType: .disclosureIndicator,
          type: .navigation,
          navigationLinkLabel: { [unowned self] in enableToolbar ? "启用" : "禁用" },
          navigationAction: { [unowned self] in
            self.subViewSubject.send(.toolbar)
          })
      ]),
    .init(
      items: [
        .init(
          text: "启用分号按键",
          type: .toggle,
          toggleValue: displaySemicolonButton,
          toggleHandled: { [unowned self] in
            displaySemicolonButton = $0
          }),
        .init(
          text: "数字九宫格",
          accessoryType: .disclosureIndicator,
          type: .navigation,
          navigationLinkLabel: { [unowned self] in enableNineGridOfNumericKeyboard ? "启用" : "禁用" },
          navigationAction: { [unowned self] in
            self.subViewSubject.send(.numberNineGrid)
          }),
        .init(
          text: "符号设置",
          accessoryType: .disclosureIndicator,
          type: .navigation,
          navigationAction: { [unowned self] in
            self.subViewSubject.send(.symbols)
          }),
        .init(
          text: "符号键盘",
          accessoryType: .disclosureIndicator,
          type: .navigation,
          navigationLinkLabel: { [unowned self] in enableSymbolKeyboard ? "启用" : "禁用" },
          navigationAction: { [unowned self] in
            self.subViewSubject.send(.symbolKeyboard)
          })
      ])
  ]

  /// 符号设置选项
  // TODO: 补充 button 逻辑
  lazy var buttonSettingItems: [SettingItemModel] = [
    .init(
      text: "成对上屏符号 - 恢复默认值",
      textTintColor: .systemRed,
      buttonAction: { [unowned self] in
        guard let defaultConfiguration = HamsterAppDependencyContainer.shared.defaultConfiguration else {
          throw "获取系统默认配置失败"
        }
        if let defaultPairsOfSymbols = defaultConfiguration.Keyboard?.pairsOfSymbols {
          self.pairsOfSymbols = defaultPairsOfSymbols
          resetSignSubject.send(true)
          ProgressHUD.showSuccess()
        }
      }),
    .init(
      text: "光标居中符号 - 恢复默认值",
      textTintColor: .systemRed,
      buttonAction: { [unowned self] in
        guard let defaultConfiguration = HamsterAppDependencyContainer.shared.defaultConfiguration else {
          throw "获取系统默认配置失败"
        }
        if let defaultSymbolsOfCursorBack = defaultConfiguration.Keyboard?.symbolsOfCursorBack {
          self.symbolsOfCursorBack = defaultSymbolsOfCursorBack
          resetSignSubject.send(true)
          ProgressHUD.showSuccess()
        }
      }),
    .init(
      text: "返回主键盘符号 - 恢复默认值",
      textTintColor: .systemRed,
      buttonAction: { [unowned self] in
        guard let defaultConfiguration = HamsterAppDependencyContainer.shared.defaultConfiguration else {
          throw "获取系统默认配置失败"
        }
        if let defaultSymbolsOfReturnToMainKeyboard = defaultConfiguration.Keyboard?.symbolsOfReturnToMainKeyboard {
          self.symbolsOfReturnToMainKeyboard = defaultSymbolsOfReturnToMainKeyboard
          resetSignSubject.send(true)
          ProgressHUD.showSuccess()
        }
      })
  ]

  /// 工具栏设置选项
  lazy var toolbarSteppers: [StepperModel] = [
    .init(
      text: "候选字最大数量",
      value: Double(maximumNumberOfCandidateWords),
      minValue: 50,
      maxValue: 500,
      stepValue: 50,
      valueChangeHandled: { [unowned self] in
        maximumNumberOfCandidateWords = Int($0)
      }),
    .init(
      text: "候选字体大小",
      value: Double(candidateWordFontSize),
      minValue: 10,
      maxValue: 30,
      stepValue: 1,
      valueChangeHandled: { [unowned self] in
        candidateWordFontSize = Int($0)
      }),
    .init(
      text: "候选备注字体大小",
      value: Double(candidateCommentFontSize),
      minValue: 5,
      maxValue: 30,
      stepValue: 1,
      valueChangeHandled: { [unowned self] in
        candidateCommentFontSize = Int($0)
      }),
    .init(
      text: "工具栏高度",
      value: Double(heightOfToolbar),
      minValue: 30,
      maxValue: 80,
      stepValue: 1,
      valueChangeHandled: { [unowned self] in
        heightOfToolbar = Int($0)
      }),
    .init(
      text: "编码区高度",
      value: Double(heightOfCodingArea),
      minValue: 5,
      maxValue: 20,
      stepValue: 1,
      valueChangeHandled: { [unowned self] in
        heightOfCodingArea = Int($0)
      }),
    .init(
      text: "编码区字体大小",
      value: Double(codingAreaFontSize),
      minValue: 5,
      maxValue: 20,
      stepValue: 1,
      valueChangeHandled: { [unowned self] in
        codingAreaFontSize = Int($0)
      })
  ]

  lazy var toolbarToggles: [SettingItemModel] = [
    .init(
      text: "启用候选工具栏",
      toggleValue: enableToolbar,
      toggleHandled: { [unowned self] in
        enableToolbar = $0
      }),
    .init(
      text: "显示键盘收起图标",
      toggleValue: displayKeyboardDismissButton,
      toggleHandled: { [unowned self] in
        displayKeyboardDismissButton = $0
      }),
    .init(
      text: "显示候选项索引",
      toggleValue: displayIndexOfCandidateWord,
      toggleHandled: { [unowned self] in
        displayIndexOfCandidateWord = $0
      })
  ]

  lazy var numberNineGridSettings: [SettingItemModel] = [
    .init(
      text: "启用数字九宫格",
      type: .toggle,
      toggleValue: enableNineGridOfNumericKeyboard,
      toggleHandled: { [unowned self] in
        enableNineGridOfNumericKeyboard = $0
      }),
    .init(
      text: "是否直接上屏",
      type: .toggle,
      toggleValue: enterDirectlyOnScreenByNineGridOfNumericKeyboard,
      toggleHandled: { [unowned self] in
        enterDirectlyOnScreenByNineGridOfNumericKeyboard = $0
      }),
    .init(
      text: "符号列表 - 恢复默认值",
      textTintColor: .systemRed,
      type: .button,
      buttonAction: { [unowned self] in
        guard let defaultConfiguration = HamsterAppDependencyContainer.shared.defaultConfiguration else {
          throw "获取系统默认配置失败"
        }
        if let defaultSymbolsOfGridOfNumericKeyboard = defaultConfiguration.Keyboard?.symbolsOfGridOfNumericKeyboard {
          self.symbolsOfGridOfNumericKeyboard = defaultSymbolsOfGridOfNumericKeyboard
          resetSignSubject.send(true)
          ProgressHUD.showSuccess()
        }
      })
  ]

  lazy var symbolKeyboardSettings: [SettingItemModel] = [
    .init(
      text: "启用符号键盘",
      type: .toggle,
      toggleValue: enableSymbolKeyboard,
      toggleHandled: { [unowned self] in
        enableSymbolKeyboard = $0
      }),
    .init(
      text: "常用符号 - 恢复默认值",
      textTintColor: .systemRed,
      type: .button,
      buttonAction: { [unowned self] in
        guard let defaultConfiguration = HamsterAppDependencyContainer.shared.defaultConfiguration else {
          throw "获取系统默认配置失败"
        }
        // TODO: 常用符号重置
      })
  ]

  // navigation 转 subview
  private let subViewSubject = PassthroughSubject<KeyboardSettingsSubView, Never>()
  public var subViewPublished: AnyPublisher<KeyboardSettingsSubView, Never> {
    subViewSubject.eraseToAnyPublisher()
  }

  // 数字九宫格页面切换
  private let numberNineGridSubviewSwitchSubject = CurrentValueSubject<NumberNineGridTabView, Never>(.settings)
  public var numberNineGridSubviewSwitchPublished: AnyPublisher<NumberNineGridTabView, Never> {
    numberNineGridSubviewSwitchSubject.eraseToAnyPublisher()
  }

  // 符号设置页面切换
  private let symbolSettingsSubviewSwitchSubject = CurrentValueSubject<Int, Never>(0)
  public var symbolSettingsSubviewPublished: AnyPublisher<Int, Never> {
    symbolSettingsSubviewSwitchSubject.eraseToAnyPublisher()
  }

  @Published
  public var symbolTableIsEditing: Bool = false

  // MARK: methods

  public init(configuration: HamsterConfiguration) {
    self.displayButtonBubbles = configuration.Keyboard?.displayButtonBubbles ?? true
    self.displayKeyboardDismissButton = configuration.toolbar?.displayKeyboardDismissButton ?? true
    self.autoLowerCaseOfKeyboard = configuration.Keyboard?.autoLowerCaseOfKeyboard ?? false
    self.displaySpaceLeftButton = configuration.Keyboard?.displaySpaceLeftButton ?? true
    self.keyValueOfSpaceLeftButton = configuration.Keyboard?.keyValueOfSpaceLeftButton ?? ","
    self.displaySpaceRightButton = configuration.Keyboard?.displaySpaceRightButton ?? false
    self.keyValueOfSpaceRightButton = configuration.Keyboard?.keyValueOfSpaceRightButton ?? "."
    self.displayChineseEnglishSwitchButton = configuration.Keyboard?.displayChineseEnglishSwitchButton ?? true
    self.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = configuration.Keyboard?.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton ?? false
    self.enableToolbar = configuration.toolbar?.enableToolbar ?? true
    self.displaySemicolonButton = configuration.Keyboard?.displaySemicolonButton ?? false
    self.enableNineGridOfNumericKeyboard = configuration.Keyboard?.enableNineGridOfNumericKeyboard ?? false
    self.enterDirectlyOnScreenByNineGridOfNumericKeyboard = configuration.Keyboard?.enterDirectlyOnScreenByNineGridOfNumericKeyboard ?? false
    self.enableSymbolKeyboard = configuration.Keyboard?.enableSymbolKeyboard ?? false
    self.symbolsOfGridOfNumericKeyboard = configuration.Keyboard?.symbolsOfGridOfNumericKeyboard ?? []
    self.pairsOfSymbols = configuration.Keyboard?.pairsOfSymbols ?? []
    self.symbolsOfCursorBack = configuration.Keyboard?.symbolsOfCursorBack ?? []
    self.symbolsOfReturnToMainKeyboard = configuration.Keyboard?.symbolsOfReturnToMainKeyboard ?? []

    self.enableEmbeddedInputMode = configuration.Keyboard?.enableEmbeddedInputMode ?? false
    self.candidateWordFontSize = configuration.toolbar?.candidateWordFontSize ?? 20
    self.heightOfToolbar = configuration.toolbar?.heightOfToolbar ?? 50
    self.heightOfCodingArea = configuration.toolbar?.heightOfCodingArea ?? 10
    self.codingAreaFontSize = configuration.toolbar?.codingAreaFontSize ?? 12
    self.candidateCommentFontSize = configuration.toolbar?.candidateCommentFontSize ?? 12
    self.displayIndexOfCandidateWord = configuration.toolbar?.displayIndexOfCandidateWord ?? false
    self.maximumNumberOfCandidateWords = configuration.rime?.maximumNumberOfCandidateWords ?? 100
  }

  @objc func numberNineGridSegmentedControlChange(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      numberNineGridSubviewSwitchSubject.send(.settings)
      return
    }
    numberNineGridSubviewSwitchSubject.send(.symbols)
  }

  @objc func changeTableEditModel() {
    symbolTableIsEditing.toggle()
  }

  @objc func symbolsSegmentedControlChange(_ sender: UISegmentedControl) {
    symbolSettingsSubviewSwitchSubject.send(sender.selectedSegmentIndex)
  }
}

extension KeyboardSettingsViewModel {
  public static let symbolKeyboardRemark = "启用后，常规符号键盘将被替换为符号键盘。常规符号键盘布局类似系统自带键盘符号布局。"
  static let enableKeyboardAutomaticallyLowercaseRemark = "默认键盘大小写会保持自身状态. 开启此选项后, 当在大写状态在下输入一个字母后会自动转为小写状态. 注意: 双击Shift会保持锁定"
}
