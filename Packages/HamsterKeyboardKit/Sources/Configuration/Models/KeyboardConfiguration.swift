//
//  KeyboardConfiguration.swift
//
//
//  Created by morse on 2023/6/30.
//

import Foundation

/// 键盘配置
public struct KeyboardConfiguration: Codable, Hashable {
  /// 使用键盘类型
  public var useKeyboardType: String?

  /// 关闭划动显示文本
  public var disableSwipeLabel: Bool?

  /// 上划显示在左侧
  public var upSwipeOnLeft: Bool?

  /// 划动上下布局 or 左右布局
  public var swipeLabelUpAndDownLayout: Bool?

  /// 上下显示划动文本不规则布局
  public var swipeLabelUpAndDownIrregularLayout: Bool?

  /// 显示按键气泡
  /// true: 显示 false: 不显示
  public var displayButtonBubbles: Bool?

  /// 启用按键声音
  /// true: 启用 false 停用
  public var enableKeySounds: Bool?

  /// 启用震动反馈
  /// true: 启用 false 停用
  public var enableHapticFeedback: Bool?

  /// 震动反馈强度
  /// 目前支持5档震动强度: 0到4， 0表示最弱 4表示最强
  public var hapticFeedbackIntensity: Int?

  /// 显示分号按键
  public var displaySemicolonButton: Bool?

  /// 显示分类符号按键
  public var displayClassifySymbolButton: Bool?

  /// 显示空格左边按键
  public var displaySpaceLeftButton: Bool?

  /// 空格左侧按键由RIME处理
  public var spaceLeftButtonProcessByRIME: Bool?

  /// 空格左边按键对应的键值
  public var keyValueOfSpaceLeftButton: String?

  /// 显示空格右边按键
  public var displaySpaceRightButton: Bool?

  /// 空格右侧按键由RIME处理
  public var spaceRightButtonProcessByRIME: Bool?

  /// 空格右边按键对应的键值
  public var keyValueOfSpaceRightButton: String?

  /// 显示中英切换按键
  public var displayChineseEnglishSwitchButton: Bool?

  /// 中英切换按键在空格左侧
  /// true 位于左侧 false 位于右侧
  public var chineseEnglishSwitchButtonIsOnLeftOfSpaceButton: Bool?

  /// 启用九宫格数字键盘
  public var enableNineGridOfNumericKeyboard: Bool?

  /// 数字九宫格键盘: 数字键是否由 RIME 处理
  public var numberKeyProcessByRimeOnNineGridOfNumericKeyboard: Bool?

  /// 数字九宫格键盘：左侧符号列表符号是否由 RIME 处理
  public var leftSymbolProcessByRimeOnNineGridOfNumericKeyboard: Bool?

  /// 数字九宫格键盘：右侧符号否由 RIME 处理
  public var rightSymbolProcessByRimeOnNineGridOfNumericKeyboard: Bool?

  /// 九宫格数字键盘: 符号列表
  public var symbolsOfGridOfNumericKeyboard: [String]?

  /// Shift状态锁定
  public var lockShiftState: Bool?

  /// 启用嵌入式输入模式
  public var enableEmbeddedInputMode: Bool?

  /// 单手键盘宽度
  public var widthOfOneHandedKeyboard: Int?

  /// 符号上屏后光标回退
  public var symbolsOfCursorBack: [String]?

  /// 符号上屏后，键盘返回主键盘
  public var symbolsOfReturnToMainKeyboard: [String]?

  /// 中文九宫格符号列
  public var symbolsOfChineseNineGridKeyboard: [String]?

  /// 成对上屏的符号
  public var pairsOfSymbols: [String]?

  /// 启用符号键盘
  public var enableSymbolKeyboard: Bool?

  /// 符号键盘锁定
  /// 锁定后键盘不会自动返回主键盘
  public var lockForSymbolKeyboard: Bool?

  /// 启用颜色方案
  public var enableColorSchema: Bool?

  /// 浅色模式下颜色方案
  public var useColorSchemaForLight: String?

  /// 暗色模式下颜色方案
  public var useColorSchemaForDark: String?

  /// 键盘颜色方案列表
  public var colorSchemas: [KeyboardColorSchema]?

