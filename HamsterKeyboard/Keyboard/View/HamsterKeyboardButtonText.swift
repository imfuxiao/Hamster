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
    self.init(
      buttonExtendCharacter: buttonExtendCharacter,
      text: text,
      isInputAction: action.isInputAction,
      showExtendArea: false
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
    self.init(
      buttonExtendCharacter: buttonExtendCharacter, text: text, isInputAction: isInputAction,
      showExtendArea: false
    )
  }

  public init(
    buttonExtendCharacter: [String: String],
    text: String,
    isInputAction: Bool,
    showExtendArea: Bool
  ) {
    self.buttonExtendCharacter = buttonExtendCharacter
    self.text = text
    self.isInputAction = isInputAction
    self.showExtentArea = showExtendArea
  }

  var buttonExtendCharacter: [String: String]
  private let text: String
  private let isInputAction: Bool
  private let showExtentArea: Bool

  var characterExtendView: some View {
    let action = buttonExtendCharacter[text.lowercased(), default: ""]
    let texts = action.split(separator: " ").filter { $0.count > 0 }.map { String($0) }
    let count = texts.count
    return VStack(alignment: .leading, spacing: 0) {
      if count >= 2 {
        HStack(alignment: .center, spacing: 0) {
          Text(texts[0])
          Spacer()
          Text(texts[1])
        }
        .font(.system(size: 9))
        .lineLimit(1)
//        .minimumScaleFactor(0.5)
      } else if count == 1 {
        Text(texts[0])
          .font(.system(size: 9))
      } else {
        Text(" ")
      }
    }
  }

  public var body: some View {
    if !isInputAction {
      Text(text)
        .lineLimit(1)
        .offset(y: useNegativeOffset ? -2 : 0)
        .font(.system(size: 22))
    } else {
      VStack(spacing: 0) {
        if showExtentArea {
          characterExtendView
        }
        VStack(spacing: 0) {
          Text(text)
            .lineLimit(1)
            .offset(y: 1)
            .font(.system(size: 22))
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
