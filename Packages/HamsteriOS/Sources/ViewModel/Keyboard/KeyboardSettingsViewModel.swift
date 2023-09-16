//
//  KeyboardSettingsViewModel.swift
//
//
//  Created by morse on 2023/7/12.
//

import Combine
import HamsterKeyboardKit
import ProgressHUD
import UIKit

public enum KeyboardSettingsSubView {
  case toolbar
  case numberNineGrid
  case symbols
  case symbolKeyboard
  case keyboardLayout
}

public enum NumberNineGridTabView {
  case settings
  case symbols
}

public enum KeyboardLayoutSegmentAction {
  case chineseLayoutSettings
  case chineseLayoutSwipeSettings
}

public class KeyboardSettingsViewModel: ObservableObject {
  // MARK: - properties

  public var displayButtonBubbles: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayButtonBubbles = displayButtonBubbles
    }
  }

  public var upSwipeOnLeft: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.upSwipeOnLeft = upSwipeOnLeft
    }
  }

  public var enableEmbeddedInputMode: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableEmbeddedInputMode = enableEmbeddedInputMode
    }
  }

  public var lockShiftState: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.lockShiftState = lockShiftState
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

  public var displayClassifySymbolButton: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayClassifySymbolButton = displayClassifySymbolButton
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

  public var displayCommentOfCandidateWord: Bool {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.displayCommentOfCandidateWord = displayCommentOfCandidateWord
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

  @Published
  public var symbolTableIsEditing: Bool = false

  /// 选择键盘类型
  public var useKeyboardType: KeyboardType {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.useKeyboardType = useKeyboardType.string
    }
  }

  // MARK: - combine

  /// 键盘类型
  /// 注意：没有为属性 useKeyboardType 加 @Published 是因为不想进入键盘布局页面解决跳转
  public var useKeyboardTypeSubject = PassthroughSubject<KeyboardType, Never>()
  public var useKeyboardTypePublished: AnyPublisher<KeyboardType, Never> {
    useKeyboardTypeSubject.eraseToAnyPublisher()
  }

  private var resetSignSubject = PassthroughSubject<Bool, Never>()
  public var resetSignPublished: AnyPublisher<Bool, Never> {
    resetSignSubject.eraseToAnyPublisher()
  }

  /// navigation 转 subview
  private let subViewSubject = PassthroughSubject<KeyboardSettingsSubView, Never>()
  public var subViewPublished: AnyPublisher<KeyboardSettingsSubView, Never> {
    subViewSubject.eraseToAnyPublisher()
  }

  /// 数字九宫格页面切换
  private let numberNineGridSubviewSwitchSubject = CurrentValueSubject<NumberNineGridTabView, Never>(.settings)
  public var numberNineGridSubviewSwitchPublished: AnyPublisher<NumberNineGridTabView, Never> {
    numberNineGridSubviewSwitchSubject.eraseToAnyPublisher()
  }

  /// 符号设置页面切换
  private let symbolSettingsSubviewSwitchSubject = CurrentValueSubject<Int, Never>(0)
  public var symbolSettingsSubviewPublished: AnyPublisher<Int, Never> {
    symbolSettingsSubviewSwitchSubject.eraseToAnyPublisher()
  }

  /// 键盘布局 segment 切换
  private var segmentActionSubject = PassthroughSubject<KeyboardLayoutSegmentAction, Never>()
  public var segmentActionPublished: AnyPublisher<KeyboardLayoutSegmentAction, Never> {
    segmentActionSubject.eraseToAnyPublisher()
  }

  /// 按键划动设置页面
  public var keySwipeSettingsActionSubject = PassthroughSubject<Key?, Never>()
  public var keySwipeSettingsActionPublished: AnyPublisher<Key?, Never> {
    keySwipeSettingsActionSubject.eraseToAnyPublisher()
  }

  // MARK: - init data

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
          text: "Shift状态锁定",
          type: .toggle,
          toggleValue: lockShiftState,
          toggleHandled: { [unowned self] in
            lockShiftState = $0
          })
      ]),

    .init(
      footer: "关闭后，上下滑动全部显示时，右侧为显示上划，左侧显示下划。",
      items: [
        .init(
          text: "左侧显示上划",
          type: .toggle,
          toggleValue: upSwipeOnLeft,
          toggleHandled: { [unowned self] in
            upSwipeOnLeft = $0
          })
      ]),

    .init(
      items: [
        .init(
          text: "键盘布局",
          accessoryType: .disclosureIndicator,
          type: .navigation,
          navigationAction: { [unowned self] in
            self.subViewSubject.send(.keyboardLayout)
          })
      ]
    ),
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
      ]
    ),
    .init(
      items: [
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

  /// 中文键盘设置
  lazy var chineseStanderSystemKeyboardSettingsItems: [SettingSectionModel] = [
    .init(
      footer: "“按键位于空格左侧”选项：关闭状态则位于空格右侧，开启状态则位于空格左侧",
      items: [
        .init(
          text: "启用分号按键",
          type: .toggle,
          toggleValue: displaySemicolonButton,
          toggleHandled: { [unowned self] in
            displaySemicolonButton = $0
          }),
        .init(
          text: "启用符号按键",
          type: .toggle,
          toggleValue: displayClassifySymbolButton,
          toggleHandled: { [unowned self] in
            displayClassifySymbolButton = $0
          }),
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
      ])
  ]

  /// 符号设置选项
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
      }),
    .init(
      text: "显示候选文字 Comment",
      toggleValue: displayCommentOfCandidateWord,
      toggleHandled: { [unowned self] in
        displayCommentOfCandidateWord = $0
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

  /// 键盘类型
  public var keyboardLayoutList: [KeyboardType] = [
    .chinese(.lowercased),
    .chineseNineGrid,
    .custom(named: "")
  ]

  /// 中文标准键盘默认划动选项
  public var chineseStanderSystemKeyboardSwipeList: [Key] = []
//  public var chineseStanderSystemKeyboardSwipeList: [Key] = [
//    Key(action: .character("a"), swipe: [
//      KeySwipe(direction: .up, action: .character("1"), label: KeyLabel(text: "1")),
//      KeySwipe(direction: .down, action: .character("x"), processByRIME: false, display: false, label: KeyLabel(text: "x"))
//    ]),
//    Key(action: .keyboardType(.numericNineGrid), swipe: [
//      KeySwipe(direction: .up, action: .custom(named: "#"), label: KeyLabel(text: "1"))
//    ]),
//    Key(action: .character("b"), swipe: [
//      KeySwipe(direction: .up, action: .character("2"), label: KeyLabel(text: "2"))
//    ])
//  ]

  // MARK: - Initialization

  public init(configuration: HamsterConfiguration) {
    self.displayButtonBubbles = configuration.Keyboard?.displayButtonBubbles ?? true
    self.upSwipeOnLeft = configuration.Keyboard?.upSwipeOnLeft ?? true
    self.displayKeyboardDismissButton = configuration.toolbar?.displayKeyboardDismissButton ?? true
    self.lockShiftState = configuration.Keyboard?.lockShiftState ?? true
    self.displaySpaceLeftButton = configuration.Keyboard?.displaySpaceLeftButton ?? true
    self.keyValueOfSpaceLeftButton = configuration.Keyboard?.keyValueOfSpaceLeftButton ?? ","
    self.displaySpaceRightButton = configuration.Keyboard?.displaySpaceRightButton ?? false
    self.keyValueOfSpaceRightButton = configuration.Keyboard?.keyValueOfSpaceRightButton ?? "."
    self.displayChineseEnglishSwitchButton = configuration.Keyboard?.displayChineseEnglishSwitchButton ?? true
    self.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = configuration.Keyboard?.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton ?? false
    self.enableToolbar = configuration.toolbar?.enableToolbar ?? true
    self.displaySemicolonButton = configuration.Keyboard?.displaySemicolonButton ?? false
    self.displayClassifySymbolButton = configuration.Keyboard?.displayClassifySymbolButton ?? true
    self.enableNineGridOfNumericKeyboard = configuration.Keyboard?.enableNineGridOfNumericKeyboard ?? false
    self.enterDirectlyOnScreenByNineGridOfNumericKeyboard = configuration.Keyboard?.enterDirectlyOnScreenByNineGridOfNumericKeyboard ?? false
    self.enableSymbolKeyboard = configuration.Keyboard?.enableSymbolKeyboard ?? false
    self.symbolsOfGridOfNumericKeyboard = configuration.Keyboard?.symbolsOfGridOfNumericKeyboard ?? []
    self.pairsOfSymbols = configuration.Keyboard?.pairsOfSymbols ?? []
    self.symbolsOfCursorBack = configuration.Keyboard?.symbolsOfCursorBack ?? []
    self.symbolsOfReturnToMainKeyboard = configuration.Keyboard?.symbolsOfReturnToMainKeyboard ?? []
    self.useKeyboardType = (configuration.Keyboard?.useKeyboardType ?? "chinese").keyboardType ?? .chinese(.lowercased)

    self.enableEmbeddedInputMode = configuration.Keyboard?.enableEmbeddedInputMode ?? false
    self.candidateWordFontSize = configuration.toolbar?.candidateWordFontSize ?? 20
    self.heightOfToolbar = configuration.toolbar?.heightOfToolbar ?? 50
    self.heightOfCodingArea = configuration.toolbar?.heightOfCodingArea ?? 10
    self.codingAreaFontSize = configuration.toolbar?.codingAreaFontSize ?? 12
    self.candidateCommentFontSize = configuration.toolbar?.candidateCommentFontSize ?? 12
    self.displayIndexOfCandidateWord = configuration.toolbar?.displayIndexOfCandidateWord ?? false
    self.displayCommentOfCandidateWord = configuration.toolbar?.displayCommentOfCandidateWord ?? false
    self.maximumNumberOfCandidateWords = configuration.rime?.maximumNumberOfCandidateWords ?? 100

    for keyboardSwipe in configuration.swipe?.keyboardSwipe ?? [] {
      if keyboardSwipe.keyboardType?.isChinesePrimaryKeyboard ?? false {
        self.chineseStanderSystemKeyboardSwipeList = keyboardSwipe.keys ?? []
      }
    }
  }
}

// MARK: - target-action

extension KeyboardSettingsViewModel {
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

  @objc func chineseLayoutSegmentChangeAction(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      segmentActionSubject.send(.chineseLayoutSettings)
    case 1:
      segmentActionSubject.send(.chineseLayoutSwipeSettings)
    default:
      return
    }
  }
}

