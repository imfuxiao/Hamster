//
//  SymbolKeyboard.swift
//  Hamster
//
//  Created by morse on 2023/5/30.
//

import KeyboardKit
import SwiftUI

/// 符号键盘
struct SymbolKeyboard: View {
  public init(
    layout: KeyboardLayout,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    calloutContext: KeyboardCalloutContext,
    keyboardContext: KeyboardContext,
    appSettings: HamsterAppSettings,
    width: CGFloat,
    height: CGFloat
  ) {
    Logger.shared.log.debug("SymbolKeyboard init")

    // 隐藏 List 滚动条

    UITableView.appearance().showsVerticalScrollIndicator = false

    // 键盘宽度
    self.keyboardWidth = width
    self.keyboardHegith = height
    self.inputWidth = 80

    self.actionHandler = actionHandler
    self.appearance = appearance as! HamsterKeyboardAppearance
    self.layout = layout
    self.layoutConfig = self.appearance.keyboardLayoutConfiguration

    self._keyboardContext = ObservedObject(wrappedValue: keyboardContext)
    self._calloutContext = ObservedObject(wrappedValue: calloutContext)
    self._appSettings = ObservedObject(wrappedValue: appSettings)

    // 返回键
    self.alphabeticButton = HamsterSystemKeyboardButtonRowItem(
      content: HamsterKeyboardButtonContent(
        action: .keyboardType(.alphabetic(.lowercased)),
        appearance: appearance,
        keyboardContext: keyboardContext
      ),
      item: .init(
        action: .keyboardType(.alphabetic(.lowercased)),
        size: .init(width: .input, height: layoutConfig.rowHeight),
        insets: layoutConfig.buttonInsets
      ),
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      keyboardWidth: keyboardWidth - inputWidth,
      inputWidth: inputWidth,
      appearance: appearance,
      customButtonStyle: true,
      customUseDarkMode: true
    )

    // 删除键
    self.backspaceButton = HamsterSystemKeyboardButtonRowItem(
      content: HamsterKeyboardButtonContent(
        action: .backspace,
        appearance: appearance,
        keyboardContext: keyboardContext
      ),
      item: .init(
        action: .backspace,
        size: .init(width: .input, height: layoutConfig.rowHeight),
        insets: layoutConfig.buttonInsets
      ),
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      calloutContext: calloutContext,
      keyboardWidth: keyboardWidth - inputWidth,
      inputWidth: inputWidth,
      appearance: appearance,
      customButtonStyle: true,
      customUseDarkMode: true
    )
  }

  private let actionHandler: KeyboardActionHandler
  private let appearance: HamsterKeyboardAppearance
  private let layout: KeyboardLayout
  private let layoutConfig: KeyboardLayoutConfiguration
  private let keyboardWidth: CGFloat
  private let keyboardHegith: CGFloat
  private let inputWidth: CGFloat
  private let alphabeticButton: HamsterSystemKeyboardButtonRowItem<HamsterKeyboardButtonContent>
  private let backspaceButton: HamsterSystemKeyboardButtonRowItem<HamsterKeyboardButtonContent>

