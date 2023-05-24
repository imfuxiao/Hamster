//
//  Color+Keyboard.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-20.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import KeyboardKit
import SwiftUI

/**
 This protocol can be implemented by any type that should be
 able to access keyboard-specific colors.

 This protocol is implemented by `Color`. This means that it
 is possible to use e.g. `Color.standardButtonBackground` to
 get the standard button background.

 The context-based color functions may look strange, but the
 reason for having them this way is that iOS gets an invalid
 color scheme when editing a text field with dark appearance.
 This causes iOS to set the extension's color scheme to dark
 even if the system color scheme is light.

 To work around this, some colors have a temporary color set
 with a `ForColorSchemeBug` suffix that are semi-transparent
 white with an opacity that makes them look ok in both light
 and dark mode.

 Issue report (also reported to Apple in Feedback Assistant):
 https://github.com/danielsaidi/KeyboardKit/issues/305
 */

public extension KeyboardColorReader {
  /**
   The standard background color of light keyboard buttons.
   */
  static var hamsterStandardButtonBackground: Color {
    color(for: .standardButtonBackground)
  }

  /**
   The standard background color of light keyboard buttons
   when accounting for the iOS dark mode bug.
   */
  static var hamsterStandardButtonBackgroundForColorSchemeBug: Color {
    color(for: .standardButtonBackgroundForColorSchemeBug)
  }

  /**
   The standard background color of light keyboard buttons
   in dark keyboard appearance.
   */
  static var hamsterStandardButtonBackgroundForDarkAppearance: Color {
    color(for: .standardButtonBackgroundForDarkAppearance)
  }

  /**
   The standard foreground color of light keyboard buttons.
   */
  static var hamsterStandardButtonForeground: Color {
    color(for: .standardButtonForeground)
  }

  /**
   The standard foreground color of light keyboard buttons
   in dark keyboard appearance.
   */
  static var hamsterStandardButtonForegroundForDarkAppearance: Color {
    color(for: .standardButtonForegroundForDarkAppearance)
  }

  /**
   The standard shadow color of keyboard buttons.
   */
  static var hamsterStandardButtonShadow: Color {
    color(for: .standardButtonShadow)
  }

  /**
   The standard background color of a dark keyboard button.
   */
  static var hamsterStandardDarkButtonBackground: Color {
    color(for: .standardDarkButtonBackground)
  }

  /**
   The standard background color of a dark keyboard button
   when accounting for the iOS dark mode bug.
   */
  static var hamsterStandardDarkButtonBackgroundForColorSchemeBug: Color {
    color(for: .standardDarkButtonBackgroundForColorSchemeBug)
  }

  /**
   The standard background color of a dark keyboard button
   in dark keyboard appearance.
   */
  static var hamsterStandardDarkButtonBackgroundForDarkAppearance: Color {
    color(for: .standardDarkButtonBackgroundForDarkAppearance)
  }

  /**
   The standard foreground color of a dark keyboard button.
   */
  static var hamsterStandardDarkButtonForeground: Color {
    color(for: .standardButtonForeground)
  }

  /**
   The standard foreground color of a dark keyboard button
   in dark keyboard appearance.
   */
  static var hamsterStandardDarkButtonForegroundForDarkAppearance: Color {
    color(for: .standardButtonForegroundForDarkAppearance)
  }

  /**
   The standard keyboard background color.
   */
  static var hamsterStandardKeyboardBackground: Color {
    color(for: .standardKeyboardBackground)
  }

  /**
   The standard keyboard background color in dark keyboard
   appearance.
   */
  static var hamsterStandardKeyboardBackgroundForDarkAppearance: Color {
    color(for: .standardKeyboardBackgroundForDarkAppearance)
  }
}

// MARK: - Functions

public extension KeyboardColorReader {
  /**
   The standard background color of light keyboard buttons.
   */
  static func hamsterStandardButtonBackground(for context: KeyboardContext) -> Color {
    context.hasDarkColorScheme ?
      .hamsterStandardButtonBackgroundForColorSchemeBug :
      .hamsterStandardButtonBackground
  }

  /**
   The standard foreground color of light keyboard buttons.
   */
  static func hamsterStandardButtonForeground(for context: KeyboardContext) -> Color {
    context.hasDarkColorScheme ?
      .hamsterStandardButtonForegroundForDarkAppearance :
      .hamsterStandardButtonForeground
  }

  /**
   The standard shadow color of keyboard buttons.
   */
  static func hamsterStandardButtonShadow(for context: KeyboardContext) -> Color {
    .hamsterStandardButtonShadow
  }

  /**
   The standard background color of dark keyboard buttons.
   */
  static func hamsterStandardDarkButtonBackground(for context: KeyboardContext) -> Color {
    context.hasDarkColorScheme ?
      .hamsterStandardDarkButtonBackgroundForColorSchemeBug :
      Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0.15))
//      .hamsterStandardDarkButtonBackground
//      .opacity(0.4)
  }

  /**
   The standard foreground color of dark keyboard buttons.
   */
  static func hamsterStandardDarkButtonForeground(for context: KeyboardContext) -> Color {
    context.hasDarkColorScheme ?
      .hamsterStandardDarkButtonForegroundForDarkAppearance :
      .hamsterStandardDarkButtonForeground
  }
}

private extension KeyboardColorReader {
  static func color(for color: HamsterKeyboardColor) -> Color {
    color.color
  }
}

struct KeyboardColorReader_Previews: PreviewProvider {
  static func preview(for color: Color, name: String) -> some View {
    VStack(alignment: .leading) {
      Text(name).font(.footnote)
      HStack(spacing: 0) {
        color
        color.colorScheme(.dark)
      }
      .frame(height: 100)
      .cornerRadius(10)
    }
  }

  static var previews: some View {
    ScrollView {
      VStack {
        Group {
          preview(for: .standardButtonBackground, name: "standardButtonBackground")
          preview(for: .standardButtonBackgroundForColorSchemeBug, name: "standardButtonBackgroundForColorSchemeBug")
          preview(for: .standardButtonBackgroundForDarkAppearance, name: "standardButtonBackgroundForDarkAppearance")
          preview(for: .standardButtonForeground, name: "standardButtonForeground")
          preview(for: .standardButtonForegroundForDarkAppearance, name: "standardButtonForegroundForDarkAppearance")
          preview(for: .standardButtonShadow, name: "standardButtonShadow")
        }
        Group {
          preview(for: .standardDarkButtonBackground, name: "standardDarkButtonBackground")
          preview(for: .standardDarkButtonBackgroundForColorSchemeBug, name: "standardDarkButtonBackgroundForColorSchemeBug")
          preview(for: .standardDarkButtonBackgroundForDarkAppearance, name: "standardDarkButtonBackgroundForDarkAppearance")
          preview(for: .standardDarkButtonForeground, name: "standardDarkButtonForeground")
          preview(for: .standardDarkButtonForegroundForDarkAppearance, name: "standardDarkButtonForegroundForDarkAppearance")
          preview(for: .standardKeyboardBackground, name: "standardKeyboardBackground")
          preview(for: .standardKeyboardBackgroundForDarkAppearance, name: "standardKeyboardBackgroundForDarkAppearance")
        }
      }.padding()
    }.background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all))
  }
}