  // 是否启用空格加载文本
  public var enableLoadingTextForSpaceButton: Bool?

  // 空格按钮加载文本
  public var loadingTextForSpaceButton: String?

  // 空格按钮长显文本
  public var labelTextForSpaceButton: String?

  // 空格按钮长显为当前输入方案
  // 当开启此选项后，labelForSpaceButton 设置的值无效
  public var showCurrentInputSchemaNameForSpaceButton: Bool?

  // 空格按钮加载文字显示当前输入方案
  // 当开启此选项后， loadingTextForSpaceButton 设置的值无效
  public var showCurrentInputSchemaNameOnLoadingTextForSpaceButton: Bool?

  // 中文26键显示大写字符
  public var showUppercasedCharacterOnChineseKeyboard: Bool?

  // 按键下方边框
  public var enableButtonUnderBorder: Bool?

  public init(useKeyboardType: String? = nil, disableSwipeLabel: Bool? = nil, upSwipeOnLeft: Bool? = nil, swipeLabelUpAndDownLayout: Bool? = nil, swipeLabelUpAndDownIrregularLayout: Bool? = nil, displayButtonBubbles: Bool? = nil, enableKeySounds: Bool? = nil, enableHapticFeedback: Bool? = nil, hapticFeedbackIntensity: Int? = nil, displaySemicolonButton: Bool? = nil, displayClassifySymbolButton: Bool? = nil, displaySpaceLeftButton: Bool? = nil, spaceLeftButtonProcessByRIME: Bool? = nil, keyValueOfSpaceLeftButton: String? = nil, displaySpaceRightButton: Bool? = nil, spaceRightButtonProcessByRIME: Bool? = nil, keyValueOfSpaceRightButton: String? = nil, displayChineseEnglishSwitchButton: Bool? = nil, chineseEnglishSwitchButtonIsOnLeftOfSpaceButton: Bool? = nil, enableNineGridOfNumericKeyboard: Bool? = nil, numberKeyProcessByRimeOnNineGridOfNumericKeyboard: Bool? = nil, leftSymbolProcessByRimeOnNineGridOfNumericKeyboard: Bool? = nil, rightSymbolProcessByRimeOnNineGridOfNumericKeyboard: Bool? = nil, symbolsOfGridOfNumericKeyboard: [String]? = nil, lockShiftState: Bool? = nil, enableEmbeddedInputMode: Bool? = nil, widthOfOneHandedKeyboard: Int? = nil, symbolsOfCursorBack: [String]? = nil, symbolsOfReturnToMainKeyboard: [String]? = nil, symbolsOfChineseNineGridKeyboard: [String]? = nil, pairsOfSymbols: [String]? = nil, enableSymbolKeyboard: Bool? = nil, lockForSymbolKeyboard: Bool? = nil, enableColorSchema: Bool? = nil, useColorSchemaForLight: String? = nil, useColorSchemaForDark: String? = nil, colorSchemas: [KeyboardColorSchema]? = nil, enableLoadingTextForSpaceButton: Bool? = nil, loadingTextForSpaceButton: String? = nil, labelTextForSpaceButton: String? = nil, showCurrentInputSchemaNameForSpaceButton: Bool? = nil, showCurrentInputSchemaNameOnLoadingTextForSpaceButton: Bool? = nil, showUppercasedCharacterOnChineseKeyboard: Bool? = nil, enableButtonUnderBorder: Bool? = nil) {
    self.useKeyboardType = useKeyboardType
    self.disableSwipeLabel = disableSwipeLabel
    self.upSwipeOnLeft = upSwipeOnLeft
    self.swipeLabelUpAndDownLayout = swipeLabelUpAndDownLayout
    self.swipeLabelUpAndDownIrregularLayout = swipeLabelUpAndDownIrregularLayout
    self.displayButtonBubbles = displayButtonBubbles
    self.enableKeySounds = enableKeySounds
    self.enableHapticFeedback = enableHapticFeedback
    self.hapticFeedbackIntensity = hapticFeedbackIntensity
    self.displaySemicolonButton = displaySemicolonButton
    self.displayClassifySymbolButton = displayClassifySymbolButton
    self.displaySpaceLeftButton = displaySpaceLeftButton
    self.spaceLeftButtonProcessByRIME = spaceLeftButtonProcessByRIME
    self.keyValueOfSpaceLeftButton = keyValueOfSpaceLeftButton
    self.displaySpaceRightButton = displaySpaceRightButton
    self.spaceRightButtonProcessByRIME = spaceRightButtonProcessByRIME
    self.keyValueOfSpaceRightButton = keyValueOfSpaceRightButton
    self.displayChineseEnglishSwitchButton = displayChineseEnglishSwitchButton
    self.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = chineseEnglishSwitchButtonIsOnLeftOfSpaceButton
    self.enableNineGridOfNumericKeyboard = enableNineGridOfNumericKeyboard
    self.numberKeyProcessByRimeOnNineGridOfNumericKeyboard = numberKeyProcessByRimeOnNineGridOfNumericKeyboard
    self.leftSymbolProcessByRimeOnNineGridOfNumericKeyboard = leftSymbolProcessByRimeOnNineGridOfNumericKeyboard
    self.rightSymbolProcessByRimeOnNineGridOfNumericKeyboard = rightSymbolProcessByRimeOnNineGridOfNumericKeyboard
    self.symbolsOfGridOfNumericKeyboard = symbolsOfGridOfNumericKeyboard
    self.lockShiftState = lockShiftState
    self.enableEmbeddedInputMode = enableEmbeddedInputMode
    self.widthOfOneHandedKeyboard = widthOfOneHandedKeyboard
    self.symbolsOfCursorBack = symbolsOfCursorBack
    self.symbolsOfReturnToMainKeyboard = symbolsOfReturnToMainKeyboard
    self.symbolsOfChineseNineGridKeyboard = symbolsOfChineseNineGridKeyboard
    self.pairsOfSymbols = pairsOfSymbols
    self.enableSymbolKeyboard = enableSymbolKeyboard
    self.lockForSymbolKeyboard = lockForSymbolKeyboard
    self.enableColorSchema = enableColorSchema
    self.useColorSchemaForLight = useColorSchemaForLight
    self.useColorSchemaForDark = useColorSchemaForDark
    self.colorSchemas = colorSchemas
    self.enableLoadingTextForSpaceButton = enableLoadingTextForSpaceButton
    self.loadingTextForSpaceButton = loadingTextForSpaceButton
    self.labelTextForSpaceButton = labelTextForSpaceButton
    self.showCurrentInputSchemaNameForSpaceButton = showCurrentInputSchemaNameForSpaceButton
    self.showCurrentInputSchemaNameOnLoadingTextForSpaceButton = showCurrentInputSchemaNameOnLoadingTextForSpaceButton
    self.showUppercasedCharacterOnChineseKeyboard = showUppercasedCharacterOnChineseKeyboard
    self.enableButtonUnderBorder = enableButtonUnderBorder
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.useKeyboardType = try container.decodeIfPresent(String.self, forKey: .useKeyboardType)
    self.disableSwipeLabel = try container.decodeIfPresent(Bool.self, forKey: .disableSwipeLabel)
    self.upSwipeOnLeft = try container.decodeIfPresent(Bool.self, forKey: .upSwipeOnLeft)
    self.swipeLabelUpAndDownLayout = try container.decodeIfPresent(Bool.self, forKey: .swipeLabelUpAndDownLayout)
    self.swipeLabelUpAndDownIrregularLayout = try container.decodeIfPresent(Bool.self, forKey: .swipeLabelUpAndDownIrregularLayout)
    self.displayButtonBubbles = try container.decodeIfPresent(Bool.self, forKey: .displayButtonBubbles)
    self.enableKeySounds = try container.decodeIfPresent(Bool.self, forKey: .enableKeySounds)
    self.enableHapticFeedback = try container.decodeIfPresent(Bool.self, forKey: .enableHapticFeedback)
    self.hapticFeedbackIntensity = try container.decodeIfPresent(Int.self, forKey: .hapticFeedbackIntensity)
    self.displaySemicolonButton = try container.decodeIfPresent(Bool.self, forKey: .displaySemicolonButton)
    self.displayClassifySymbolButton = try container.decodeIfPresent(Bool.self, forKey: .displayClassifySymbolButton)
    self.displaySpaceLeftButton = try container.decodeIfPresent(Bool.self, forKey: .displaySpaceLeftButton)
    self.spaceLeftButtonProcessByRIME = try container.decodeIfPresent(Bool.self, forKey: .spaceLeftButtonProcessByRIME)
    self.keyValueOfSpaceLeftButton = try container.decodeIfPresent(String.self, forKey: .keyValueOfSpaceLeftButton)
    self.displaySpaceRightButton = try container.decodeIfPresent(Bool.self, forKey: .displaySpaceRightButton)
    self.spaceRightButtonProcessByRIME = try container.decodeIfPresent(Bool.self, forKey: .spaceRightButtonProcessByRIME)
    self.keyValueOfSpaceRightButton = try container.decodeIfPresent(String.self, forKey: .keyValueOfSpaceRightButton)
    self.displayChineseEnglishSwitchButton = try container.decodeIfPresent(Bool.self, forKey: .displayChineseEnglishSwitchButton)
    self.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton = try container.decodeIfPresent(Bool.self, forKey: .chineseEnglishSwitchButtonIsOnLeftOfSpaceButton)
    self.enableNineGridOfNumericKeyboard = try container.decodeIfPresent(Bool.self, forKey: .enableNineGridOfNumericKeyboard)
    self.numberKeyProcessByRimeOnNineGridOfNumericKeyboard = try container.decodeIfPresent(Bool.self, forKey: .numberKeyProcessByRimeOnNineGridOfNumericKeyboard)
    self.leftSymbolProcessByRimeOnNineGridOfNumericKeyboard = try container.decodeIfPresent(Bool.self, forKey: .leftSymbolProcessByRimeOnNineGridOfNumericKeyboard)
    self.rightSymbolProcessByRimeOnNineGridOfNumericKeyboard = try container.decodeIfPresent(Bool.self, forKey: .rightSymbolProcessByRimeOnNineGridOfNumericKeyboard)
    self.symbolsOfGridOfNumericKeyboard = try container.decodeIfPresent([String].self, forKey: .symbolsOfGridOfNumericKeyboard)
    self.lockShiftState = try container.decodeIfPresent(Bool.self, forKey: .lockShiftState)
    self.enableEmbeddedInputMode = try container.decodeIfPresent(Bool.self, forKey: .enableEmbeddedInputMode)
    self.widthOfOneHandedKeyboard = try container.decodeIfPresent(Int.self, forKey: .widthOfOneHandedKeyboard)
    self.symbolsOfCursorBack = try container.decodeIfPresent([String].self, forKey: .symbolsOfCursorBack)
    self.symbolsOfReturnToMainKeyboard = try container.decodeIfPresent([String].self, forKey: .symbolsOfReturnToMainKeyboard)
    self.symbolsOfChineseNineGridKeyboard = try container.decodeIfPresent([String].self, forKey: .symbolsOfChineseNineGridKeyboard)
    self.pairsOfSymbols = try container.decodeIfPresent([String].self, forKey: .pairsOfSymbols)
    self.enableSymbolKeyboard = try container.decodeIfPresent(Bool.self, forKey: .enableSymbolKeyboard)
    self.lockForSymbolKeyboard = try container.decodeIfPresent(Bool.self, forKey: .lockForSymbolKeyboard)
    self.enableColorSchema = try container.decodeIfPresent(Bool.self, forKey: .enableColorSchema)
    self.useColorSchemaForLight = try container.decodeIfPresent(String.self, forKey: .useColorSchemaForLight)
    self.useColorSchemaForDark = try container.decodeIfPresent(String.self, forKey: .useColorSchemaForDark)
    self.colorSchemas = try container.decodeIfPresent([KeyboardColorSchema].self, forKey: .colorSchemas)
    self.enableLoadingTextForSpaceButton = try container.decodeIfPresent(Bool.self, forKey: .enableLoadingTextForSpaceButton)
    self.loadingTextForSpaceButton = try container.decodeIfPresent(String.self, forKey: .loadingTextForSpaceButton)
    self.labelTextForSpaceButton = try container.decodeIfPresent(String.self, forKey: .labelTextForSpaceButton)
    self.showCurrentInputSchemaNameForSpaceButton = try container.decodeIfPresent(Bool.self, forKey: .showCurrentInputSchemaNameForSpaceButton)
    self.showCurrentInputSchemaNameOnLoadingTextForSpaceButton = try container.decodeIfPresent(Bool.self, forKey: .showCurrentInputSchemaNameOnLoadingTextForSpaceButton)
    self.showUppercasedCharacterOnChineseKeyboard = try container.decodeIfPresent(Bool.self, forKey: .showUppercasedCharacterOnChineseKeyboard)
    self.enableButtonUnderBorder = try container.decodeIfPresent(Bool.self, forKey: .enableButtonUnderBorder)
  }