// MARK: - KeyboardLayout 键盘布局相关

extension KeyboardSettingsViewModel {
  /// 键盘布局总列表 DataSource
  func initKeyboardLayoutDataSource() -> NSDiffableDataSourceSnapshot<Int, KeyboardType> {
    var snapshot = NSDiffableDataSourceSnapshot<Int, KeyboardType>()
    snapshot.appendSections([0])
    snapshot.appendItems(keyboardLayoutList, toSection: 0)
    return snapshot
  }

  /// 中文26键盘布局 DataSource
  func initChineseStanderSystemKeyboardDataSource() -> NSDiffableDataSourceSnapshot<SettingSectionModel, SettingItemModel> {
    var snapshot = NSDiffableDataSourceSnapshot<SettingSectionModel, SettingItemModel>()
    snapshot.appendSections(chineseStanderSystemKeyboardSettingsItems)
    chineseStanderSystemKeyboardSettingsItems.forEach { item in
      snapshot.appendItems(item.items, toSection: item)
    }
    return snapshot
  }

  /// 中文26键盘划动 DataSource
  func initChineseStanderSystemKeyboardSwipeDataSource() -> NSDiffableDataSourceSnapshot<Int, Key> {
    var snapshot = NSDiffableDataSourceSnapshot<Int, Key>()
    snapshot.appendSections([0])
    snapshot.appendItems(chineseStanderSystemKeyboardSwipeList, toSection: 0)
    return snapshot
  }
}

// MARK: - Constants

public extension KeyboardSettingsViewModel {
  static let symbolKeyboardRemark = "启用后，常规符号键盘将被替换为符号键盘。常规符号键盘布局类似系统自带键盘符号布局。"
  static let enableKeyboardAutomaticallyLowercaseRemark = "关闭后，Shift状态随当前输入状态变化。注意: 双击Shift会保持锁定"
}

extension KeyboardType {
  var label: String {
    switch self {
    case .chinese: return "中文26键"
    case .chineseNineGrid: return "中文9键"
    case .custom: return "自定义键盘"
    case .numericNineGrid: return "数字九宫格"
    default: return ""
    }
  }

  var string: String {
    switch self {
    case .chinese: return "chinese"
    case .chineseNineGrid: return "chineseNineGrid"
    case .custom(let name): return "custom(\(name))"
    default: return ""
    }
  }
}
