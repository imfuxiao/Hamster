//
//  KeyboardButtonText.swift
//  HamsterKeyboard
//
//  Created by morse on 11/1/2023.
//

import KeyboardKit
import SwiftUI

@available(iOS 14, *)
struct HamsterKeyboardButtonText: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var keyboardContext: KeyboardContext

  var buttonExtendCharacter: [String: String]
  private let text: String
  private let isInputAction: Bool

  public init(
    buttonExtendCharacter: [String: String],
    text: String,
    action: KeyboardAction
  ) {
    self.init(
      buttonExtendCharacter: buttonExtendCharacter,
      text: text,
      isInputAction: action.isInputAction
    )
  }

  /**
   Create a system keyboard button text view.

   - Parameters:
   - text: The text to display.
   - isInputAction: Whether or not the action bound to the button is an input action.
   */
  public init(
    buttonExtendCharacter: [String: String],
    text: String,
    isInputAction: Bool
  ) {
    self.buttonExtendCharacter = buttonExtendCharacter
    self.text = text
    self.isInputAction = isInputAction
  }

  // 是否显示按键扩展区域
  var showExtendArea: Bool {
    appSettings.enableKeyboardUpAndDownSlideSymbol
      && appSettings.showKeyboardUpAndDownSlideSymbol
      && keyboardContext.keyboardType.isAlphabetic
  }

  var characterExtendView: some View {
    let action = buttonExtendCharacter[text.lowercased(), default: ""]
    let texts = action.split(separator: " ").filter { $0.count > 0 }.map { String($0) }
    return VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .center, spacing: 0) {
        if !texts.isEmpty {
          Text(texts[0])
        }
        if texts.count > 1 {
          Spacer()
          Text(texts[1])
        }
      }
      .font(.system(size: 10))
      .lineLimit(1)
      .minimumScaleFactor(0.5)
      .padding(.all, 2)
    }
  }

  public var body: some View {
    if !isInputAction {
      VStack(alignment: .center, spacing: 0) {
        Text(text)
          .lineLimit(1)
//          .offset(y: useNegativeOffset ? -2 : 0)
      }
    } else {
      VStack(spacing: 0) {
        if showExtendArea {
          characterExtendView
        }
        VStack(alignment: .center, spacing: 0) {
          Text(text)
            .lineLimit(1)
            // 纯字母模式，位置向上偏移
            .offset(y: showExtendArea ? -3 : 0)
        }
      }
    }
  }
}

private extension HamsterKeyboardButtonText {
  var useNegativeOffset: Bool {
    isInputAction && text.isLowercased
  }
}

struct HamsterKeyboardButtonText_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      SystemKeyboardButtonText(text: "PasCal", action: .space)
      SystemKeyboardButtonText(text: "UPPER", action: .space)
      SystemKeyboardButtonText(text: "lower", action: .space)
      SystemKeyboardButtonText(text: "lower", action: .space)
      SystemKeyboardButtonText(text: "non-input", action: .backspace)
    }
  }
}
