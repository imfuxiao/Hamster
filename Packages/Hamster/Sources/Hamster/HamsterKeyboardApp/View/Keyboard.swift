//
//  SystemKeyboardView.swift
//  HamsterKeyboard
//
//  Created by morse on 10/1/2023.
//

import KeyboardKit
import Plist
import SwiftUI

struct AlphabetKeyboard: View {
  var skinExtend: [String: String] = [:]
  var layoutProvider: KeyboardLayoutProvider
  var appearance: KeyboardAppearance
  var actionHandler: KeyboardActionHandler

  @EnvironmentObject
  private var context: KeyboardContext

  @EnvironmentObject
  private var actionCalloutContext: ActionCalloutContext

  @EnvironmentObject
  private var inputCalloutContext: InputCalloutContext

  init(list: Plist) {
    if let dict = list.dict {
      for (key, value) in dict {
        if let value = value as? String {
          skinExtend[(key as! String).lowercased()] = value
        }
      }
    }
    let controller = KeyboardInputViewController.shared
    layoutProvider = controller.keyboardLayoutProvider
    appearance = controller.keyboardAppearance
    actionHandler = controller.keyboardActionHandler
  }

  @ViewBuilder
  func buttonContent(item: KeyboardLayoutItem) -> some View {
    HamsterKeyboardActionButtonContent(
      buttonExtendCharacter: skinExtend,
      action: item.action,
      appearance: appearance,
      context: context
    )
  }

  var body: some View {
    SystemKeyboard(
      layout: layoutProvider.keyboardLayout(for: context),
      appearance: appearance,
      actionHandler: actionHandler,
      keyboardContext: context,
      actionCalloutContext: actionCalloutContext,
      inputCalloutContext: inputCalloutContext,
      width: width,
      buttonView: { layoutItem, keyboardWidth, inputWidth in
        StandardSystemKeyboardButtonView(
          content: buttonContent(item: layoutItem),
          item: layoutItem,
          context: context,
          keyboardWidth: keyboardWidth,
          inputWidth: inputWidth,
          appearance: appearance,
          actionHandler: actionHandler
        )
      }
    )
  }

  var width: CGFloat {
    print(context.isPortrait)
    print(standardKeyboardWidth)
    // TODO: 横向的全面屏需要减去左右两边的听写键和键盘切换键
    return !context.isPortrait && context.hasDictationKey ? standardKeyboardWidth - 150 : standardKeyboardWidth
  }

  var standardKeyboardWidth: CGFloat {
    KeyboardInputViewController.shared.view.frame.width
  }
}
