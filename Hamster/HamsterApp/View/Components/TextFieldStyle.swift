//
//  TextFieldStyle.swift
//  HamsterApp
//
//  Created by morse on 2023/3/21.
//

import SwiftUI

struct BorderTextFieldBackground: TextFieldStyle {
  let systemImageString: String
  let height: CGFloat
  let borderColor: Color
  let cornerRadius: CGFloat
  init(systemImageString: String,
       height: CGFloat = 40,
       borderColor: Color = .secondary,
       cornerRadius: CGFloat = 8.0)
  {
    self.systemImageString = systemImageString
    self.height = height
    self.borderColor = borderColor
    self.cornerRadius = cornerRadius
  }

  // Hidden function to conform to this protocol
  func _body(configuration: TextField<Self._Label>) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: cornerRadius)
        .stroke(borderColor)
        .frame(height: height)

      HStack {
        Image(systemName: systemImageString)
        configuration
      }
      .padding(.horizontal)
    }
  }
}

struct TextFieldStyle_Previews: PreviewProvider {
  @State static var text: String = ""
  static var previews: some View {
    Rectangle()
//          .fill(Color.primary.opacity(0.5))
      .fill(Color.clear)
      .frame(minWidth: 0, maxWidth: .infinity)
      .frame(height: 50)
      .overlay(
        HStack {
          TextField("输入", text: $text)
            .textFieldStyle(BorderTextFieldBackground(systemImageString: "text.badge.plus"))
            .padding(.vertical, 5)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
      )
  }
}
