//
//  SwiftUIView.swift
//
//
//  Created by morse on 16/1/2023.
//

import IsScrolling
import KeyboardKit
import SwiftUI

@available(iOS 14, *)
struct HamsterAutocompleteToolbar: View {
  init(appearance: KeyboardAppearance, style: AutocompleteToolbarStyle, keyboardSize: Binding<CGSize>) {
    self.appearance = appearance as! HamsterKeyboardAppearance
    self.style = style
    self._keyboardSize = keyboardSize
  }

  let appearance: HamsterKeyboardAppearance
  let style: AutocompleteToolbarStyle
  @Binding var keyboardSize: CGSize
  @GestureState private var scrollingState = false

  @EnvironmentObject private var keyboardContext: KeyboardContext
  @EnvironmentObject private var appSettings: HamsterAppSettings
  @EnvironmentObject private var rimeContext: RimeContext
  @EnvironmentObject private var actionHandler: HamsterKeyboardActionHandler

  var foregroundColor: Color {
    guard let colorSchema = appearance.hamsterColorSchema else { return Color.standardButtonForeground(for: keyboardContext) }
    return colorSchema.candidateTextColor == .clear ? Color.standardButtonForeground(for: keyboardContext) : colorSchema.candidateTextColor
  }

  var backgroundColor: Color {
    guard let colorSchema = appearance.hamsterColorSchema else { return Color.standardDarkButtonBackground(for: keyboardContext) }
    return colorSchema.backColor == .clear ? Color.standardButtonForeground(for: keyboardContext) : colorSchema.backColor
  }

  // 候选栏下拉箭头
  var candidateBarView: some View {
    CandidateBarArrowButton(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      size: appSettings.candidateBarHeight,
      imageName: appSettings.candidateBarArrowButtonImageName,
      showDivider: appSettings.showDivider,
      action: {
        if rimeContext.suggestions.isEmpty {
          actionHandler.handle(.release, on: .dismissKeyboard)
          return
        }

        withAnimation {
          appSettings.keyboardStatus = appSettings.keyboardStatus == .normal ? .keyboardAreaToExpandCandidates : .normal
        }
      }
    )
    .opacity(showCandidateBarArrowButton ? 1 : 0)
  }

  // 是否显示候选栏按钮
  var showCandidateBarArrowButton: Bool {
    return appSettings.showKeyboardDismissButton || !rimeContext.suggestions.isEmpty || appSettings.keyboardStatus != .normal
  }

  // 水平候选区
  var hCandidateBar: some View {
    CandidateHStackView(appearance: appearance, style: style, suggestions: $rimeContext.suggestions, actionHandler: actionHandler)
      .padding(.leading, 2)
      .padding(.trailing, 50)
      .frame(height: appSettings.enableInputEmbeddedMode ? appSettings.candidateBarHeight : appSettings.candidateBarHeight - 10)
      .frame(minWidth: 0, maxWidth: .infinity)
  }

  // 水平候选区 测试版
  var hCandidateBarTest: some View {
    ScrollViewReader { scrollProxy in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHGrid(rows: [GridItem(.adaptive(minimum: 40))], spacing: 0) {
          ForEach(rimeContext.suggestions) { suggestion in
            CandidateView(
              appearance: appearance,
              style: style,
              padding: .init(top: 6, leading: 6, bottom: 6, trailing: 6),
              data: suggestion,
              actionHandler: actionHandler,
              isInScrollView: true
            )
            .id(suggestion.index)
            .padding(.horizontal, 5)
            .minimumScaleFactor(0.5)
          }
        }
      }
      .accessibilityAddTraits(.isButton)
      .padding(.trailing, 50)
      .padding(.top, 5)
      .frame(height: appSettings.enableInputEmbeddedMode ? appSettings.candidateBarHeight : appSettings.candidateBarHeight - 10)
      .frame(minWidth: 0, maxWidth: .infinity)
      .scrollStatusMonitor($actionHandler.isScrolling, monitorMode: .exclusion)
      .onChange(of: rimeContext.userInputKey, perform: { _ in
        scrollProxy.scrollTo(0)
      })
    }
  }

  // 纵向候选区
  var vCandidateBar: some View {
    CandidateVStackView(
      appearance: appearance,
      style: style,
      suggestions: $rimeContext.suggestions,
      actionHandler: actionHandler
    )
    .frame(width: keyboardSize.width - appSettings.candidateBarHeight, height: keyboardSize.height + appSettings.candidateBarHeight)
  }

  // 横向候选栏
  var horizontalCandidateBar: some View {
    VStack(alignment: .leading, spacing: 0) {
      // 拼写区域: 判断是否启用内嵌模式
      if !appSettings.enableInputEmbeddedMode {
        HStack {
          Text(rimeContext.userInputKey)
            .font(style.item.subtitleFont.font)
//            .foregroundColor(hamsterColor.hilitedTextColor.bgrColor ?? .primary)
            .foregroundColor(foregroundColor)
            .minimumScaleFactor(0.7)
          Spacer()
        }
        .padding(.leading, 5)
        .padding(.vertical, 1)
        .frame(height: 10)
      }

      hCandidateBar
    }
  }

  // 输入方案切换视图
  var switchInputSchemaView: some View {
    SelectInputSchemaView(
      appearance: appearance,
      keyboardSize: keyboardSize,
      schemas: appSettings.rimeTotalSchemas.filter { appSettings.rimeUserSelectSchema.contains($0) }
    )
    .frame(width: keyboardSize.width - appSettings.candidateBarHeight, height: keyboardSize.height + appSettings.candidateBarHeight)
  }

  var body: some View {
    // 候选区域
    ZStack(alignment: .topLeading) {
      // 横向候选栏
      horizontalCandidateBar
        .frame(height: appSettings.candidateBarHeight)
        .opacity(appSettings.keyboardStatus == .normal ? 1 : 0)
        .offset(y: -keyboardSize.height / 2)

      // 候选区箭头
      candidateBarView
        .frame(width: appSettings.candidateBarHeight, height: appSettings.candidateBarHeight)
        .offset(x: keyboardSize.width - appSettings.candidateBarHeight, y: appSettings.keyboardStatus == .keyboardAreaToExpandCandidates ? 0 : -keyboardSize.height / 2)

      // 纵向候选栏
      if appSettings.keyboardStatus == .keyboardAreaToExpandCandidates {
        vCandidateBar
      }

      // 输入方案切换
      if appSettings.keyboardStatus == .switchInputSchema {
        switchInputSchemaView
      }
    }
    .frame(width: keyboardSize.width, height: keyboardSize.height + appSettings.candidateBarHeight)
  }
}

struct AutocompleteToolbar_Previews: PreviewProvider {
  static var previews: some View {
    VStack {}
//    HamsterAutocompleteToolbar()
//      .preferredColorScheme(.dark)
//      .environmentObject(KeyboardContext.preview)
//      .environmentObject(RimeEngine.shared)
//      .environmentObject(AutocompleteContext())
//      .environmentObject(ActionCalloutContext.preview)
//      .environmentObject(InputCalloutContext.preview)
  }
}
