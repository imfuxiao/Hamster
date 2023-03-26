//
//  RadioButton.swift
//  HamsterApp
//
//  Created by morse on 15/3/2023.
//

import SwiftUI

struct RadioButton: View {
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
          Circle()
            .fill(color)
            .frame(width: width, height: width)
          Image(systemName: "checkmark")
            .font(.system(size: fontSize, weight: .heavy))
            .foregroundColor(.white)
            .frame(width: width / 2, height: width / 2)
        } else {
          Circle()
            .stroke(.gray, lineWidth: 1)
            .frame(width: width, height: width)
        }
      }
      .transition(.opacity)
      .animation(.easeInOut, value: isSelected)
    }
  }
}

struct RadioButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      RadioButton(isSelected: true)
      RadioButton(isSelected: false)
    }
  }
}
