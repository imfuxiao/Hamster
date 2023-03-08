//
//  SwiftUIView.swift
//
//
//  Created by morse on 16/1/2023.
//

import KeyboardKit
import SwiftUI

let itemStyle = AutocompleteToolbarItemStyle(
    titleFont: .system(size: 9),
    titleColor: .primary,
    subtitleFont: .system(size: 18),
    subtitleColor: .primary
)

struct HamsterAutocompleteToolbar: View {
    @EnvironmentObject private var autocompleteContext: AutocompleteContext
    @EnvironmentObject private var keyboardContext: KeyboardContext
    @EnvironmentObject private var rimeEngine: RimeEngine

    func itemView(suggestion: AutocompleteSuggestion, style: AutocompleteToolbarStyle, local: Locale) -> some View {
        HStack {
            HamsterAutocompleteToolbarItemTitle(
                suggestion: suggestion,
                style: style.item
            )
        }
        .padding(1)
    }

    var body: some View {
        GeometryReader { _ in
            AutocompleteToolbar(
                suggestions: rimeEngine.suggestions,
                locale: keyboardContext.locale,
                style: AutocompleteToolbarStyle(
                    item: itemStyle
                ),
                itemView: itemView,
                suggestionAction: {
                    // TODO: 点击候选项处理
                    let text = $0.text
                    if !text.isEmpty {
                        keyboardContext.textDocumentProxy.insertText(text)
                    }
                    rimeEngine.rest()
                }
            )
        }
        .frame(height: 50)
    }
}

public struct HamsterAutocompleteToolbarItemTitle: View {
    public init(
        suggestion: AutocompleteSuggestion,
        style: AutocompleteToolbarItemStyle = .standard
    ) {
        self.suggestion = suggestion
        self.style = style
    }

    private let suggestion: AutocompleteSuggestion
    private let style: AutocompleteToolbarItemStyle

    public var body: some View {
        VStack(alignment: .leading) {
            Text(suggestion.title)
                .lineLimit(1)
                .font(style.titleFont)
                .foregroundColor(style.titleColor)

            HStack(alignment: .bottom, spacing: 0) {
                Text(suggestion.subtitle ?? "")
                    .font(style.subtitleFont)
                    .foregroundColor(style.subtitleColor)
                    .font(Font.body.bold())

                if let comment = suggestion.additionalInfo["comment"] {
                    Text(comment as! String)
                        .font(.system(size: 6))
                        .foregroundColor(style.subtitleColor)
                        .font(Font.body.bold())
                }
            }
        }
    }
}

struct AutocompleteToolbar_Previews: PreviewProvider {
    static var previews: some View {
        HamsterAutocompleteToolbar()
            .preferredColorScheme(.dark)
            .environmentObject(KeyboardContext.hamsterPreview)
            .environmentObject(RimeEngine.shared)
            .environmentObject(AutocompleteContext())
            .environmentObject(ActionCalloutContext.preview)
            .environmentObject(InputCalloutContext.preview)
    }
}
