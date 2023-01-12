//
//  KeyboardButtonText.swift
//  HamsterKeyboard
//
//  Created by morse on 11/1/2023.
//

import KeyboardKit
import SwiftUI

struct HamsterKeyboardButtonText: View {
  /**
   Create a system keyboard button text view.

   - Parameters:
   - text: The text to display.
   - action: The action bound to the button.
   */
  public init(
    buttonExtendCharacter: [String: String],
    text: String,
    action: KeyboardAction
  ) {
    self.buttonExtendCharacter = buttonExtendCharacter
    self.text = text
    self.isInputAction = action.isInputAction
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

  var buttonExtendCharacter: [String: String]
  private let text: String
  private let isInputAction: Bool

  var characterExtendView: some View {
    let action = buttonExtendCharacter[text.lowercased(), default: ""]
    let texts = action.split(separator: " ").filter { $0.count > 0 }.map { String($0) }
    let count = texts.count
    return VStack(alignment: .leading, spacing: 0) {
      if texts.count != 0 {
        HStack(spacing: 0) {
          // MARK: 键盘扩展最多显示2个扩展字符

          ForEach(0 ..< 2) {
            if $0 < count {
              Text(texts[$0]).font(.system(size: 8))
            }
            if $0 < 1 {
              Spacer()
            }
          }
        }
      } else {
        Text(" ")
          .font(.system(size: 8))
      }
    }
  }

  public var body: some View {
    VStack(spacing: 0) {
      characterExtendView
      VStack(spacing: 0) {
        Text(text)
          .lineLimit(1)
          .offset(y: useNegativeOffset ? -2 : 0)
          .font(.system(size: 18))
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
