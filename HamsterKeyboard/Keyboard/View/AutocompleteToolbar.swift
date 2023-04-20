//
//  SwiftUIView.swift
//
//
//  Created by morse on 16/1/2023.
//

import KeyboardKit
import SwiftUI

@available(iOS 14, *)
struct HamsterAutocompleteToolbar: View {
  weak var ivc: HamsterKeyboardViewController?
  let style: AutocompleteToolbarStyle

  @EnvironmentObject
  private var keyboardContext: KeyboardContext

  @EnvironmentObject
  private var appSettings: HamsterAppSettings

  @EnvironmentObject
  private var rimeEngine: RimeEngine

  init(ivc: HamsterKeyboardViewController?, style: AutocompleteToolbarStyle) {
    weak var keyboardViewController = ivc
    self.ivc = keyboardViewController
    self.style = style
  }

  var hamsterColor: ColorSchema {
    rimeEngine.currentColorSchema
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // 拼写区域: 判断是否启用内嵌模式
      if !appSettings.enableInputEmbeddedMode {
        HStack {
          Text(rimeEngine.userInputKey)
            .font(style.item.subtitleFont)
            .foregroundColor(hamsterColor.hilitedTextColor)
            .minimumScaleFactor(0.7)
          Spacer()
        }
        .padding(.leading, 5)
        .padding(.vertical, 2)
        .frame(minHeight: 0, maxHeight: 10)
      }
      // 候选区
      CandidateHStackView(style: style, hamsterColor: hamsterColor, suggestions: $rimeEngine.suggestions) { [weak ivc] item in
        guard let ivc = ivc else { return }
        ivc.selectCandidateIndex(index: item.index)
      }
      .padding(.leading, 1)
      .padding(.trailing, 50)
      .frame(minHeight: 40, maxHeight: 50)
      .frame(minWidth: 0, maxWidth: .infinity)

      // TODO: 使用 ScrollView + LazyHStack 存在误触问题
//        ScrollView(.horizontal, showsIndicators: false) {
//          LazyHStack(spacing: 0, pinnedViews: .sectionFooters) {
//            ForEach(rimeEngine.suggestions) { item in
//              Button { [weak ivc] in
//                guard let ivc = ivc else { return }
//                // TODO: 点击候选项处理
//                ivc.selectCandidateIndex(index: item.index)
//              } label: {
//                HStack(spacing: 0) {
//                  Text(item.text)
//                    .font(style.item.titleFont)
//                    .foregroundColor(
//                      item.isAutocomplete
//                        ? hamsterColor.hilitedCandidateTextColor
//                        : hamsterColor.candidateTextColor
//                    )
//                  if let comment = item.comment {
//                    Text(comment)
//                      .font(style.item.subtitleFont)
//                      .foregroundColor(
//                        item.isAutocomplete
//                          ? hamsterColor.hilitedCommentTextColor
//                          : hamsterColor.commentTextColor
//                      )
//                  }
//                }
//                .padding(.all, 5)
//                .background(item.isAutocomplete ? hamsterColor.hilitedCandidateBackColor : Color.clearInteractable)
//                .cornerRadius(style.autocompleteBackground.cornerRadius)
//                .contentShape(Rectangle())
//              }
//              .buttonStyle(.plain)
//            }
//          }
//        }
//        .frame(height: proxy.size.height - 10)
//        .frame(minWidth: 0, maxWidth: .infinity)
//        .padding(.leading, 2)
    }
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
