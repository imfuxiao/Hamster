//
//  SystemKeyboardView.swift
//  HamsterKeyboard
//
//  Created by morse on 10/1/2023.
//

import Combine
import KeyboardKit
import Plist
import SwiftUI

struct AlphabetKeyboard: View {
    var layoutProvider: KeyboardLayoutProvider
    var appearance: KeyboardAppearance
    var actionHandler: KeyboardActionHandler
    var keyboardInputViewController: KeyboardInputViewController

    @EnvironmentObject
    private var keyboardContext: KeyboardContext

    @EnvironmentObject
    private var autocompleteContext: AutocompleteContext

    @EnvironmentObject
    private var keyboardCalloutContext: KeyboardCalloutContext

    @EnvironmentObject
    private var rimeEngine: RimeEngine

    @EnvironmentObject
    private var appSetting: HamsterAppSettings

    var skinExtend: [String: String]

    init(keyboardInputViewController ivc: HamsterKeyboardViewController) {
        self.keyboardInputViewController = ivc
        self.skinExtend = ivc.skinExtend.strDict
        self.layoutProvider = ivc.keyboardLayoutProvider
        self.appearance = ivc.keyboardAppearance
        self.actionHandler = ivc.keyboardActionHandler
    }

    @ViewBuilder
    func buttonContent(item: KeyboardLayoutItem) -> some View {
        HamsterKeyboardActionButtonContent(
            buttonExtendCharacter: skinExtend,
            action: item.action,
            appearance: appearance,
            context: keyboardContext
        )
    }

    var autocompleteToolbar: some View {
        HamsterAutocompleteToolbar()
    }

    var keyboard: some View {
        SystemKeyboard(
            layout: layoutProvider.keyboardLayout(for: keyboardContext),
            appearance: appearance,
            actionHandler: actionHandler,
            autocompleteContext: autocompleteContext,
            autocompleteToolbar: .none,
            autocompleteToolbarAction: { _ in },
            keyboardContext: keyboardContext,
            calloutContext: keyboardCalloutContext,
            width: width,
            buttonView: { layoutItem, keyboardWidth, inputWidth in
                SystemKeyboardButtonRowItem(
                    content: buttonContent(item: layoutItem),
                    item: layoutItem,
                    actionHandler: actionHandler,
                    keyboardContext: keyboardContext,
                    calloutContext: keyboardCalloutContext,
                    keyboardWidth: keyboardWidth,
                    inputWidth: inputWidth,
                    appearance: appearance
                )
            }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            if keyboardContext.keyboardType != .emojis {
                VStack {
                    HStack {
                        Toggle(isOn: $appSetting.preferences.showKeyPressBubble) {
                            Text("按钮气泡")
                        }
                        Toggle(isOn: $appSetting.preferences.switchTraditionalChinese) {
                            Text("繁体中文")
                        }
                    }
                }
                autocompleteToolbar
            }
            keyboard
        }
    }

    var width: CGFloat {
        // TODO: 横向的全面屏需要减去左右两边的听写键和键盘切换键
        return !keyboardContext.isPortrait && keyboardContext.hasDictationKey ? standardKeyboardWidth - 150 : standardKeyboardWidth
    }

    var standardKeyboardWidth: CGFloat {
        keyboardInputViewController.view.frame.width
    }
}
