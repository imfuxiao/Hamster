//
//  AlphabetKeyboard.swift
//  HamsterKeyboard
//
//  Created by morse on 10/1/2023.
//

import Combine
import KeyboardKit
import SwiftUI

@available(iOS 14, *)
struct AlphabetKeyboard: View {
  weak var ivc: HamsterKeyboardViewController?
  let appearance: KeyboardAppearance
  let actionHandler: KeyboardActionHandler

  let style: AutocompleteToolbarStyle

  // MARK: 依赖注入

  @EnvironmentObject
  private var keyboardCalloutContext: KeyboardCalloutContext

  @EnvironmentObject
  private var keyboardContext: KeyboardContext

  @EnvironmentObject
  private var rimeEngine: RimeEngine

  @EnvironmentObject
  private var appSettings: HamsterAppSettings

  @Environment(\.openURL) var openURL

  init(keyboardInputViewController ivc: HamsterKeyboardViewController) {
    Logger.shared.log.debug("AlphabetKeyboard init")
    weak var keyboardViewController = ivc
    self.ivc = keyboardViewController
    self.appearance = ivc.keyboardAppearance
    self.actionHandler = ivc.keyboardActionHandler

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
  }

  var hamsterColor: ColorSchema {
    rimeEngine.currentColorSchema
  }

  var backgroundColor: Color {
    return hamsterColor.backColor ?? Color.standardKeyboardBackground
  }

  // 是否显示候选栏按钮
  var showCandidateBarArrowButton: Bool {
    appSettings.showKeyboardDismissButton || !rimeEngine.suggestions.isEmpty
  }

  @ViewBuilder
  var keyboard: some View {
    if let ivc = ivc {
      SystemKeyboard(
        controller: ivc,
        autocompleteToolbarMode: .none,
        buttonView: { layoutItem, keyboardWidth, inputWidth in
          SystemKeyboardButtonRowItem(
            content: HamsterKeyboardActionButtonContent(
              action: layoutItem.action,
              appearance: appearance,
              keyboardContext: keyboardContext,
              appSettings: appSettings
            ),
            item: layoutItem,
            actionHandler: actionHandler,
            keyboardContext: keyboardContext,
            calloutContext: keyboardCalloutContext,
            keyboardWidth: keyboardWidth,
            inputWidth: inputWidth,
            appearance: appearance
          )
        }
      )
    }
  }

  // 候选栏
  var candidateBarView: some View {
    HStack(spacing: 0) {
      // TODO: 主菜单功能暂未实现
      // Image(systemName: "house.circle.fill")
      Spacer()

      CandidateBarArrowButton(hamsterColor: hamsterColor, action: { [weak ivc] in
        if rimeEngine.suggestions.isEmpty {
          ivc?.dismissKeyboard()
          return
        }
        appSettings.keyboardStatus = appSettings.keyboardStatus == .normal ? .keyboardAreaToExpandCandidates : .normal
      })
      .opacity(showCandidateBarArrowButton ? 1 : 0)
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      // 候选区域
      HStack(spacing: 0) {
        ZStack(alignment: .topLeading) {
          // 横向滑动条: 候选文字
          HamsterAutocompleteToolbar(ivc: ivc, style: style)

          // 候选栏箭头按钮
          candidateBarView
        }
      }
      .frame(height: appSettings.enableInputEmbeddedMode ? 40 : 50)
      .padding(.top, 5)

      // 键盘
      keyboard
    }
    .background(appSettings.enableRimeColorSchema ? backgroundColor : .clear)
  }
}
