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
  @EnvironmentObject
  private var keyboardContext: KeyboardContext

  @EnvironmentObject
  private var rimeEngine: RimeEngine

  public typealias SuggestionAction = (AutocompleteSuggestion) -> Void

  var style = AutocompleteToolbarStyle(
    item: itemStyle
  )

  func itemButton(for suggestion: HamsterSuggestion) -> some View {
    Button {
      // TODO: 点击候选项处理
      let text = suggestion.text
      if !text.isEmpty {
        keyboardContext.textDocumentProxy.insertText(text)
      }
      rimeEngine.rest()
    } label: {
      HStack {
        HamsterAutocompleteToolbarItemTitle(
          suggestion: suggestion,
          style: style.item
        )
      }
      .padding(1)
      .padding(.horizontal, 4)
      .padding(.vertical, 10)
      .background(suggestion.isAutocomplete ? style.autocompleteBackground.color : Color.clearInteractable)
      .cornerRadius(style.autocompleteBackground.cornerRadius)
    }
    .buttonStyle(.plain)
  }

  var body: some View {
    HStack(spacing: 3) {
      ForEach(rimeEngine.suggestions) { item in
        itemButton(for: item)
      }

      Spacer()
    }
  }
}

public struct HamsterAutocompleteToolbarItemTitle: View {
  public init(
    suggestion: HamsterSuggestion,
    style: AutocompleteToolbarItemStyle = .standard
  ) {
    self.suggestion = suggestion
    self.style = style
  }

  private let suggestion: HamsterSuggestion
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
      .environmentObject(KeyboardContext.preview)
      .environmentObject(RimeEngine.shared)
      .environmentObject(AutocompleteContext())
      .environmentObject(ActionCalloutContext.preview)
      .environmentObject(InputCalloutContext.preview)
  }
}
