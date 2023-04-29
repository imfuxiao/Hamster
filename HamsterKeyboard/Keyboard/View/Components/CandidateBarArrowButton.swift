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
  var size: CGFloat
  var hamsterColor: ColorSchema
  var imageName: String
  var showDivider: Bool
  var action: () -> Void

  @EnvironmentObject
  var keyboardContext: KeyboardContext

  init(size: CGFloat, hamsterColor: ColorSchema, imageName: String, showDivider: Bool, action: @escaping () -> Void) {
    self.size = size
    self.hamsterColor = hamsterColor
    self.imageName = imageName
    self.showDivider = showDivider
    self.action = action
  }

  var foregroundColor: Color {
    hamsterColor.candidateTextColor.bgrColor ?? Color.standardButtonForeground(for: keyboardContext)
  }

  var backgroundColor: Color {
    return hamsterColor.backColor.bgrColor ?? Color.standardKeyboardBackground
  }

  @State var tapped: Bool = false

  var tapGesture: some Gesture {
    TapGesture()
      .onEnded {
        tapped = true
        action()
        tapped = false
      }
  }

  var body: some View {
    // 控制栏V型按钮
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .center, spacing: 0) {
        Divider()
          .frame(width: 1, height: 30)
          .overlay(foregroundColor.opacity(0.1))
          .opacity(showDivider ? 1 : 0)
          .offset(x: -10)

        Image(systemName: imageName)
          .font(.system(size: 20))
          .foregroundColor(foregroundColor)
          .iconStyle()
      }
    }
    .padding(3)
    .contentShape(Rectangle())
    .minimumScaleFactor(0.5)
    .frame(width: size, height: size)
    .overlay(
      Color.clearInteractable
        .overlay(
          Color.clear
            .contentShape(Rectangle())
            .gesture(tapGesture)
        )
        .accessibilityAddTraits(.isButton)
    )
  }
}
