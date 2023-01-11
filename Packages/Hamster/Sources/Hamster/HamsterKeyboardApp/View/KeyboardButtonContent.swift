//
//  HamsterKeyboardActionButtonContent.swift
//  HamsterKeyboard
//
//  Created by morse on 11/1/2023.
//

import KeyboardKit
import SwiftUI

struct HamsterKeyboardActionButtonContent: View {
  /**
   Create a system keyboard button content view.
   
   - Parameters:
   - action: The action for which to generate content.
   - appearance: The appearance to apply to the content.
   - context: The context to use when resolving content.
   */
  public init(
    buttonExtendCharacter: [String: String],
    action: KeyboardAction,
    appearance: KeyboardAppearance,
    context: KeyboardContext
  ) {
    self.buttonExtendCharacter = buttonExtendCharacter
    self.action = action
    self.appearance = appearance
    self.context = context
  }
  
  var buttonExtendCharacter: [String: String]
  private let action: KeyboardAction
  private let appearance: KeyboardAppearance
  private let context: KeyboardContext
  
  public var body: some View {
    if action == .nextKeyboard {
#if os(iOS) || os(tvOS)
      NextKeyboardButton()
#else
      Image.keyboardGlobe
#endif
    } else if action == .space {
      spaceView
    } else if let image = buttonImage {
      image
    } else if let text = buttonText {
      textView(for: text)
    } else {
      Text("")
    }
  }
}

private extension HamsterKeyboardActionButtonContent {
  var buttonImage: Image? {
    appearance.buttonImage(for: action)
  }
  
  var buttonText: String? {
    appearance.buttonText(for: action)
  }
  
  var spaceView: some View {
    SystemKeyboardSpaceButtonContent(
      localeText: localeText,
      spaceText: spaceText
    )
  }
  
  func textView(for text: String) -> some View {
    HamsterKeyboardButtonText(
      buttonExtendCharacter: buttonExtendCharacter,
      text: text,
      action: action
    )
    .padding(3)
    .minimumScaleFactor(0.6)
  }
}

private extension HamsterKeyboardActionButtonContent {
  var localeName: String {
    context.locale.localizedLanguageName ?? ""
  }
  
  var localeText: String {
    shouldShowLocaleName ? localeName : spaceText
  }
  
  var shouldShowLocaleName: Bool {
    context.locales.count > 1
  }
  
  var spaceText: String {
    appearance.buttonText(for: action) ?? ""
  }
}

#if os(iOS) || os(tvOS)
struct HamsterKeyboardActionButtonContent_Previews: PreviewProvider {
  static let multiLocaleContext: KeyboardContext = {
    var context = KeyboardContext(controller: .shared)
    context.locales = [
      KeyboardLocale.english.locale,
      KeyboardLocale.swedish.locale,
    ]
    return context
  }()
  
  static func preview(
    for action: KeyboardAction,
    multiLocale: Bool = false
  ) -> some View {
    SystemKeyboardActionButtonContent(
      action: action,
      appearance: .preview,
      context: multiLocale ? multiLocaleContext : .preview
    )
  }
  
  static var previews: some View {
    HStack {
      preview(for: .backspace)
      preview(for: .space, multiLocale: false)
      preview(for: .space, multiLocale: true)
      preview(for: .character("PascalCased"))
      preview(for: .character("lowercased"))
    }
  }
}
#endif
