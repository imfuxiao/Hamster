//
//  Checkbox.swift
//  Hamster
//
//  Created by morse on 26/4/2023.
//

import SwiftUI

struct Checkbox: View {
  var color: Color = .green
  var width: CGFloat = 32
  var fontSize: CGFloat = 16
  var isSelected = false
  var action: () -> Void = {}

  var body: some View {
    Button {
      action()
    } label: {
      ZStack {
        if isSelected {
          Rectangle()
            .fill(color)
            .frame(width: width, height: width)
          Image(systemName: "checkmark")
            .font(.system(size: fontSize, weight: .heavy))
            .foregroundColor(.white)
            .frame(width: width / 2, height: width / 2)
        } else {
          Rectangle()
            .stroke(.gray, lineWidth: 1)
            .frame(width: width, height: width)
        }
      }
      .transition(.opacity)
      .animation(.linear, value: isSelected)
    }
  }
}

struct Checkbox_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Checkbox()
      Checkbox(isSelected: true)
    }
  }
}
