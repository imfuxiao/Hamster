//
//  HamsterKeyboardActionButtonContent.swift
//  HamsterKeyboard
//
//  Created by morse on 11/1/2023.
//

import KeyboardKit
import SwiftUI

@available(iOS 14, *)
struct HamsterKeyboardButtonContent: View {
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
    keyboardContext: KeyboardContext
  ) {
    self.action = action
    self.appearance = appearance as! HamsterKeyboardAppearance
    self.keyboardContext = keyboardContext
  }
  
  private let keyboardContext: KeyboardContext
  private let action: KeyboardAction
  private let appearance: HamsterKeyboardAppearance
  
  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var rimeContext: RimeContext
  
  public var body: some View {
    bodyContent
      .padding(3)
      .contentShape(Rectangle())
  }
}

private extension HamsterKeyboardButtonContent {
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
      image.scaleEffect(appearance.buttonImageScaleFactor(for: action))
    } else if let text = appearance.buttonText(for: action) {
      textView(for: text)
    } else {
      Text("")
    }
  }
  
  @ViewBuilder
  var spaceView: some View {
    //    HamsterSystemKeyboardSpaceContent(
    //      localeText: localSpaceText,
    //      spaceView: localSpaceView
    //    )
    SystemKeyboardButtonText(
      text: keyboardContext.keyboardType.isNumberNineGrid ? "空格" : localSpaceText,
      action: .space
    )
    .minimumScaleFactor(0.5)
  }
  
  func textView(for text: String) -> some View {
    //    SystemKeyboardButtonText(
    //        text: text,
    //        action: action
    //    ).minimumScaleFactor(0.5)
    HamsterKeyboardButtonText(
      buttonExtendCharacter: appearance.buttonExtendCharacter,
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
    .minimumScaleFactor(0.5)
  }
}

private extension HamsterKeyboardButtonContent {
  var spaceText: String {
    KKL10n.hamsterText(forKey: "space", locale: keyboardContext.locale)
  }
  
  var localSpaceText: String {
    if rimeContext.asciiMode {
      return "EN"
    }
    return appSettings.rimeTotalSchemas.first {
      $0.schemaId == appSettings.rimeInputSchema
    }?.schemaName ?? ""
  }
  
  var localSpaceView: some View {
    if #available(iOS 16, *) {
      return Image(systemName: "space")
    }
    return Text(KKL10n.hamsterText(forKey: "space", locale: keyboardContext.locale))
  }
}

// private extension HamsterKeyboardActionButtonContent {
//  var spaceText: String {
//    appearance.buttonText(for: action) ?? ""
//  }
// }
