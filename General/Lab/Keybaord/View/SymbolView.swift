//
//  SymbolView.swift
//  Hamster
//
//  Created by morse on 2023/5/25.
//

import KeyboardKit
import SwiftUI

struct SymbolView: View {
  init(
    appearance: HamsterKeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    calloutContext: KeyboardCalloutContext,
    padding: EdgeInsets,
    width: CGFloat,
    symbol: String,
    isInScrollView: Bool = true,
    enableRoundedCorners: Bool = false
  ) {
    self.appearance = appearance
    self.width = width
    self.actionHandler = actionHandler
    self.padding = padding
    self.symbol = symbol
    self.isInScrollView = isInScrollView
    self.enableRoundedCorners = enableRoundedCorners
    self._calloutContext = ObservedObject(wrappedValue: calloutContext)
  }

  let appearance: HamsterKeyboardAppearance
  let width: CGFloat
  let padding: EdgeInsets
  let symbol: String
  private let actionHandler: KeyboardActionHandler
  private let isInScrollView: Bool
  private let enableRoundedCorners: Bool

  @State private var isPressed: Bool = false
  @EnvironmentObject var keyboardContext: KeyboardContext
  @EnvironmentObject var appSettings: HamsterAppSettings

  @ObservedObject
  private var calloutContext: KeyboardCalloutContext

  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      Spacer()
      HStack(alignment: .center, spacing: 0) {
        Text(symbol)
      }
      Spacer()
      Divider()
    }
    .foregroundColor(foregroundColor)
    .hamsterKeyboardGestures(
      for: KeyboardAction.character(symbol),
      actionHandler: actionHandler,
      calloutContext: calloutContext,
      isInScrollView: isInScrollView,
      isPressed: $isPressed
    )
    .frame(width: width, height: 45)
    .listRowBackground(backgroundColor(isPressed).roundedCorner(enableRoundedCorners ? appearance.keyboardLayoutConfiguration.buttonCornerRadius : 0, corners: [.topLeft, .topRight]))
    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    .hideListRowSeparator()
    // iOS 16 版本可以通过下面函数制定对齐方式
//    .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
  }
}

extension SymbolView {
  var foregroundColor: Color {
    guard let colorSchema = appearance.hamsterColorSchema else { return .primary }
    return colorSchema.candidateTextColor == .clear ? .primary : colorSchema.candidateTextColor
  }

  func backgroundColor(_ isPressed: Bool) -> Color {
    if isPressed {
      return Color.white
    }
    guard let colorSchema = appearance.hamsterColorSchema else {
      return Color.clear
    }
    return colorSchema.backColor
  }

  var buttonStyle: KeyboardButtonStyle {
    KeyboardButtonStyle(
      backgroundColor: backgroundColor(isPressed),
      foregroundColor: foregroundColor,
      font: .body,
      cornerRadius: appearance.keyboardLayoutConfiguration.buttonCornerRadius,
      border: .noBorder,
      shadow: .noShadow
    )
  }
}

struct SymbolView_Previews: PreviewProvider {
  static var previews: some View {
    SymbolView(
      appearance: HamsterKeyboardAppearance.preview,
      actionHandler: KeyboardInputViewController.preview.keyboardActionHandler,
      calloutContext: KeyboardCalloutContext.preview,
      padding: .init(top: 0, leading: 0, bottom: 0, trailing: 0),
      width: 50,
      symbol: "+"
    )
  }
}