  @ObservedObject private var keyboardContext: KeyboardContext
  @ObservedObject private var calloutContext: KeyboardCalloutContext
  @ObservedObject private var appSettings: HamsterAppSettings
  @State private var selectSymbolCategory: SymbolCategory = .frequent

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        VStack(spacing: 0) {
          ScrollViewReader { proxy in
            List {
              ForEach(Array(SymbolCategory.all.enumerated()), id: \.offset) { index, symbol in
                SymbolCategoryView(
                  keyboardContext: keyboardContext,
                  appearance: appearance,
                  scrollProxy: proxy,
                  width: inputWidth,
                  symbol: symbol.rawValue,
                  selectSymbolCategory: $selectSymbolCategory,
                  enableRoundedCorners: index == 0
                )
                .id(symbol.rawValue)
              }
            }
            .clipped()
            .cornerRadius(5)
            .background(
              RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 5)
                  .fill(darkBackgroundColor))
            )
            .listStyle(.plain)
            .padding(layoutConfig.buttonInsets)
          }
        }
        .frame(width: inputWidth, height: keyboardHegith - layoutConfig.rowHeight)

        VStack(spacing: 0) {
          SymbolStackView(appearance: appearance, appSettings: appSettings, style: .standard, symbols: selectSymbolCategory.symbols, actionHandler: actionHandler)
            .frame(width: keyboardWidth - inputWidth, height: keyboardHegith - layoutConfig.rowHeight)
        }
      }

      // 底部栏
      HStack(spacing: 0) {
        // 返回键
        self.alphabeticButton

        Spacer()

        Button {
          withAnimation {
            appSettings.symbolKeyboardLockState.toggle()
          }
        } label: {
          Color.clearInteractable.overlay(
            Image(systemName: appSettings.symbolKeyboardLockState ? "lock" : "lock.open")
              .contentShape(Rectangle())
          )
        }
        .buttonStyle(.plain)

        Spacer()

        // 回退键
        self.backspaceButton
      }
      .frame(width: keyboardWidth, height: layoutConfig.rowHeight)
    }
  }
}

extension SymbolKeyboard {
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

struct SymbolCategoryView: View {
  init(
    keyboardContext: KeyboardContext,
    appearance: HamsterKeyboardAppearance,
    scrollProxy: ScrollViewProxy,
    width: CGFloat,
    symbol: String,
    selectSymbolCategory: Binding<SymbolCategory>,
    enableRoundedCorners: Bool = false
  ) {
    self.keyboardContext = keyboardContext
    self.appearance = appearance
    self.scrollProxy = scrollProxy
    self.width = width
    self.symbol = symbol
    self._symbolCategory = selectSymbolCategory
    self.enableRoundedCorners = enableRoundedCorners
  }

  let keyboardContext: KeyboardContext
  let appearance: HamsterKeyboardAppearance
  let scrollProxy: ScrollViewProxy
  let width: CGFloat
  let symbol: String
  private let enableRoundedCorners: Bool
  @Binding var symbolCategory: SymbolCategory
  @State private var isPressed: Bool = false

  @EnvironmentObject var appSettings: HamsterAppSettings

  var body: some View {
    Button {
      if let symboleCategory = SymbolCategory(rawValue: symbol) {
        self.symbolCategory = symboleCategory
        withAnimation {
          scrollProxy.scrollTo(symbol, anchor: .center)
        }
      }
    } label: {
      VStack(alignment: .center, spacing: 0) {
        Spacer()
        HStack(alignment: .center, spacing: 0) {
          Text(KKL10n.hamsterText(forKey: symbol, locale: keyboardContext.locale))
            .font(.system(size: 16))
        }
        Spacer()
        Divider()
      }
      .foregroundColor(foregroundColor)
      .frame(width: width, height: 45)
    }
    .buttonStyle(ListButtonStyle(isPressing: $isPressed))
    .listRowBackground(
      backgroundColor(isPressed)
        .roundedCorner(
          enableRoundedCorners ? appearance.keyboardLayoutConfiguration.buttonCornerRadius : 0,
          corners: [.topLeft, .topRight]
        ))
    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    .hideListRowSeparator()
    .contentShape(Rectangle())
  }
}

struct ListButtonStyle: ButtonStyle {
  @Binding var isPressing: Bool

  @ViewBuilder
  func makeBody(configuration: Configuration) -> some View {
    configuration
      .label
      .onChange(of: configuration.isPressed) {
        isPressing = $0
      }
  }
}

extension SymbolCategoryView {
  var foregroundColor: Color {
    guard let colorSchema = appearance.hamsterColorSchema else { return .primary }
    return colorSchema.candidateTextColor == .clear ? .primary : colorSchema.candidateTextColor
  }

