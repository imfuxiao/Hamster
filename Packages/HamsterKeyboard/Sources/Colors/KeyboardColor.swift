//
//  KeyboardColor.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-04-13.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This enum defines raw, keyboard-specific asset-based colors.

 Although you can use this type directly, you should instead
 use the ``KeyboardColorReader`` protocol, to get extensions
 that build on these colors. `Color` already implements this
 protocol, so you can use it directly.
 */

public enum HamsterKeyboardColor: String, CaseIterable, Identifiable {
  case standardButtonBackground
  case standardButtonBackgroundForColorSchemeBug
  case standardButtonBackgroundForDarkAppearance
  case standardButtonForeground
  case standardButtonForegroundForDarkAppearance
  case standardButtonShadow
  case standardDarkButtonBackground
  case standardDarkButtonBackgroundForColorSchemeBug
  case standardDarkButtonBackgroundForDarkAppearance
  case standardKeyboardBackground
  case standardKeyboardBackgroundForDarkAppearance
}

public extension HamsterKeyboardColor {
  /**
   The color's unique identifier.
   */
  var id: String { rawValue }

  /**
   The color value.
   */
  var color: Color {
    Color(resourceName)
  }

  /**
   The color asset name in the bundle asset catalog.
   */
  var resourceName: String { rawValue }
}

struct HamsterKeyboardColor_Previews: PreviewProvider {
  static func preview(for color: HamsterKeyboardColor) -> some View {
    VStack(alignment: .leading) {
      Text(color.resourceName).font(.footnote)
      HStack(spacing: 0) {
        color.color
        color.color.colorScheme(.dark)
      }
      .frame(height: 100)
      .cornerRadius(10)
    }
  }

  static var previews: some View {
    ScrollView {
      VStack {
        ForEach(HamsterKeyboardColor.allCases) {
          preview(for: $0)
        }
      }.padding()
    }.background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all))
  }
}
