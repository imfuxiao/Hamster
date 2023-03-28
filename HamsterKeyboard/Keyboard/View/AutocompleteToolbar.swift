//
//  SwiftUIView.swift
//
//
//  Created by morse on 16/1/2023.
//

import KeyboardKit
import SwiftUI

let itemStyle = AutocompleteToolbarItemStyle(
  titleFont: .system(size: 18, weight: .bold),
  titleColor: .primary,
  subtitleFont: .system(size: 12),
  subtitleColor: .primary
)

@available(iOS 13, *)
struct HamsterAutocompleteToolbar: View {
  @EnvironmentObject
  private var keyboardContext: KeyboardContext

  @EnvironmentObject
  private var appSettings: HamsterAppSettings

  @EnvironmentObject
  private var rimeEngine: RimeEngine

  var style = AutocompleteToolbarStyle(
    item: itemStyle
  )

  struct HamsterColorSchema {
    var hilitedTextColor: Color = itemStyle.titleColor
    var hilitedCandidateTextColor: Color = itemStyle.titleColor
    var hilitedCommentTextColor: Color = itemStyle.titleColor
    var hilitedCandidateBackColor: Color = .clear
    var candidateTextColor: Color = itemStyle.subtitleColor
    var commentTextColor: Color = itemStyle.subtitleColor
    var backgroundColor: Color = .clear
  }

  var hamsterColor: HamsterColorSchema {
    var schema = HamsterColorSchema()

    if !appSettings.enableRimeColorSchema {
      return schema
    }
    let name = appSettings.rimeColorSchema
    if name.isEmpty {
      return schema
    }

    guard let colorSchema = rimeEngine.colorSchema().first(where: { $0.schemaName == name }) else {
      return schema
    }

    if let color = colorSchema.hilitedTextColor.bgrColor {
      schema.hilitedTextColor = color
    }
    if let color = colorSchema.hilitedCandidateTextColor.bgrColor {
      schema.hilitedCandidateTextColor = color
    }
    if let color = colorSchema.hilitedCommentTextColor.bgrColor {
      schema.hilitedCommentTextColor = color
    }
    if let color = colorSchema.hilitedCandidateBackColor.bgrColor {
      schema.hilitedCandidateBackColor = color
    }
    if let color = colorSchema.candidateTextColor.bgrColor {
      schema.candidateTextColor = color
    }
    if let color = colorSchema.commentTextColor.bgrColor {
      schema.commentTextColor = color
    }
    if let color = colorSchema.backColor.bgrColor {
      schema.backgroundColor = color
    }

    return schema
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text(rimeEngine.userInputKey)
          .font(style.item.subtitleFont)
          .foregroundColor(hamsterColor.hilitedTextColor)

        Spacer()
      }
      .padding(.vertical, 3)
      .padding(.leading, 5)

      ScrollView(.horizontal, showsIndicators: true) {
        LazyHStack {
          ForEach(rimeEngine.suggestions) { item in
            Button {
              // TODO: 点击候选项处理
              let text = item.text
              if !text.isEmpty {
                keyboardContext.textDocumentProxy.insertText(text)
              }
              rimeEngine.rest()
            } label: {
              HStack(alignment: .bottom, spacing: 1) {
                Text(item.text)
                  .font(style.item.titleFont)
                  .foregroundColor(item.isAutocomplete ?
                    hamsterColor.hilitedCandidateTextColor : hamsterColor.candidateTextColor
                  )

                if let comment = item.comment {
                  Text(comment)
                    .font(style.item.subtitleFont)
                    .foregroundColor(item.isAutocomplete ?
                      hamsterColor.hilitedCommentTextColor : hamsterColor.commentTextColor
                    )
                }
              }
              .padding(.horizontal, 4)
              .padding(.vertical, 10)
              .background(item.isAutocomplete ? hamsterColor.hilitedCandidateBackColor : Color.clearInteractable)
              .cornerRadius(style.autocompleteBackground.cornerRadius)
            }
            .buttonStyle(.plain)
          }
        }
        .frame(height: 40)
      }
    }
    .background(hamsterColor.backgroundColor)
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
