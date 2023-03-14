//
//  RadioButton.swift
//  HamsterApp
//
//  Created by morse on 15/3/2023.
//

import SwiftUI

struct RadioButton: View {
  var color: Color = .green.opacity(0.8)
  var width: CGFloat = 32
  var isSelected = false
  var action: () -> Void = {}

  var body: some View {
    Button {
      action()
    } label: {
      ZStack {
        Circle()
          .foregroundColor(color)
          .frame(width: width, height: width)
        if isSelected {
          Circle()
            .foregroundColor(Color.white)
            .frame(width: width / 2, height: width / 2)
        }
      }
      .transition(.opacity)
      .animation(.easeInOut, value: isSelected)
    }
  }
}

struct RadioButton_Previews: PreviewProvider {
  static var previews: some View {
    RadioButton(isSelected: true)
  }
}
