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
  
  /// 上划显示在左侧
  public var upSwipeOnLeft: Bool?

  /// 划动上下布局 or 左右布局
  public var swipeLabelUpAndDownLayout: Bool?

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
  
  /// 空格左边按键对应的键值
  public var keyValueOfSpaceLeftButton: String?
  
  /// 显示空格右边按键
  public var displaySpaceRightButton: Bool?
  
  /// 空格右边按键对应的键值
  public var keyValueOfSpaceRightButton: String?
  
  /// 显示中英切换按键
  public var displayChineseEnglishSwitchButton: Bool?
  
  /// 中英切换按键在空格左侧
  /// true 位于左侧 false 位于右侧
  public var chineseEnglishSwitchButtonIsOnLeftOfSpaceButton: Bool?
  
  /// 启用九宫格数字键盘
  public var enableNineGridOfNumericKeyboard: Bool?
  
  /// 九宫格数字键盘: 输入后直接上屏
  public var enterDirectlyOnScreenByNineGridOfNumericKeyboard: Bool?
  
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
  
  /// 使用中颜色方案
  public var useColorSchema: String?
  
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
}
