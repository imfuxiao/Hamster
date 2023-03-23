//
//  SystemKeyboardView.swift
//  HamsterKeyboard
//
//  Created by morse on 10/1/2023.
//

import Combine
import KeyboardKit
import Plist
import SwiftUI

struct AlphabetKeyboard: View {
  var layoutProvider: KeyboardLayoutProvider
  var appearance: KeyboardAppearance
  var actionHandler: KeyboardActionHandler
  var keyboardInputViewController: KeyboardInputViewController

  @EnvironmentObject
  private var keyboardContext: KeyboardContext

  @EnvironmentObject
  private var autocompleteContext: AutocompleteContext

  @EnvironmentObject
  private var keyboardCalloutContext: KeyboardCalloutContext

  @EnvironmentObject
  private var rimeEngine: RimeEngine

  @EnvironmentObject
  private var appSettings: HamsterAppSettings

  init(keyboardInputViewController ivc: HamsterKeyboardViewController) {
    self.keyboardInputViewController = ivc
    self.layoutProvider = ivc.keyboardLayoutProvider
    self.appearance = ivc.keyboardAppearance
    self.actionHandler = ivc.keyboardActionHandler
  }

  var keyboard: some View {
    SystemKeyboard(
      layout: layoutProvider.keyboardLayout(for: keyboardContext),
      appearance: appearance,
      actionHandler: actionHandler,
      autocompleteContext: autocompleteContext,
      autocompleteToolbar: .none,
      autocompleteToolbarAction: { _ in },
      keyboardContext: keyboardContext,
      calloutContext: keyboardCalloutContext,
      width: width,
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

  var body: some View {
    VStack(spacing: 0) {
      if keyboardContext.keyboardType != .emojis {
        HStack(spacing: 0) {
          ZStack(alignment: .leading) {
            HamsterAutocompleteToolbar()

            if rimeEngine.userInputKey.isEmpty {
              HStack {
                // 主菜单功能暂未实现
//                Image(systemName: "house.circle.fill")
//                  .font(.system(size: 25))
//                  .foregroundColor(Color.gray)
//                  .frame(width: 25, height: 25)
//                  .padding(.leading, 15)
//                  .onTapGesture {}

                Spacer()

                if appSettings.showKeyboardDismissButton {
                  Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color.gray)
                    .frame(width: 25, height: 25)
                    .padding(.trailing, 15)
                    .onTapGesture {
                      keyboardInputViewController.dismissKeyboard()
                    }
                }
              }
            }
          }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
      }
      keyboard
        .background(backgroudColor)
    }
  }

  var backgroudColor: Color {
    if appSettings.enableRimeColorSchema {
      if let colorSchema = rimeEngine.colorSchema().first(where: { $0.schemaName == appSettings.rimeColorSchema }) {
        return colorSchema.backColor.bgrColor ?? Color.clearInteractable
      }
    }
    return Color.clearInteractable
  }

  var width: CGFloat {
    // TODO: 横向的全面屏需要减去左右两边的听写键和键盘切换键
    return !keyboardContext.isPortrait && keyboardContext.hasDictationKey
      ? standardKeyboardWidth - 150 : standardKeyboardWidth
  }

  var standardKeyboardWidth: CGFloat {
    keyboardInputViewController.view.frame.width
  }
}
