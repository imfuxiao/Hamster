//
//  KeyboardSettingsViewModel.swift
//
//
//  Created by morse on 2023/7/12.
//

import Combine
import HamsterKeyboardKit
import HamsterKit
import OSLog
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
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayButtonBubbles ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayButtonBubbles = newValue
    }
  }

  public var upSwipeOnLeft: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.upSwipeOnLeft ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.upSwipeOnLeft = newValue
    }
  }

  public var enableEmbeddedInputMode: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableEmbeddedInputMode ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableEmbeddedInputMode = newValue
    }
  }

  public var lockShiftState: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.lockShiftState ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.lockShiftState = newValue
    }
  }

  public var displaySpaceLeftButton: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displaySpaceLeftButton ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displaySpaceLeftButton = newValue
    }
  }

  public var keyValueOfSpaceLeftButton: String {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.keyValueOfSpaceLeftButton ?? ""
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.keyValueOfSpaceLeftButton = newValue
    }
  }

  public var displaySpaceRightButton: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displaySpaceRightButton ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displaySpaceRightButton = newValue
    }
  }

  public var keyValueOfSpaceRightButton: String {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.keyValueOfSpaceRightButton ?? ""
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.keyValueOfSpaceRightButton = newValue
    }
  }

  public var displayChineseEnglishSwitchButton: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayChineseEnglishSwitchButton ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayChineseEnglishSwitchButton = newValue
    }
  }

  public var chineseEnglishSwitchButtonIsOnLeftOfSpaceButton: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = newValue
    }
  }

  public var enableToolbar: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.enableToolbar ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.enableToolbar = newValue
    }
  }

  public var displaySemicolonButton: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displaySemicolonButton ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displaySemicolonButton = newValue
    }
  }

  public var displayClassifySymbolButton: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayClassifySymbolButton ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.displayClassifySymbolButton = newValue
    }
  }

  public var enableNineGridOfNumericKeyboard: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableNineGridOfNumericKeyboard ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableNineGridOfNumericKeyboard = newValue
    }
  }

  public var enterDirectlyOnScreenByNineGridOfNumericKeyboard: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enterDirectlyOnScreenByNineGridOfNumericKeyboard ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enterDirectlyOnScreenByNineGridOfNumericKeyboard = newValue
    }
  }

  public var enableSymbolKeyboard: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableSymbolKeyboard ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableSymbolKeyboard = newValue
    }
  }

  public var candidateWordFontSize: Int {
    get {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.candidateWordFontSize ?? 20
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.candidateWordFontSize = newValue
    }
  }

  public var heightOfToolbar: Int {
    get {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.heightOfToolbar ?? 50
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.heightOfToolbar = newValue
    }
  }

  public var heightOfCodingArea: Int {
    get {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.heightOfCodingArea ?? 10
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.heightOfCodingArea = newValue
    }
  }

  public var codingAreaFontSize: Int {
    get {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.codingAreaFontSize ?? 12
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.codingAreaFontSize = newValue
    }
  }

  public var candidateCommentFontSize: Int {
    get {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.candidateCommentFontSize ?? 12
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.candidateCommentFontSize = newValue
    }
  }

  public var displayKeyboardDismissButton: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.displayKeyboardDismissButton ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.displayKeyboardDismissButton = newValue
    }
  }

  public var displayIndexOfCandidateWord: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.displayIndexOfCandidateWord ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.displayIndexOfCandidateWord = newValue
    }
  }

  public var displayCommentOfCandidateWord: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.displayCommentOfCandidateWord ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.toolbar?.displayCommentOfCandidateWord = newValue
    }
  }

  public var maximumNumberOfCandidateWords: Int {
    get {
      HamsterAppDependencyContainer.shared.configuration.rime?.maximumNumberOfCandidateWords ?? 100
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.rime?.maximumNumberOfCandidateWords = newValue
    }
  }

  public var symbolsOfGridOfNumericKeyboard: [String] {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfGridOfNumericKeyboard ?? []
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfGridOfNumericKeyboard = newValue
    }
  }

  public var pairsOfSymbols: [String] {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.pairsOfSymbols ?? []
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.pairsOfSymbols = newValue
    }
  }

  public var symbolsOfCursorBack: [String] {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfCursorBack ?? []
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfCursorBack = newValue
    }
  }

  public var symbolsOfReturnToMainKeyboard: [String] {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfReturnToMainKeyboard ?? []
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfReturnToMainKeyboard = newValue
    }
  }

  public var symbolsOfChineseNineGridKeyboard: [String] {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfChineseNineGridKeyboard ?? []
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.symbolsOfChineseNineGridKeyboard = newValue
    }
  }

  /// 中文标准键盘默认划动选项
  public var chineseStanderSystemKeyboardSwipeList: [Key] {
    HamsterAppDependencyContainer.shared.configuration.swipe?.keyboardSwipe?
      .first(where: { $0.keyboardType?.isChinesePrimaryKeyboard ?? false })?
      .keys ?? []
  }

  /// 选择键盘类型
  public var useKeyboardType: KeyboardType? {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.useKeyboardType?.keyboardType
    }
    set {
      guard let keyboardType = newValue else { return }
      if case .custom(let named, _) = keyboardType {
        if !named.isEmpty {
          HamsterAppDependencyContainer.shared.configuration.Keyboard?.useKeyboardType = keyboardType.yamlString
        }
        return
      }
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.useKeyboardType = keyboardType.yamlString
    }
  }

  /// 键盘布局用户选择设置键盘类型
  public var settingsKeyboardType: KeyboardType? = nil

  /// 键盘类型
  public var keyboardLayoutList: [KeyboardType] {
    let list: [KeyboardType] = [
      .chinese(.lowercased),
      .chineseNineGrid
    ]
    return list + (HamsterAppDependencyContainer.shared.configuration.keyboards ?? []).map { $0.type }
  }

  // MARK: - combine

  // 中文九宫格符号列表编辑状态
  @Published
  public var symbolsOfChineseNineGridIsEditing: Bool = false

  @Published
  public var symbolTableIsEditing: Bool = false

  /// 键盘类型
  /// 注意：没有为属性 useKeyboardType 加 @Published 是因为不想进入键盘布局页面解决跳转
  public var useKeyboardTypeSubject = PassthroughSubject<KeyboardType, Never>()
  public var useKeyboardTypePublished: AnyPublisher<KeyboardType, Never> {
    useKeyboardTypeSubject.eraseToAnyPublisher()
  }

  /// 重置信号，当需要 table/collection 重新加载时使用
  public var resetSignSubject = PassthroughSubject<Bool, Never>()
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

  /// 打开文档页面
  public var openDocumentPickerSubject = PassthroughSubject<Bool, Never>()
  public var openDocumentPickerPublished: AnyPublisher<Bool, Never> {
    openDocumentPickerSubject.eraseToAnyPublisher()
  }

  /// keyboardLayout Root View Reload
  public var reloadRootViewSubject = PassthroughSubject<Bool, Never>()
  public var reloadRootViewPublished: AnyPublisher<Bool, Never> {
    reloadRootViewSubject.eraseToAnyPublisher()
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
          toggleValue: { [unowned self] in displayButtonBubbles },
          toggleHandled: { [unowned self] in
            displayButtonBubbles = $0
          }),
        .init(
          text: "启用内嵌模式",
          type: .toggle,
          toggleValue: { [unowned self] in enableEmbeddedInputMode },
          toggleHandled: { [unowned self] in
            enableEmbeddedInputMode = $0
          }),
        .init(
          text: "Shift状态锁定",
          type: .toggle,
          toggleValue: { [unowned self] in lockShiftState },
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
          toggleValue: { [unowned self] in upSwipeOnLeft },
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
          // navigationLinkLabel: { [unowned self] in enableNineGridOfNumericKeyboard ? "启用" : "禁用" },
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
          // navigationLinkLabel: { [unowned self] in enableSymbolKeyboard ? "启用" : "禁用" },
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
          toggleValue: { [unowned self] in displaySemicolonButton },
          toggleHandled: { [unowned self] in
            displaySemicolonButton = $0
          }),
        .init(
          text: "启用符号按键",
          type: .toggle,
          toggleValue: { [unowned self] in displayClassifySymbolButton },
          toggleHandled: { [unowned self] in
            displayClassifySymbolButton = $0
          }),
        .init(
          text: "启用中英切换按键",
          type: .toggle,
          toggleValue: { [unowned self] in displayChineseEnglishSwitchButton },
          toggleHandled: { [unowned self] in
            displayChineseEnglishSwitchButton = $0
          }),
        .init(
          text: "按键位于空格左侧",
          type: .toggle,
          toggleValue: { [unowned self] in chineseEnglishSwitchButtonIsOnLeftOfSpaceButton },
          toggleHandled: { [unowned self] in
            chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = $0
          })
      ]),
    .init(
      items: [
        .init(
          text: "启用空格左侧按键",
          type: .toggle,
          toggleValue: { [unowned self] in displaySpaceLeftButton },
          toggleHandled: { [unowned self] in
            displaySpaceLeftButton = $0
          }),
        .init(
          icon: UIImage(systemName: "square.and.pencil"),
          placeholder: "左侧按键键值",
          type: .textField,
          textValue: { [unowned self] in keyValueOfSpaceLeftButton },
          textHandled: { [unowned self] in
            keyValueOfSpaceLeftButton = $0
          }),
        .init(
          text: "启用空格右侧按键",
          type: .toggle,
          toggleValue: { [unowned self] in displaySpaceRightButton },
          toggleHandled: { [unowned self] in
            displaySpaceRightButton = $0
          }),
        .init(
          icon: UIImage(systemName: "square.and.pencil"),
          placeholder: "右侧按键键值",
          type: .textField,
          textValue: { [unowned self] in keyValueOfSpaceRightButton },
          textHandled: { [unowned self] in
            keyValueOfSpaceRightButton = $0
          })
      ])
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
      toggleValue: { [unowned self] in enableToolbar },
      toggleHandled: { [unowned self] in
        enableToolbar = $0
      }),
    .init(
      text: "显示键盘收起图标",
      toggleValue: { [unowned self] in displayKeyboardDismissButton },
      toggleHandled: { [unowned self] in
        displayKeyboardDismissButton = $0
      }),
    .init(
      text: "显示候选项索引",
      toggleValue: { [unowned self] in displayIndexOfCandidateWord },
      toggleHandled: { [unowned self] in
        displayIndexOfCandidateWord = $0
      }),
    .init(
      text: "显示候选文字 Comment",
      toggleValue: { [unowned self] in displayCommentOfCandidateWord },
      toggleHandled: { [unowned self] in
        displayCommentOfCandidateWord = $0
      })
  ]

  lazy var numberNineGridSettings: [SettingItemModel] = [
    //    .init(
//      text: "启用数字九宫格",
//      type: .toggle,
//      toggleValue: enableNineGridOfNumericKeyboard,
//      toggleHandled: { [unowned self] in
//        enableNineGridOfNumericKeyboard = $0
//      }),
    .init(
      text: "是否直接上屏",
      type: .toggle,
      toggleValue: { [unowned self] in enterDirectlyOnScreenByNineGridOfNumericKeyboard },
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
    //    .init(
//      text: "启用符号键盘",
//      type: .toggle,
//      toggleValue: enableSymbolKeyboard,
//      toggleHandled: { [unowned self] in
//        enableSymbolKeyboard = $0
//      }),
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

  // MARK: - Initialization

  public init() {
//    self.displayButtonBubbles = configuration.Keyboard?.displayButtonBubbles ?? true
//    self.upSwipeOnLeft = configuration.Keyboard?.upSwipeOnLeft ?? true
//    self.displayKeyboardDismissButton = configuration.toolbar?.displayKeyboardDismissButton ?? true
//    self.lockShiftState = configuration.Keyboard?.lockShiftState ?? true
//    self.displaySpaceLeftButton = configuration.Keyboard?.displaySpaceLeftButton ?? true
//    self.keyValueOfSpaceLeftButton = configuration.Keyboard?.keyValueOfSpaceLeftButton ?? ","
//    self.displaySpaceRightButton = configuration.Keyboard?.displaySpaceRightButton ?? false
//    self.keyValueOfSpaceRightButton = configuration.Keyboard?.keyValueOfSpaceRightButton ?? "."
//    self.displayChineseEnglishSwitchButton = configuration.Keyboard?.displayChineseEnglishSwitchButton ?? true
//    self.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = configuration.Keyboard?.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton ?? false
//    self.enableToolbar = configuration.toolbar?.enableToolbar ?? true
//    self.displaySemicolonButton = configuration.Keyboard?.displaySemicolonButton ?? false
//    self.displayClassifySymbolButton = configuration.Keyboard?.displayClassifySymbolButton ?? true
//    self.enableNineGridOfNumericKeyboard = configuration.Keyboard?.enableNineGridOfNumericKeyboard ?? false
//    self.enterDirectlyOnScreenByNineGridOfNumericKeyboard = configuration.Keyboard?.enterDirectlyOnScreenByNineGridOfNumericKeyboard ?? false
//    self.enableSymbolKeyboard = configuration.Keyboard?.enableSymbolKeyboard ?? false
//    self.symbolsOfGridOfNumericKeyboard = configuration.Keyboard?.symbolsOfGridOfNumericKeyboard ?? []
//    self.pairsOfSymbols = configuration.Keyboard?.pairsOfSymbols ?? []
//    self.symbolsOfCursorBack = configuration.Keyboard?.symbolsOfCursorBack ?? []
//    self.symbolsOfReturnToMainKeyboard = configuration.Keyboard?.symbolsOfReturnToMainKeyboard ?? []
//    self.useKeyboardType = (configuration.Keyboard?.useKeyboardType ?? "chinese").keyboardType ?? .chinese(.lowercased)
//
//    self.enableEmbeddedInputMode = configuration.Keyboard?.enableEmbeddedInputMode ?? false
//    self.candidateWordFontSize = configuration.toolbar?.candidateWordFontSize ?? 20
//    self.heightOfToolbar = configuration.toolbar?.heightOfToolbar ?? 50
//    self.heightOfCodingArea = configuration.toolbar?.heightOfCodingArea ?? 10
//    self.codingAreaFontSize = configuration.toolbar?.codingAreaFontSize ?? 12
//    self.candidateCommentFontSize = configuration.toolbar?.candidateCommentFontSize ?? 12
//    self.displayIndexOfCandidateWord = configuration.toolbar?.displayIndexOfCandidateWord ?? false
//    self.displayCommentOfCandidateWord = configuration.toolbar?.displayCommentOfCandidateWord ?? false
//    self.maximumNumberOfCandidateWords = configuration.rime?.maximumNumberOfCandidateWords ?? 100

//    for keyboardSwipe in configuration.swipe?.keyboardSwipe ?? [] {
//      if keyboardSwipe.keyboardType?.isChinesePrimaryKeyboard ?? false {
//        self.chineseStanderSystemKeyboardSwipeList = keyboardSwipe.keys ?? []
//      }
//    }

//    self.keyboardLayoutList = keyboardLayoutList + (configuration.customizeKeyboards ?? []).map { $0.type }
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

  @objc func changeSymbolsOfChineseNineGridEditorState() {
    symbolsOfChineseNineGridIsEditing.toggle()
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

  /// 导入自定义键盘布局
  @objc func importCustomizeKeyboardLayout() {
    openDocumentPickerSubject.send(true)
  }

  /// 导出自定义键盘布局
  @objc func exportCustomizeKeyboardLayout() {}
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

  /// 自定义键盘列表 DataSource
//  func initCustomizerKeyboardLayoutDataSource() -> NSDiffableDataSourceSnapshot<Int, KeyboardType> {
//    var snapshot = NSDiffableDataSourceSnapshot<Int, KeyboardType>()
//    snapshot.appendSections([0])
//    snapshot.appendItems(customizeKeyboardLayoutList, toSection: 0)
//    return snapshot
//  }

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

  /// 导入自定义键盘布局
  public func importCustomizeKeyboardLayout(fileURL: URL) async {
    Logger.statistics.debug("importCustomizeKeyboardLayout fileName: \(fileURL.path)")
    await ProgressHUD.show("导入中……", interaction: false)
    // 检测是否为iCloudURL, 需要特殊处理
    var needAccessingSecurity = false
    if fileURL.path.contains("com~apple~CloudDocs") || fileURL.path.contains("iCloud~dev~fuxiao~app~hamsterapp") {
      needAccessingSecurity = true
      // iCloud中的URL须添加安全访问资源语句，否则会异常：Operation not permitted
      // startAccessingSecurityScopedResource与stopAccessingSecurityScopedResource必须成对出现
      if !fileURL.startAccessingSecurityScopedResource() {
        await ProgressHUD.showError("导入文件读取受限，无法加载文件", interaction: false, delay: 1.5)
        return
      }
    }

    // 加载自定义键盘配置文件
    do {
      let keyboards = try HamsterConfigurationRepositories.shared.loadCustomizerKeyboardLayoutYAML(fileURL)

      // 停止读取url文件
      if needAccessingSecurity { fileURL.stopAccessingSecurityScopedResource() }

      // 内置键盘
      // 注意：.filter 会过滤掉与导入键盘名称相同的键盘
      let originalKeyboards = (HamsterAppDependencyContainer.shared.configuration.keyboards ?? [])
        .filter {
          for importKeyboard in keyboards.keyboards {
            if importKeyboard.type == $0.type {
              return false
            }
          }
          return true
        }

      HamsterAppDependencyContainer.shared.configuration.keyboards = originalKeyboards + keyboards.keyboards

      await ProgressHUD.showSuccess("导入成功", interaction: false, delay: 1.5)
      reloadRootViewSubject.send(true)
    } catch {
      Logger.statistics.error("importCustomizeKeyboardLayout error: \(error)")
      await ProgressHUD.showError("自定义键盘配置文件加载失败", interaction: false, delay: 1.5)
      return
    }
  }

  /// 删除自定义键盘布局
  func deleteCustomizeKeyboardLayout(_ keyboardType: KeyboardType) {
    var keyboards = HamsterAppDependencyContainer.shared.configuration.keyboards ?? []
    if let index = keyboards.firstIndex(where: { $0.type == keyboardType }) {
      keyboards.remove(at: index)
      HamsterAppDependencyContainer.shared.configuration.keyboards = keyboards
      ProgressHUD.showSuccess("删除成功", interaction: false, delay: 1.5)
      reloadRootViewSubject.send(true)
    } else {
      ProgressHUD.showFailed("未找到此键盘", interaction: false, delay: 1.5)
    }
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
    case .custom(let name, _): return name.isEmpty ? "自定义键盘" : "自定义-\(name)"
    case .numericNineGrid: return "数字九宫格"
    default: return ""
    }
  }

  var yamlString: String {
    switch self {
    case .chinese: return "chinese"
    case .chineseNineGrid: return "chineseNineGrid"
    case .custom(let name, _): return "custom(\(name))"
    default: return ""
    }
  }
}
