//
//  SymbolView.swift
//  Hamster
//
//  Created by morse on 2023/5/25.
//

import KeyboardKit
import SwiftUI

struct NumNineGridSymbolView: View {
  init(
    appearance: HamsterKeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    calloutContext: KeyboardCalloutContext,
    width: CGFloat,
    symbol: String,
    isInScrollView: Bool = true,
    enableRoundedCorners: Bool = false
  ) {
    self.appearance = appearance
    self.width = width
    self.actionHandler = actionHandler
    self.symbol = symbol
    self.isInScrollView = isInScrollView
    self.enableRoundedCorners = enableRoundedCorners
    self._calloutContext = ObservedObject(wrappedValue: calloutContext)
  }

  let appearance: HamsterKeyboardAppearance
  let width: CGFloat
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
    .frame(width: width, height: 38.5)
    .foregroundColor(foregroundColor)
    .hamsterKeyboardGestures(
      for: KeyboardAction.character(symbol),
      actionHandler: actionHandler,
      calloutContext: calloutContext,
      isInScrollView: isInScrollView,
      isPressed: $isPressed
    )
    .listRowBackground(backgroundColor(isPressed).roundedCorner(enableRoundedCorners ? appearance.keyboardLayoutConfiguration.buttonCornerRadius : 0, corners: [.topLeft, .topRight]))
    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    .hideListRowSeparator()
  }
}

extension NumNineGridSymbolView {
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
}

struct NumNineGridSymbolView_Previews: PreviewProvider {
  static var previews: some View {
    NumNineGridSymbolView(
      appearance: HamsterKeyboardAppearance.preview,
      actionHandler: KeyboardInputViewController.preview.keyboardActionHandler,
      calloutContext: KeyboardCalloutContext.preview,
      width: 50,
      symbol: "+"
    )
  }
}
