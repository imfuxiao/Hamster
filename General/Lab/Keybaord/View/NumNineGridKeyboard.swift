//
//  NumNineGridKeyboard.swift
//  HamsterKeyboard
//
//  Created by morse on 2023/5/24.
//

import KeyboardKit
import SwiftUI

struct NumNineGridKeyboard<ButtonView: View>: View {
  public init(
    layout: KeyboardLayout,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    calloutContext: KeyboardCalloutContext,
    keyboardContext: KeyboardContext,
    appSettings: HamsterAppSettings,
    width: CGFloat,
    height: CGFloat
  ) where ButtonView == HamsterSystemKeyboardButtonRowItem<HamsterKeyboardButtonContent> {
    Logger.shared.log.debug("NumNineGridKeyboard init")
    
    // 隐藏 List 滚动条
    
    UITableView.appearance().showsVerticalScrollIndicator = false
    
    // 键盘宽度
    self.keyboardWidth = width
    self.keyboardHegith = height
    self.inputWidth = layout.inputWidth(for: keyboardWidth)
    
    self.actionHandler = actionHandler
    self.appearance = appearance as! HamsterKeyboardAppearance
    self.layout = layout
    let layoutConfig = self.appearance.keyboardLayoutConfiguration
    self.buttonInsets = .init(
      top: layoutConfig.buttonInsets.leading,
      leading: layoutConfig.buttonInsets.leading,
      bottom: layoutConfig.buttonInsets.trailing,
      trailing: layoutConfig.buttonInsets.trailing
    )
    
    self._keyboardContext = ObservedObject(wrappedValue: keyboardContext)
    self._calloutContext = ObservedObject(wrappedValue: calloutContext)
    self._appSettings = ObservedObject(wrappedValue: appSettings)
    self.buttonView = { isLastItem, item, keyboardWidth, inputWidth in
      HamsterSystemKeyboardButtonRowItem(
        content: HamsterKeyboardButtonContent(
          action: item.action,
          appearance: appearance,
          keyboardContext: keyboardContext
        ),
        item: item,
        actionHandler: actionHandler,
        keyboardContext: keyboardContext,
        calloutContext: calloutContext,
        keyboardWidth: keyboardWidth,
        inputWidth: inputWidth,
        appearance: appearance,
        customButtonStyle: true,
        customUseDarkMode: isLastItem
      )
    }
    
    // 返回键
    self.alphabeticButton = HamsterSystemKeyboardButtonRowItem(
      content: HamsterKeyboardButtonContent(
        action: .keyboardType(.alphabetic(.lowercased)),
        appearance: appearance,
        keyboardContext: keyboardContext
      ),
      item: .init(
        action: .keyboardType(.alphabetic(.lowercased)),
        size: .init(width: .available, height: layoutConfig.rowHeight),
        insets: buttonInsets
      ),
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      keyboardWidth: keyboardWidth,
      inputWidth: inputWidth,
      appearance: appearance,
      customButtonStyle: true,
      customUseDarkMode: true
    )
  }
  
  private let actionHandler: KeyboardActionHandler
  private let appearance: HamsterKeyboardAppearance
  private let layout: KeyboardLayout
  private let buttonInsets: EdgeInsets
  private let buttonView: ButtonViewBuilder
  
  public typealias KeyboardWidth = CGFloat
  public typealias KeyboardItemWidth = CGFloat
  public typealias darkModeItem = Bool
  public typealias ButtonViewBuilder = (darkModeItem, KeyboardLayoutItem, KeyboardWidth, KeyboardItemWidth) -> ButtonView
  
  private let keyboardWidth: CGFloat
  private let keyboardHegith: CGFloat
  private let inputWidth: CGFloat
  private let alphabeticButton: HamsterSystemKeyboardButtonRowItem<HamsterKeyboardButtonContent>
  
  @ObservedObject private var keyboardContext: KeyboardContext
  @ObservedObject private var calloutContext: KeyboardCalloutContext
  @ObservedObject private var appSettings: HamsterAppSettings
  
  var body: some View {
    HStack(spacing: 0) {
      VStack(spacing: 0) {
        List {
          ForEach(Array(appSettings.numberNineGridSymbols.enumerated()), id: \.offset) { index, symbol in
            if !symbol.isEmpty {
              NumNineGridSymbolView(
                appearance: appearance,
                actionHandler: actionHandler,
                calloutContext: calloutContext,
                width: inputWidth,
                symbol: symbol,
                enableRoundedCorners: index == 0
              )
            }
          }
          // TODO: 点击跳转app中设置
        }
        .listStyle(.plain)
        .clipped()
        .cornerRadius(5)
        .background(
          RoundedRectangle(cornerRadius: 5)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            .background(RoundedRectangle(cornerRadius: 5).fill(darkBackgroundColor))
        )
        .padding(self.buttonInsets)
        .environment(\.defaultMinListRowHeight, 10)

        // 返回键
        self.alphabeticButton
      }
      .frame(width: inputWidth, height: keyboardHegith)
      
      VStack(spacing: 0) {
        itemRows(for: layout)
      }
      .frame(width: keyboardWidth - inputWidth, height: keyboardHegith)
    }
    .padding(appearance.keyboardEdgeInsets)
  }
}

extension NumNineGridKeyboard {
  var backgroundColor: Color {
    if appSettings.enableRimeColorSchema, let backColor = appearance.hamsterColorSchema?.backColor, backColor != Color.clear {
      return backColor
    }
    return Color.hamsterStandardButtonBackground(for: keyboardContext)
  }
  
  var darkBackgroundColor: Color {
    if appSettings.enableRimeColorSchema, let backColor = appearance.hamsterColorSchema?.backColor, backColor != Color.clear {
      return backColor
    }
    return Color.hamsterStandardDarkButtonBackground(for: keyboardContext)
  }
  
  var foregroundColor: Color {
    if appSettings.enableRimeColorSchema, let foregroundColor = appearance.hamsterColorSchema?.candidateTextColor, foregroundColor != Color.clear {
      return foregroundColor
    }
    return Color.hamsterStandardButtonForeground(for: keyboardContext)
  }
}

extension NumNineGridKeyboard {
  func itemRows(for layout: KeyboardLayout) -> some View {
    ForEach(Array(layout.itemRows.enumerated()), id: \.offset) {
      items(for: layout, itemRow: $0.element)
    }
  }
  
  func items(for layout: KeyboardLayout, itemRow: KeyboardLayoutItemRow) -> some View {
    let items = Array(itemRow.enumerated())
    return HStack(spacing: 0) {
      ForEach(items, id: \.offset) { index, element in
        if element.action == .none {
          EmptyView()
        } else {
          buttonView(index + 1 == items.count, element, keyboardWidth - inputWidth, inputWidth)
        }
      }
    }
  }
}

// struct NumNineGridKeyboard_Previews: PreviewProvider {
//  static var previews: some View {
//    NumNineGridKeyboard()
//  }
// }
