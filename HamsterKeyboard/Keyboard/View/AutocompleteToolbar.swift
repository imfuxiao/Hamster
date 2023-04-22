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
      .padding(.leading, 2)
      .padding(.trailing, 50)
      .frame(minHeight: 30, maxHeight: 40)
      .frame(minWidth: 0, maxWidth: .infinity)
    }
//    .background(hamsterColor.backColor)
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
