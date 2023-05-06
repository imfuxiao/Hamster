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
  public init(
    buttonExtendCharacter: [String: [String]],
    text: String,
    action: KeyboardAction
  ) {
    self.init(
      buttonExtendCharacter: buttonExtendCharacter,
      text: text,
      isInputAction: action.isInputAction
    )
  }

  public init(
    buttonExtendCharacter: [String: [String]],
    text: String,
    isInputAction: Bool
  ) {
    self.buttonExtendCharacter = buttonExtendCharacter
    self.text = text
    self.isInputAction = isInputAction
  }

  var buttonExtendCharacter: [String: [String]]
  private let text: String
  private let isInputAction: Bool

  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var keyboardContext: KeyboardContext

  var characterExtendView: some View {
    let texts = buttonExtendCharacter[text.lowercased(), default: []]
    return HStack(alignment: .center, spacing: 0) {
      if !texts.isEmpty {
        Text(texts[0])
      }
      if texts.count > 1 {
        Spacer()
        Text(texts[1])
      }
    }
    .opacity(0.64)
    .font(.system(size: 7))
    .frame(minWidth: 0, maxWidth: .infinity)
    .frame(height: 10)
    .padding(.init(top: 2, leading: 1, bottom: 1, trailing: 1))
    .lineLimit(1)
    .minimumScaleFactor(0.5)
  }

  public var body: some View {
    let showExtendArea = showExtendArea
    ZStack(alignment: .center) {
      if showExtendArea {
        VStack(alignment: .center, spacing: 0) {
          characterExtendView

          Spacer()
        }
        .offset(y: -4)
      }
      Text(text)
        .lineLimit(1)
        .offset(y: useNegativeOffset ? -2 : 0)
        .scaleEffect(showExtendArea && isInputAction ? 0.85 : 1)
    }
  }
}

private extension HamsterKeyboardButtonText {
  // 使用负偏移
  var useNegativeOffset: Bool {
    isInputAction && text.isLowercased
  }

  // 是否显示按键扩展区域
  var showExtendArea: Bool {
    appSettings.enableKeyboardSwipeGestureSymbol
      && appSettings.showKeyExtensionArea
      && keyboardContext.keyboardType.isAlphabetic
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
