//
//  OneHandedView.swift
//  Hamster
//
//  Created by morse on 19/5/2023.
//

import KeyboardKit
import SwiftUI

/// 单手模式
struct OneHandedView<Content: View>: View {
  let content: Content
  let realKeyboardWidth: CGFloat
  let oneHandWidth: CGFloat

  @EnvironmentObject
  var keyboardContext: KeyboardContext

  @EnvironmentObject
  var appSettings: HamsterAppSettings

  var foregroundColor: Color {
    Color.standardButtonForeground(for: keyboardContext)
  }

  @ViewBuilder
  var panelOfOnehandOnLeft: some View {
    VStack(spacing: 20) {
      Image(systemName: "keyboard.onehanded.left")
        .foregroundColor(foregroundColor)
        .opacity(0.7)
        .iconStyle()
        .frame(width: 56, height: 56)
        .onTapGesture {
          self.appSettings.keyboardOneHandOnRight = false
        }
      Image(systemName: "arrow.up.backward.and.arrow.down.forward")
        .foregroundColor(foregroundColor)
        .opacity(0.7)
        .iconStyle()
        .frame(width: 56, height: 56)
        .onTapGesture {
          self.appSettings.enableKeyboardOneHandMode = false
        }
    }
    .padding(.top, 40)
    .frame(width: oneHandWidth)
  }

  @ViewBuilder
  var panelOfOnehandOnRight: some View {
    VStack(spacing: 20) {
      Image(systemName: "keyboard.onehanded.right")
        .foregroundColor(foregroundColor)
        .iconStyle()
        .frame(width: 56, height: 56)
        .onTapGesture {
          self.appSettings.keyboardOneHandOnRight = true
        }
      Image(systemName: "arrow.up.backward.and.arrow.down.forward")
        .foregroundColor(foregroundColor)
        .iconStyle()
        .frame(width: 56, height: 56)
        .onTapGesture {
          self.appSettings.enableKeyboardOneHandMode = false
        }
    }
    .padding(.top, 40)
    .frame(width: oneHandWidth)
  }

  var body: some View {
    HStack(spacing: 0) {
      if appSettings.enableKeyboardOneHandMode && appSettings.keyboardOneHandOnRight {
        panelOfOnehandOnLeft
      }

      content
        .frame(width: realKeyboardWidth)

      if appSettings.enableKeyboardOneHandMode && !appSettings.keyboardOneHandOnRight {
        panelOfOnehandOnRight
      }
    }
  }
}

extension View {
  @ViewBuilder
  func oneHandKeyboard(enable: Bool, realKeyboardWidth: CGFloat, oneHandWidth: CGFloat) -> some View {
    if !enable {
      self
    }
    if enable {
      OneHandedView(content: self, realKeyboardWidth: realKeyboardWidth, oneHandWidth: oneHandWidth)
    }
  }
}

struct OneHandedView_Previews: PreviewProvider {
  static var appSettings: HamsterAppSettings {
    let appSettings = HamsterAppSettings()
    appSettings.enableKeyboardOneHandMode = true
    appSettings.keyboardOneHandOnRight = true
    return appSettings
  }

  static var previews: some View {
    OneHandedView(
      content: SystemKeyboard(controller: KeyboardInputViewController.preview),
      realKeyboardWidth: KeyboardInputViewController.preview.view.frame.width - appSettings.keyboardOneHandWidth,
      oneHandWidth: appSettings.keyboardOneHandWidth
    )
    .environmentObject(KeyboardContext.preview)
    .environmentObject(appSettings)
  }
}
