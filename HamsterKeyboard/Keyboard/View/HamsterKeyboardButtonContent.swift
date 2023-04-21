//
//  HamsterKeyboardActionButtonContent.swift
//  HamsterKeyboard
//
//  Created by morse on 11/1/2023.
//

import KeyboardKit
import SwiftUI

@available(iOS 14, *)
struct HamsterKeyboardActionButtonContent: View {
  /**
   Create a system keyboard button content view.

   - Parameters:
   - action: The action for which to generate content.
   - appearance: The appearance to apply to the content.
   - context: The context to use when resolving content.
   */
  public init(
    action: KeyboardAction,
    appearance: KeyboardAppearance,
    keyboardContext: KeyboardContext,
    appSettings: HamsterAppSettings
  ) {
    self.action = action
    self.appearance = appearance
    self.keyboardContext = keyboardContext
    self.appSettings = appSettings

    let translateFunctionText = { (name: String) -> String in
      if name.hasPrefix("#"), let slidFunction = FunctionalInstructions(rawValue: name) {
        return slidFunction.text
      }
      return name
    }

    var buttonExtendCharacter: [String: String] = [:]
    for (fullKey, fullValue) in appSettings.keyboardUpAndDownSlideSymbol {
      var key = fullKey
      let value = translateFunctionText(fullValue)
      let suffix = String(key.removeLast())

      // 上划
      if suffix == KeyboardConstant.Character.SlideUp {
        if let dictValue = buttonExtendCharacter[key] {
          buttonExtendCharacter[key] = "\(value) \(dictValue)"
        } else {
          buttonExtendCharacter[key] = value
        }
        continue
      }

      // 下划
      if suffix == KeyboardConstant.Character.SlideDown {
        if let dictValue = buttonExtendCharacter[key] {
          buttonExtendCharacter[key] = "\(dictValue) \(value)"
        } else {
          buttonExtendCharacter[key] = value
        }
      }
    }
    self.buttonExtendCharacter = buttonExtendCharacter
  }

  private let keyboardContext: KeyboardContext
  private let action: KeyboardAction
  private let appearance: KeyboardAppearance
  private let appSettings: HamsterAppSettings
  private let buttonExtendCharacter: [String: String]
  @State var spaceText: String = ""

  @EnvironmentObject var rimeEngine: RimeEngine

  public var body: some View {
    bodyContent
//      .padding(3)
      .contentShape(Rectangle())
  }
}

private extension HamsterKeyboardActionButtonContent {
  @ViewBuilder
  var bodyContent: some View {
    #if os(iOS) || os(tvOS)
      if action == .nextKeyboard {
        NextKeyboardButton { bodyView }
      } else {
        bodyView
      }
    #else
      bodyView
    #endif
  }

  @ViewBuilder
  var bodyView: some View {
    if action == .space {
      spaceView
    } else if let image = appearance.buttonImage(for: action) {
      image
        .scaleEffect(appearance.buttonImageScaleFactor(for: action))
    } else if let text = appearance.buttonText(for: action) {
      textView(for: text)
    } else {
      Text("")
    }
  }

  @ViewBuilder
  var spaceView: some View {
//    if #available(iOS 16, *) {
//      Image(systemName: "space")
//    } else {
//      Text(spaceText)
//    }
    if rimeEngine.asciiMode {
      Text("西文")
    } else {
      Text("中文")
    }
  }

  func textView(for text: String) -> some View {
    HamsterKeyboardButtonText(
      buttonExtendCharacter: buttonExtendCharacter,
      text: text,
      isInputAction: action.isInputAction || {
        switch action {
        case .custom:
          return true
        default:
          return false
        }
      }()
    )
    .minimumScaleFactor(0.8)
  }
}

// private extension HamsterKeyboardActionButtonContent {
//  var spaceText: String {
//    appearance.buttonText(for: action) ?? ""
//  }
// }
