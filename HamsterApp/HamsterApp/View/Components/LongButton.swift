//
//  LongButton.swift
//  HamsterApp
//
//  Created by morse on 2023/3/20.
//

import SwiftUI

struct LongButton: View {
  let buttonText: String
  let buttonWidth: CGFloat
  let buttonHeight: CGFloat
  let foregroundColor: Color
  let backgroundColor: Color
  let buttonRadius: CGFloat
  let buttonAction: () -> Void

  init(
    buttonText: String,
    buttonWidth: CGFloat = 120,
    buttonHeight: CGFloat = 40,
    foregroundColor: Color = .HamsterFontColor,
    backgroundColor: Color = .HamsterCellColor,
    buttonRadius: CGFloat = 10,
    buttonAction: @escaping () -> Void
  ) {
    self.buttonText = buttonText
    self.buttonWidth = buttonWidth
    self.buttonHeight = buttonHeight
    self.foregroundColor = foregroundColor
    self.backgroundColor = backgroundColor
    self.buttonRadius = buttonRadius
    self.buttonAction = buttonAction
  }

  var body: some View {
    Button {
      buttonAction()
    } label: {
      Text(buttonText)
        .font(.system(size: 16, weight: .bold))
        .frame(width: buttonWidth, height: buttonHeight)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(buttonRadius)
        .hamsterShadow()
    }
    .buttonStyle(.plain)
  }
}

struct LongButton_Preview: PreviewProvider {
  @State static var isShow: Bool = false

  static var previews: some View {
    GeometryReader { proxy in

      LongButton(
        buttonText: "Rime重置",
        buttonWidth: proxy.size.width - 40
      ) {
        isShow.toggle()
      }
//      .padding(.horizontal)
      .alert(isPresented: $isShow, content: {
        Alert(title: Text("测试"))
      })
    }
  }
}
