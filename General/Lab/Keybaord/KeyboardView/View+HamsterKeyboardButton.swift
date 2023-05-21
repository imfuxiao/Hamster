//
//  View+HamsterKeyboardButton.swift
//  Hamster
//
//  Created by morse on 2023/5/26.
//

import KeyboardKit
import SwiftUI

extension View {
  func hamsterKeyboardButtonStyle(
    _ style: KeyboardButtonStyle,
    isPressed: Bool = false
  ) -> some View {
    self.background(HamsterKeyboardButtonBody(style: style))
      .foregroundColor(style.foregroundColor)
      .font(style.font?.font)
  }
}


//struct View_HamsterKeyboardButton_Previews: PreviewProvider {
//  static var previews: some View {
//    View_HamsterKeyboardButton()
//  }
//}
