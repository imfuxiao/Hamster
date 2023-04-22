//
//  CandidateBarArrowButton.swift
//  HamsterKeyboard
//
//  Created by morse on 22/4/2023.
//

import KeyboardKit
import SwiftUI

/// 候选栏箭头按钮
struct CandidateBarArrowButton: View {
  var hamsterColor: ColorSchema
  var action: () -> Void

  @EnvironmentObject
  var keyboardContext: KeyboardContext

  @EnvironmentObject
  var appSettings: HamsterAppSettings

  init(hamsterColor: ColorSchema, action: @escaping () -> Void) {
    self.hamsterColor = hamsterColor
    self.action = action
  }

  var imageName: String {
    if appSettings.keyboardStatus == .normal {
      return "chevron.down"
    }
    return "chevron.up"
  }

  var foregroundColor: Color {
    Color.standardButtonForeground(for: keyboardContext)
  }

  var backgroundColor: Color {
    .standardKeyboardBackground
  }

  var body: some View {
    // 控制栏V型按钮
    ZStack(alignment: .center) {
      VStack(alignment: .leading) {
        HStack {
          Divider()
            .frame(width: 1, height: 30)
            .overlay((hamsterColor.candidateTextColor ?? foregroundColor).opacity(0.1))
            .opacity(appSettings.keyboardStatus == .normal ? 1 : 0)

          Spacer()
        }
      }

      Image(systemName: imageName)
        .font(.system(size: 18))
        .foregroundColor(hamsterColor.candidateTextColor ?? foregroundColor)
        .iconStyle()
    }
    .frame(minWidth: 30, maxWidth: 50)
    .frame(minHeight: 30, maxHeight: 50)
    .background(hamsterColor.backColor ?? backgroundColor)
    .onTapGesture { action() }
  }
}
