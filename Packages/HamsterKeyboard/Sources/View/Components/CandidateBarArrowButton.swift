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
  init(foregroundColor: Color, backgroundColor: Color, size: CGFloat, imageName: String, showDivider: Bool, action: @escaping () -> Void) {
    self.foregroundColor = foregroundColor
    self.backgroundColor = backgroundColor
    self.size = size
    self.imageName = imageName
    self.showDivider = showDivider
    self.action = action
  }

  var size: CGFloat
  var imageName: String
  var showDivider: Bool
  var action: () -> Void

  var foregroundColor: Color
  var backgroundColor: Color

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
    VStack(alignment: .center, spacing: 0) {
      ZStack(alignment: .center) {
        HStack(alignment: .center, spacing: 0) {
          Divider()
            .frame(width: 1, height: size * 0.6)
            .overlay(foregroundColor.opacity(0.1))
            .opacity(showDivider ? 1 : 0)
            .padding(.trailing, 10)

          Spacer()
        }
        Image(systemName: imageName)
          .resizable()
          .scaledToFit()
          .scaleEffect(0.8)
          .frame(width: size * 0.5, height: size * 0.5)
          .foregroundColor(foregroundColor.opacity(0.8))
          .iconStyle()
      }
    }
    .padding(3)
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

struct CandidateBarArrowButton_Preview: PreviewProvider {
  static let appSettings = HamsterAppSettings.shared
  static var previews: some View {
    VStack {
      CandidateBarArrowButton(foregroundColor: .red, backgroundColor: .yellow, size: 50, imageName: appSettings.candidateBarArrowButtonImageName, showDivider: true) {}
    }
    .environmentObject(KeyboardContext.preview)
  }
}
