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
  let standardKeyboardWidth: CGFloat

  let style: AutocompleteToolbarStyle

  @Binding var keyboardStatus: HamsterKeyboardStatus

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

  init(keyboardInputViewController ivc: HamsterKeyboardViewController, keyboardStatus: Binding<HamsterKeyboardStatus>) {
    Logger.shared.log.debug("AlphabetKeyboard init")
    weak var keyboardViewController = ivc
    self.ivc = keyboardViewController
    self.appearance = ivc.keyboardAppearance
    self.actionHandler = ivc.keyboardActionHandler
    self.standardKeyboardWidth = ivc.view.frame.width

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

    self._keyboardStatus = keyboardStatus
  }

  var hamsterColor: ColorSchema {
    rimeEngine.currentColorSchema
  }

  var backgroundColor: Color {
    return hamsterColor.backColor ?? Color.standardKeyboardBackground
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
    } else {
      EmptyView()
    }
  }

  // 候选栏
  var candidateBarView: some View {
    HStack(spacing: 0) {
      // TODO: 主菜单功能暂未实现
      // Image(systemName: "house.circle.fill")
      Spacer()

      CandidateBarArrowButton(hamsterColor: hamsterColor, keyboardStatus: keyboardStatus, action: { [weak ivc] in
        if rimeEngine.suggestions.isEmpty {
          ivc?.dismissKeyboard()
          return
        }
        withAnimation(.easeInOut) {
          keyboardStatus = keyboardStatus == .normal ? .KeyboardAreaToExpandCandidates : .normal
        }
      })
    }
  }

  var body: some View {
    GeometryReader { _ in
      VStack(spacing: 0) {
        // 候选区域
        HStack(spacing: 0) {
          ZStack(alignment: .topLeading) {
            // 横向滑动条: 候选文字
            HamsterAutocompleteToolbar(ivc: ivc, style: style)
              .background(backgroundColor)

            // 候选栏箭头按钮
            candidateBarView
          }
        }
        .frame(height: 50)

        // 键盘
        keyboard
      }
      .background(backgroundColor)
    }
  }
}

/// 候选栏箭头按钮
struct CandidateBarArrowButton: View {
  var hamsterColor: ColorSchema
  var keyboardStatus: HamsterKeyboardStatus
  var action: () -> Void

  @EnvironmentObject
  var keyboardContext: KeyboardContext

  init(hamsterColor: ColorSchema, keyboardStatus: HamsterKeyboardStatus, action: @escaping () -> Void) {
    self.hamsterColor = hamsterColor
    self.keyboardStatus = keyboardStatus
    self.action = action
  }

  var imageName: String {
    if keyboardStatus == .normal {
      return "chevron.down"
    }
    if keyboardStatus == .KeyboardAreaToExpandCandidates {
      return "chevron.up"
    }
    return ""
  }

  var foregroundColor: Color {
    Color.standardButtonForeground(for: keyboardContext)
  }

  var backgroundColor: Color {
    .standardKeyboardBackground
  }

  var body: some View {
    // 控制栏V型按钮
    ZStack(alignment: .center) {
      VStack(alignment: .leading) {
        HStack {
          Divider()
            .frame(width: 1, height: 35)
            .overlay(hamsterColor.candidateTextColor ?? foregroundColor)

          Spacer()
        }
      }

      Image(systemName: imageName)
        .font(.system(size: 18))
        .foregroundColor(hamsterColor.candidateTextColor ?? foregroundColor)
        .iconStyle()
    }
    .frame(width: 50, height: 50)
    .background(hamsterColor.backColor ?? backgroundColor)
    .onTapGesture { action() }
  }
}
