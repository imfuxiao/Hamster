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
        bodyContent
            .padding(3)
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
            image.scaleEffect(appearance.buttonImageScaleFactor(for: action))
        } else if let text = appearance.buttonText(for: action) {
            textView(for: text)
        } else {
            Text("")
        }
    }
    
    var spaceView: some View {
        SystemKeyboardSpaceContent(
            localeText: shouldShowLocaleName ? localeName : spaceText,
            spaceView: SystemKeyboardButtonText(
                text: spaceText,
                action: .space
            )
        )
    }
  
    func textView(for text: String) -> some View {
        HamsterKeyboardButtonText(
            buttonExtendCharacter: buttonExtendCharacter,
            text: text,
            isInputAction: action.isInputAction,
            showExtendArea: context.keyboardType.isAlphabetic
        )
        .padding(3)
        .minimumScaleFactor(0.6)
    }
}

private extension HamsterKeyboardActionButtonContent {
    var localeName: String {
        context.locale.localizedLanguageName ?? ""
    }
  
    var shouldShowLocaleName: Bool {
        context.locales.count > 1
    }
  
    var spaceText: String {
        appearance.buttonText(for: action) ?? ""
    }
}