  func backgroundColor(_ isPressed: Bool) -> Color {
    if isPressed {
      return Color.white
    }
    guard let colorSchema = appearance.hamsterColorSchema else {
      if symbol == symbolCategory.rawValue {
        return Color.gray.opacity(0.3)
      }
      return Color.clear
    }
    if symbol == symbolCategory.rawValue {
      return colorSchema.backColor.opacity(0.3)
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

/// 符号堆显示
struct SymbolStackView: View {
  init(appearance: HamsterKeyboardAppearance, appSettings: HamsterAppSettings, style: AutocompleteToolbarStyle, symbols: [Symbol], actionHandler: KeyboardActionHandler) {
    self.appearance = appearance
    self.appSettings = appSettings
    self.style = style
    self.symbols = symbols
    self.actionHandler = actionHandler

    // 计算最长符号的宽度
    let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(20))]
    let symbol = symbols.max(by: { $0.char.count < $1.char.count })?.char ?? ""
    let font = (symbol as NSString).size(withAttributes: fontAttributes)
    let size = max(font.width, font.height)
    self.cellSize = CGSize(width: size + 10, height: font.height)
    Logger.shared.log.debug("maxSymbol: \(symbol), cellSize: \(cellSize)")
  }

  let appearance: HamsterKeyboardAppearance
  let appSettings: HamsterAppSettings
  let style: AutocompleteToolbarStyle
  let cellSize: CGSize
  var symbols: [Symbol]
  var actionHandler: KeyboardActionHandler

  @EnvironmentObject var rimeContext: RimeContext

  var body: some View {
    CollectionView(
      collection: self.symbols,
      scrollDirection: .vertical,
      contentSize: .fixed(cellSize),
      itemSpacing: .init(mainAxisSpacing: 20, crossAxisSpacing: 0),
      rawCustomize: { collectionView in
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentOffset.y = 0

        if let layout = collectionView.collectionViewLayout as? SeparatorCollectionViewFlowLayout {
          layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
          layout.minimumLineSpacing = 1
          collectionView.collectionViewLayout = layout
        }
      },
      contentForData: {
        SymbolView(
          appearance: appearance,
          style: style,
          padding: .init(),
          data: $0,
          actionHandler: actionHandler,
          isInScrollView: true
        )
        .contentShape(Rectangle())
      },
      selectItemBuilder: {
        let data = $0
        let action = KeyboardAction.custom(named: "#selectSymbol\(data.char)")
        self.actionHandler.handle(.press, on: action)
        self.actionHandler.handle(.release, on: action)
        SymbolCategory.frequentSymbolProvider.registerSymbol(data)
        if !appSettings.symbolKeyboardLockState {
          self.actionHandler.handle(.release, on: .keyboardType(.alphabetic(.lowercased)))
        }
      }
    )
  }
}

struct SymbolView: View {
  init(
    appearance: HamsterKeyboardAppearance,
    style: AutocompleteToolbarStyle,
    padding: EdgeInsets,
    data: Symbol,
    actionHandler: KeyboardActionHandler,
    isInScrollView: Bool = false
  ) {
    self.appearance = appearance
    self.data = data
    self.style = style
    self.padding = padding
    self.actionHandler = actionHandler
    self.isInScrollView = isInScrollView
  }

  let appearance: HamsterKeyboardAppearance
  let style: AutocompleteToolbarStyle
  let padding: EdgeInsets
  let data: Symbol
  private let actionHandler: KeyboardActionHandler
  private let isInScrollView: Bool

  @State private var isPressed: Bool = false
  @EnvironmentObject var keyboardContext: KeyboardContext
  @EnvironmentObject var appSettings: HamsterAppSettings

  var foregroundColor: Color {
    guard let colorSchema = appearance.hamsterColorSchema else { return .primary }
    return colorSchema.candidateTextColor == .clear ? .primary : colorSchema.candidateTextColor
  }

//  var backgroundColor: Color {
//    guard let colorSchema = appearance.hamsterColorSchema else { return .clear }
//    return colorSchema.hilitedCandidateBackColor
//  }

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      Text(data.char)
        .font(.system(size: 20))
        .foregroundColor(foregroundColor)
    }
    .padding(padding)
    .background(Color.clearInteractable)
    .cornerRadius(style.autocompleteBackground.cornerRadius)
    .background(Color.clearInteractable)
  }
}
