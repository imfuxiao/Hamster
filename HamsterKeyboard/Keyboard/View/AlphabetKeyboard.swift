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
    self.standardKeyboardWidth = ivc.view.frame.width
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

  var body: some View {
    VStack(spacing: 0) {
      if keyboardContext.keyboardType != .emojis {
        VStack(spacing: 0) {
          if rimeEngine.userInputKey.isEmpty {
            HStack {
              // TODO: 主菜单功能暂未实现
              //                Image(systemName: "house.circle.fill")
              //                  .font(.system(size: 25))
              //                  .foregroundColor(Color.gray)
              //                  .frame(width: 25, height: 25)
              //                  .padding(.leading, 15)
              //                  .onTapGesture {}

              Spacer()

              if appSettings.showKeyboardDismissButton {
                Image(systemName: "chevron.down.circle.fill")
                  .iconStyle()
                  .padding(.trailing, 15)
                  .onTapGesture { [weak ivc] in
                    guard let ivc = ivc else { return }
                    ivc.dismissKeyboard()
                  }
              }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: appSettings.enableInputEmbeddedMode ? 40 : 50, maxHeight: .infinity)
          } else {
            HamsterAutocompleteToolbar(ivc: ivc)
          }
        }
      }
      keyboard
    }
    .background(backgroundColor)
  }

  var backgroundColor: Color {
    return rimeEngine.currentColorSchema.backColor ?? .clearInteractable
  }

//  var width: CGFloat {
//    // TODO: 横向的全面屏需要减去左右两边的听写键和键盘切换键
//    return !keyboardContext.isPortrait && keyboardContext.hasDictationKey
//      ? standardKeyboardWidth - 150 : standardKeyboardWidth
//  }
}
