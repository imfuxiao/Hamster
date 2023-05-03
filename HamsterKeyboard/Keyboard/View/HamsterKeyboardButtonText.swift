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
    appSettings.enableKeyboardSwipeGestureSymbol
      && appSettings.showKeyExtensionArea
      && keyboardContext.keyboardType.isAlphabetic
  }

  var characterExtendView: some View {
    let action = buttonExtendCharacter[text.lowercased(), default: ""]
    let texts = action.split(separator: " ").filter { $0.count > 0 }.map { String($0) }
    return VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .center, spacing: 0) {
        if !texts.isEmpty {
          Text(texts[0])
                .opacity(0.64)
        }
        if texts.count > 1 {
          Spacer()
          Text(texts[1])
                .opacity(0.64)
        }
      }
      .font(.system(size: 9))
      .lineLimit(1)
      .frame(height: 10)
      .minimumScaleFactor(0.5)
      .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 4))
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
            .padding(extendTextInsets)
        }
        VStack(alignment: .center, spacing: 0) {
          Text(text)
            .lineLimit(1)
            // 纯字母模式，位置向上偏移
            .offset(y: keyTextOffsetY)
        }
      }
    }
  }
  
  var keyTextOffsetY: CGFloat {
    if showExtendArea {
      switch keyboardContext.deviceType {
      case .phone:
        return keyboardContext.isPortrait ? -3 : -8
      case .pad:
        return keyboardContext.isPortrait ? 0 : 2
      default: break
      }
    }
    return 0
  }
  
  var extendTextInsets: EdgeInsets {
    if !keyboardContext.isPortrait {
      if keyboardContext.deviceType == .phone {
        return .init(top: 8, leading: 4, bottom: 0, trailing: 4)
      } else if keyboardContext.deviceType == .pad {
        return .init(top: 0, leading: 4, bottom: 2, trailing: 4)
      }
    }
    return .init(top: 0, leading: 0, bottom: 0, trailing: 0)
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
