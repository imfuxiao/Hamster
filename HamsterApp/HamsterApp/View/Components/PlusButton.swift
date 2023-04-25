//
//  PlusButton.swift
//  HamsterApp
//
//  Created by morse on 25/4/2023.
//

import SwiftUI

struct PlusButton: View {
  typealias Action = () -> Void
  var tapAction: Action?
  var body: some View {
    ZStack(alignment: .center) {
      Circle()
        .fill(Color.blue)
      Image(systemName: "plus")
        .font(.system(size: 30, weight: .bold))
        .foregroundColor(.white)
    }
    .frame(width: 60, height: 60)
    .shadow(radius: 5)
    .overlay(
      Color.white.opacity(0.001)
        .overlay(
          Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
              tapAction?()
            }
        )
        .accessibilityAddTraits(.isButton)
    )
  }
}

struct PlusButton_Previews: PreviewProvider {
  static var previews: some View {
    PlusButton()
  }
}
