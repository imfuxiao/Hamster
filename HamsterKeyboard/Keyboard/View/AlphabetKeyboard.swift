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

  @ObservedObject
  private var appSettings: HamsterAppSettings

  @ObservedObject
  private var rimeEngine: RimeEngine
  private var appearance: KeyboardAppearance
  private var actionHandler: KeyboardActionHandler
  private var keyboardCalloutContext: KeyboardCalloutContext
  private var keyboardContext: KeyboardContext
  private var autocompleteContext: AutocompleteContext
  private var keyboardLayout: KeyboardLayout
  private var candidateBarHeight: CGFloat
  private let keyboardWidth: CGFloat
  private let style: AutocompleteToolbarStyle
  private let buttonExtendCharacter: [String: String]
  @Environment(\.openURL) var openURL

  init(
    keyboardInputViewController ivc: HamsterKeyboardViewController,
    candidateBarHeight: CGFloat,
    buttonExtendCharacter: [String: String]
  ) {
    Logger.shared.log.debug("AlphabetKeyboard init")
    weak var keyboardViewController = ivc
    self.ivc = keyboardViewController
    self.appSettings = ivc.appSettings
    self.rimeEngine = ivc.rimeEngine
    self.appearance = ivc.keyboardAppearance
    self.actionHandler = ivc.keyboardActionHandler
    self.keyboardCalloutContext = ivc.calloutContext
    self.keyboardContext = ivc.keyboardContext
    self.autocompleteContext = ivc.autocompleteContext
    self.keyboardLayout = ivc.keyboardLayoutProvider.keyboardLayout(for: ivc.keyboardContext)
    self.candidateBarHeight = candidateBarHeight
    self.keyboardWidth = ivc.view.frame.width
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
    self.buttonExtendCharacter = buttonExtendCharacter
  }

  var hamsterColor: ColorSchema {
    rimeEngine.currentColorSchema
  }

  var backgroundColor: Color {
    return hamsterColor.backColor.bgrColor ?? Color.standardKeyboardBackground
  }

  // 是否显示候选栏按钮
  var showCandidateBarArrowButton: Bool {
    appSettings.showKeyboardDismissButton || !rimeEngine.suggestions.isEmpty
  }

  // 每个按键的显示内容
  func hamsterButtonContent(item: KeyboardLayoutItem) -> some View {
    return HamsterKeyboardActionButtonContent(
      action: item.action,
      appearance: appearance,
      keyboardContext: keyboardContext,
      appSettings: appSettings,
      buttonExtendCharacter: buttonExtendCharacter
    )
  }

  @ViewBuilder
  var keyboard: some View {
    SystemKeyboard(
      layout: self.keyboardLayout,
      appearance: self.appearance,
      actionHandler: self.actionHandler,
      autocompleteContext: self.autocompleteContext,
      autocompleteToolbar: .none,
      autocompleteToolbarAction: { _ in },
      keyboardContext: self.keyboardContext,
      calloutContext: self.keyboardCalloutContext,
      width: self.keyboardWidth,
      buttonContent: self.hamsterButtonContent
    )
  }

  // 候选栏
  var candidateBarView: some View {
    HStack(spacing: 0) {
      // TODO: 主菜单功能暂未实现
      // Image(systemName: "house.circle.fill")
      Spacer()

      CandidateBarArrowButton(
        size: candidateBarHeight,
        hamsterColor: hamsterColor,
        imageName: appSettings.candidateBarArrowButtonImageName,
        showDivider: appSettings.showDivider,
        action: { [weak ivc] in
          if rimeEngine.suggestions.isEmpty {
            ivc?.dismissKeyboard()
            return
          }
          DispatchQueue.main.async {
            appSettings.keyboardStatus = appSettings.keyboardStatus == .normal ? .keyboardAreaToExpandCandidates : .normal
          }
        }
      )
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
      .frame(height: candidateBarHeight)
      .padding(.top, 5)

      // 键盘
      keyboard
    }
    .background(appSettings.enableRimeColorSchema ? backgroundColor : .clear)
  }
}
