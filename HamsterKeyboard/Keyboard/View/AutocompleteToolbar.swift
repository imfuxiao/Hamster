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

@available(iOS 14, *)
struct HamsterAutocompleteToolbar: View {
  weak var ivc: HamsterKeyboardViewController?

  @EnvironmentObject
  private var keyboardContext: KeyboardContext

  @EnvironmentObject
  private var appSettings: HamsterAppSettings

  @EnvironmentObject
  private var rimeEngine: RimeEngine

  var style = AutocompleteToolbarStyle(
    item: itemStyle
  )

  init(ivc: HamsterKeyboardViewController) {
    weak var keyboardViewController = ivc
    self.ivc = keyboardViewController
  }

  var hamsterColor: ColorSchema {
    rimeEngine.currentColorSchema
  }

  var body: some View {
    VStack(spacing: 0) {
      // 拼写区域
      HStack {
        Text(rimeEngine.userInputKey)
          .font(style.item.subtitleFont)
          .foregroundColor(hamsterColor.hilitedTextColor)

        Spacer()
      }
      .padding(.vertical, 5)
      .padding(.leading, 5)
      .frame(height: 25)

      // 候选区
      HStack(spacing: 0) {
        ScrollView(.horizontal, showsIndicators: true) {
          LazyHStack(spacing: 0) {
            ForEach(rimeEngine.suggestions) { item in
              Button { [weak ivc] in
                guard let ivc = ivc else { return }
                // TODO: 点击候选项处理
                ivc.insertText(String(item.index))
              } label: {
                HStack(alignment: .bottom, spacing: 0) {
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
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
                .background(item.isAutocomplete ? hamsterColor.hilitedCandidateBackColor : Color.clearInteractable)
                .cornerRadius(style.autocompleteBackground.cornerRadius)
                .contentShape(Rectangle(), eoFill: true)
              }
              .buttonStyle(.plain)
            }
          }
          // LazyHStack End
        }
        // ScrollView End
      }
      .frame(minHeight: 35)
    }
    .frame(minWidth: 0, maxWidth: .infinity)
    .frame(height: 60)
    .background(hamsterColor.backColor)
  }
}

struct AutocompleteToolbar_Previews: PreviewProvider {
  static var previews: some View {
    VStack {}
//    HamsterAutocompleteToolbar()
//      .preferredColorScheme(.dark)
//      .environmentObject(KeyboardContext.preview)
//      .environmentObject(RimeEngine.shared)
//      .environmentObject(AutocompleteContext())
//      .environmentObject(ActionCalloutContext.preview)
//      .environmentObject(InputCalloutContext.preview)
  }
}
