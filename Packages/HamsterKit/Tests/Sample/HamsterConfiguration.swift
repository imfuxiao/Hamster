//
//  File.swift
//
//
//  Created by morse on 2023/7/3.
//

import Foundation
@testable import HamsterModel

extension HamsterConfiguration {
  /// 用于测试的模拟数据
  static let preview = HamsterConfiguration(
    general: GeneralConfiguration(
      enableAppleCloud: true,
      regexOnCopyFile: ["^.text|.yaml$"]),
    toolbar: KeyboardToolbarConfiguration(
      enableToolbar: true,
      heightOfToolbar: 65,
      displayKeyboardDismissButton: true,
      heightOfCodingArea: 15,
      codingAreaFontSize: 20, candidateWordFontSize: 25, candidateCommentFontSize: 18,
      displayIndexOfCandidateWord: true),
    Keyboard: KeyboardConfiguration(
      displayButtonBubbles: true,
      enableKeySounds: true,
      enableHapticFeedback: true,
      hapticFeedbackIntensity: 3,
      displaySemicolonButton: true,
      displaySpaceLeftButton: true,
      keyValueOfSpaceLeftButton: ",",
      displaySpaceRightButton: true,
      keyValueOfSpaceRightButton: ".",
      displayChineseEnglishSwitchButton: true,
      chineseEnglishSwitchButtonIsOnLeftOfSpaceButton: true,
      enableNineGridOfNumericKeyboard: true,
      enterDirectlyOnScreenByNineGridOfNumericKeyboard: true,
      symbolsOfGridOfNumericKeyboard: ["+", "-", "*", "/"],
      autoLowerCaseOfKeyboard: true,
      enableEmbeddedInputMode: true,
      widthOfOneHandedKeyboard: 80,
      symbolsOfCursorBack: ["\"\"", "“”", "[]"],
      symbolsOfReturnToMainKeyboard: [",", ".", "!"],
      pairsOfSymbols: ["[]", "()", "“”"],
      enableSymbolKeyboard: true,
      lockForSymbolKeyboard: true,
      enableColorSchema: true,
      useColorSchema: "solarized_light",
      colorSchemas: [
        "native": .init(name: "系统配色"),
        "solarized_light": .init(
          name: "曬經・日／Solarized Light",
          author: "雪齋 <lyc20041@gmail.com>",
          backColor: "0xF0E5F6FB",
          borderColor: "0xEDFFFF",
          hilitedTextColor: "0x2C8BAE",
          hilitedBackColor: "0x4C4022",
          hilitedCandidateTextColor: "0x3942CB",
          hilitedCandidateBackColor: "0xD7E8ED",
          hilitedCommentTextColor: "0x8144C2",
          candidateTextColor: "0x005947",
          commentTextColor: "0x595E00")
      ]),
    rime: .init(
      maximumNumberOfCandidateWords: 30,
      keyValueOfSwitchSimplifiedAndTraditional: "simplified",
      overrideDictFiles: true),
    swipe: .init(
      xAxleSwipeSensitivity: 20,
      yAxleSwipeSensitivity: 30,
      spaceSwipeSensitivity: 50))
}
