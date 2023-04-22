//
//  ExpandCandidatesView.swift
//  HamsterKeyboard
//
//  Created by morse on 21/4/2023.
//

import KeyboardKit
import SwiftUI

struct ExpandCandidatesView: View {
  var style: AutocompleteToolbarStyle
  @EnvironmentObject var appSettings: HamsterAppSettings
  var candidatesAction: (HamsterSuggestion) -> Void

  init(style: AutocompleteToolbarStyle, candidatesAction: @escaping (HamsterSuggestion) -> Void) {
    Logger.shared.log.debug("ExpandCandidatesView init")
    self.style = style
    self.candidatesAction = candidatesAction
  }

  @EnvironmentObject
  var rimeEngine: RimeEngine

  var hamsterColor: ColorSchema {
    rimeEngine.currentColorSchema
  }

  var backgroundColor: Color {
    return hamsterColor.backColor ?? Color.standardKeyboardBackground
  }

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      // 纵向候选区
      CandidateVStackView(style: style, hamsterColor: hamsterColor, suggestions: $rimeEngine.suggestions) {
        candidatesAction($0)
      }
      .background(backgroundColor)
      .transition(.move(edge: .top).combined(with: .opacity))

      VStack(alignment: .center, spacing: 0) {
        // 收起按钮
        CandidateBarArrowButton(hamsterColor: hamsterColor, action: {
          appSettings.keyboardStatus = .normal
        })
        Spacer()
        // TODO: 这里可以增加删除按钮
        // Image.keyboardBackspace
      }
    }
    .background(backgroundColor)
  }
}
