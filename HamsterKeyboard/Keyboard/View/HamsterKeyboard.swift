//
//  HamsterKeyboard.swift
//  HamsterKeyboard
//
//  Created by morse on 17/2/2023.
//

import KeyboardKit
import SwiftUI

struct HamsterKeyboard: View {
    #if DEBUG
        @ObservedObject var iO = injectionObserver
    #endif

    @State
    private var text = "Text"

    @EnvironmentObject
    private var autocompleteContext: AutocompleteContext

    @EnvironmentObject
    private var keyboardContext: KeyboardContext

    @EnvironmentObject
    private var calloutContext: KeyboardCalloutContext

    private weak var controler: HamsterKeyboardViewController?

    init(controler: HamsterKeyboardViewController) {
        self.controler = controler
    }

    var body: some View {
        VStack(spacing: 0) {
            if keyboardContext.keyboardType != .emojis {
                AutocompleteToolbar(
                    suggestions: autocompleteContext.suggestions,
                    locale: keyboardContext.locale,
                    suggestionAction: { _ in }
                )
            }
            if let controler = controler {
                SystemKeyboard(controller: controler, autocompleteToolbar: .none)
            }
        }
        .eraseToAnyView()
    }
}

struct HamsterAutocomplateView: View {
    var body: some View {
        HStack {
            Image(systemName: "line.horizontal.3")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.secondary)

            Spacer()

            Image(systemName: "chevron.down.circle")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 50)
    }
}

// struct HamsterKeyboard_Previews: PreviewProvider {
//    static var previews: some View {
//        HamsterKeyboard()
//    }
// }
