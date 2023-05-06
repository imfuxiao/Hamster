//
//  HamsterKeyboard.swift
//  HamsterKeyboard
//
//  Created by morse on 20/4/2023.
//

import KeyboardKit
import SwiftUI

/// 废弃代码
/// Hamster键盘
@available(iOS 14, *)
struct HamsterKeyboard: View {
  weak var ivc: HamsterKeyboardViewController?
  var style: AutocompleteToolbarStyle
  var keyboardLayout: KeyboardLayout
  var actionHandler: KeyboardActionHandler
  var candidateBarHeight: CGFloat
//  private let buttonExtendCharacter: [String: String]

  @ObservedObject
  private var rimeContext: RimeContext

  @ObservedObject
  private var appSettings: HamsterAppSettings

  // MARK: 自身状态变量

  // 键盘尺寸
  let hamsterKeyboardSize: CGSize

  // MARK: 依赖注入

  @EnvironmentObject
  private var keyboardCalloutContext: KeyboardCalloutContext

  @EnvironmentObject
  private var keyboardContext: KeyboardContext

  @Environment(\.openURL) var openURL

  init(keyboardInputViewController ivc: HamsterKeyboardViewController) {
    Logger.shared.log.debug("HamsterKeyboard init")
    weak var keyboardViewController = ivc
    self.ivc = keyboardViewController
    self.actionHandler = ivc.keyboardActionHandler
    self.rimeContext = ivc.rimeContext
    self.appSettings = ivc.appSettings
    self.style = AutocompleteToolbarStyle(
      item: AutocompleteToolbarItemStyle(
        titleFont: .system(
          size: CGFloat(ivc.appSettings.rimeCandidateTitleFontSize)
        ),
        titleColor: .primary,
        subtitleFont: .system(
          size: CGFloat(ivc.appSettings.rimeCandidateCommentFontSize)
        )
      ),
      autocompleteBackground: .init(cornerRadius: 5)
    )

    self.keyboardLayout = ivc.keyboardLayoutProvider.keyboardLayout(for: ivc.keyboardContext)
    self.candidateBarHeight = ivc.appSettings.candidateBarHeight

    // 计算键盘总高度
    let height = Double(keyboardLayout.itemRows.count)
      * keyboardLayout.idealItemHeight
      + keyboardLayout.idealItemInsets.top
      + keyboardLayout.idealItemInsets.bottom
      + candidateBarHeight

    Logger.shared.log.debug("keyboard idealItemHeight \(keyboardLayout.idealItemHeight)")
    Logger.shared.log.debug("keyboard idealItemInsets.top \(keyboardLayout.idealItemInsets.top)")
    Logger.shared.log.debug("keyboard idealItemInsets.bottom \(keyboardLayout.idealItemInsets.bottom)")
    Logger.shared.log.debug("keyboard total height \(height)")

    self.hamsterKeyboardSize = CGSize(width: 0, height: height)

    // 键盘扩展显示
//    self.buttonExtendCharacter = ivc.buttonExtendCharacter
  }

  var hamsterColor: ColorSchema {
    .init()
  }

  var backgroundColor: Color {
    return hamsterColor.backColor.bgrColor ?? Color.standardKeyboardBackground
  }

  // 全键盘展示候选字
  var expandCandidatesView: some View {
//    ExpandCandidatesView(style: style, actionHandler: actionHandler)
    EmptyView()
  }

//  // 输入方案切换视图
//  var switchInputSchemaView: some View {
//    SelectInputSchemaView(
//      hamsterKeyboardSize: hamsterKeyboardSize,
//      hamsterColor: hamsterColor,
//      schemas: appSettings.rimeTotalSchemas.filter { appSettings.rimeUserSelectSchema.contains($0) }
//    )
//  }

  var body: some View {
    ZStack {
      // 正常键盘状态
      if appSettings.keyboardStatus == .normal {
        AlphabetKeyboard(
          keyboardInputViewController: ivc ?? NextKeyboardController.shared as! HamsterKeyboardViewController
//          buttonExtendCharacter: buttonExtendCharacter
        )
        .frame(height: hamsterKeyboardSize.height)
      }

      // 全区域展示候选键盘
      if appSettings.keyboardStatus == .keyboardAreaToExpandCandidates {
        expandCandidatesView
          .padding(.top, 3)
          .padding(.leading, 2)
          .frame(height: hamsterKeyboardSize.height)
      }

      // 输入方案切换视图
//      if appSettings.keyboardStatus == .switchInputSchema {
//        switchInputSchemaView
//          .foregroundColor(hamsterColor.candidateTextColor.bgrColor ?? Color.standardButtonForeground(for: keyboardContext))
//          .frame(height: hamsterKeyboardSize.height)
//      }
    }
  }

  // 键盘大小连动
  struct KeyboardSizeGeometryPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
      value = nextValue()
    }

    typealias Value = CGSize
  }
}