  enum CodingKeys: CodingKey {
    case useKeyboardType
    case disableSwipeLabel
    case upSwipeOnLeft
    case swipeLabelUpAndDownLayout
    case swipeLabelUpAndDownIrregularLayout
    case displayButtonBubbles
    case enableKeySounds
    case enableHapticFeedback
    case hapticFeedbackIntensity
    case displaySemicolonButton
    case displayClassifySymbolButton
    case displaySpaceLeftButton
    case spaceLeftButtonProcessByRIME
    case keyValueOfSpaceLeftButton
    case displaySpaceRightButton
    case spaceRightButtonProcessByRIME
    case keyValueOfSpaceRightButton
    case displayChineseEnglishSwitchButton
    case chineseEnglishSwitchButtonIsOnLeftOfSpaceButton
    case enableNineGridOfNumericKeyboard
    case numberKeyProcessByRimeOnNineGridOfNumericKeyboard
    case leftSymbolProcessByRimeOnNineGridOfNumericKeyboard
    case rightSymbolProcessByRimeOnNineGridOfNumericKeyboard
    case symbolsOfGridOfNumericKeyboard
    case lockShiftState
    case enableEmbeddedInputMode
    case widthOfOneHandedKeyboard
    case symbolsOfCursorBack
    case symbolsOfReturnToMainKeyboard
    case symbolsOfChineseNineGridKeyboard
    case pairsOfSymbols
    case enableSymbolKeyboard
    case lockForSymbolKeyboard
    case enableColorSchema
    case useColorSchemaForLight
    case useColorSchemaForDark
    case colorSchemas
    case enableLoadingTextForSpaceButton
    case loadingTextForSpaceButton
    case labelTextForSpaceButton
    case showCurrentInputSchemaNameForSpaceButton
    case showCurrentInputSchemaNameOnLoadingTextForSpaceButton
    case showUppercasedCharacterOnChineseKeyboard
    case enableButtonUnderBorder
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.useKeyboardType, forKey: .useKeyboardType)
    try container.encodeIfPresent(self.disableSwipeLabel, forKey: .disableSwipeLabel)
    try container.encodeIfPresent(self.upSwipeOnLeft, forKey: .upSwipeOnLeft)
    try container.encodeIfPresent(self.swipeLabelUpAndDownLayout, forKey: .swipeLabelUpAndDownLayout)
    try container.encodeIfPresent(self.swipeLabelUpAndDownIrregularLayout, forKey: .swipeLabelUpAndDownIrregularLayout)
    try container.encodeIfPresent(self.displayButtonBubbles, forKey: .displayButtonBubbles)
    try container.encodeIfPresent(self.enableKeySounds, forKey: .enableKeySounds)
    try container.encodeIfPresent(self.enableHapticFeedback, forKey: .enableHapticFeedback)
    try container.encodeIfPresent(self.hapticFeedbackIntensity, forKey: .hapticFeedbackIntensity)
    try container.encodeIfPresent(self.displaySemicolonButton, forKey: .displaySemicolonButton)
    try container.encodeIfPresent(self.displayClassifySymbolButton, forKey: .displayClassifySymbolButton)
    try container.encodeIfPresent(self.displaySpaceLeftButton, forKey: .displaySpaceLeftButton)
    try container.encodeIfPresent(self.spaceLeftButtonProcessByRIME, forKey: .spaceLeftButtonProcessByRIME)
    try container.encodeIfPresent(self.keyValueOfSpaceLeftButton, forKey: .keyValueOfSpaceLeftButton)
    try container.encodeIfPresent(self.displaySpaceRightButton, forKey: .displaySpaceRightButton)
    try container.encodeIfPresent(self.spaceRightButtonProcessByRIME, forKey: .spaceRightButtonProcessByRIME)
    try container.encodeIfPresent(self.keyValueOfSpaceRightButton, forKey: .keyValueOfSpaceRightButton)
    try container.encodeIfPresent(self.displayChineseEnglishSwitchButton, forKey: .displayChineseEnglishSwitchButton)
    try container.encodeIfPresent(self.chineseEnglishSwitchButtonIsOnLeftOfSpaceButton, forKey: .chineseEnglishSwitchButtonIsOnLeftOfSpaceButton)
    try container.encodeIfPresent(self.enableNineGridOfNumericKeyboard, forKey: .enableNineGridOfNumericKeyboard)
    try container.encodeIfPresent(self.numberKeyProcessByRimeOnNineGridOfNumericKeyboard, forKey: .numberKeyProcessByRimeOnNineGridOfNumericKeyboard)
    try container.encodeIfPresent(self.leftSymbolProcessByRimeOnNineGridOfNumericKeyboard, forKey: .leftSymbolProcessByRimeOnNineGridOfNumericKeyboard)
    try container.encodeIfPresent(self.rightSymbolProcessByRimeOnNineGridOfNumericKeyboard, forKey: .rightSymbolProcessByRimeOnNineGridOfNumericKeyboard)
    try container.encodeIfPresent(self.symbolsOfGridOfNumericKeyboard, forKey: .symbolsOfGridOfNumericKeyboard)
    try container.encodeIfPresent(self.lockShiftState, forKey: .lockShiftState)
    try container.encodeIfPresent(self.enableEmbeddedInputMode, forKey: .enableEmbeddedInputMode)
    try container.encodeIfPresent(self.widthOfOneHandedKeyboard, forKey: .widthOfOneHandedKeyboard)
    try container.encodeIfPresent(self.symbolsOfCursorBack, forKey: .symbolsOfCursorBack)
    try container.encodeIfPresent(self.symbolsOfReturnToMainKeyboard, forKey: .symbolsOfReturnToMainKeyboard)
    try container.encodeIfPresent(self.symbolsOfChineseNineGridKeyboard, forKey: .symbolsOfChineseNineGridKeyboard)
    try container.encodeIfPresent(self.pairsOfSymbols, forKey: .pairsOfSymbols)
    try container.encodeIfPresent(self.enableSymbolKeyboard, forKey: .enableSymbolKeyboard)
    try container.encodeIfPresent(self.lockForSymbolKeyboard, forKey: .lockForSymbolKeyboard)
    try container.encodeIfPresent(self.enableColorSchema, forKey: .enableColorSchema)
    try container.encodeIfPresent(self.useColorSchemaForLight, forKey: .useColorSchemaForLight)
    try container.encodeIfPresent(self.useColorSchemaForDark, forKey: .useColorSchemaForDark)
    try container.encodeIfPresent(self.colorSchemas, forKey: .colorSchemas)
    try container.encodeIfPresent(self.enableLoadingTextForSpaceButton, forKey: .enableLoadingTextForSpaceButton)
    try container.encodeIfPresent(self.loadingTextForSpaceButton, forKey: .loadingTextForSpaceButton)
    try container.encodeIfPresent(self.labelTextForSpaceButton, forKey: .labelTextForSpaceButton)
    try container.encodeIfPresent(self.showCurrentInputSchemaNameForSpaceButton, forKey: .showCurrentInputSchemaNameForSpaceButton)
    try container.encodeIfPresent(self.showCurrentInputSchemaNameOnLoadingTextForSpaceButton, forKey: .showCurrentInputSchemaNameOnLoadingTextForSpaceButton)
    try container.encodeIfPresent(self.showUppercasedCharacterOnChineseKeyboard, forKey: .showUppercasedCharacterOnChineseKeyboard)
    try container.encodeIfPresent(self.enableButtonUnderBorder, forKey: .enableButtonUnderBorder)
  }
}
