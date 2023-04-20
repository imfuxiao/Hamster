//
//  HamsterKeyboard.swift
//  HamsterKeyboard
//
//  Created by morse on 20/4/2023.
//

import KeyboardKit
import SwiftUI

/// 键盘状态
enum HamsterKeyboardStatus: Equatable {
  /// 正常情况, 即只显示键盘
  case normal
  /// 键盘区域展开候选文字
  case KeyboardAreaToExpandCandidates
  /// 键盘区域调节高度
  case KeyboardAreaAdjustmentHeight
}

@available(iOS 14, *)
struct HamsterKeyboard: View {
  weak var ivc: HamsterKeyboardViewController?
  let style: AutocompleteToolbarStyle
  let keyboardLayout: KeyboardLayout

  @State var hamsterKeyboardSize: CGSize

  // MARK: 自身状态变量

  // 键盘当前状态
  @State var keyboardStatus: HamsterKeyboardStatus = .normal

  // MARK: 依赖注入

  @EnvironmentObject
  private var keyboardCalloutContext: KeyboardCalloutContext

  @EnvironmentObject
  private var keyboardContext: KeyboardContext

  @EnvironmentObject
  private var rimeEngine: RimeEngine

  @EnvironmentObject
  private var appSettings: HamsterAppSettings

  @Environment(\.openURL) var openURL

  init(keyboardInputViewController ivc: HamsterKeyboardViewController) {
    Logger.shared.log.debug("AlphabetKeyboard init")
    weak var keyboardViewController = ivc
    self.ivc = keyboardViewController
    self.style = AutocompleteToolbarStyle(
      item: AutocompleteToolbarItemStyle(
        titleFont: .system(
          size: CGFloat(ivc.appSettings.rimeCandidateTitleFontSize)
        ),
        titleColor: .primary,
        subtitleFont: .system(
          size: CGFloat(ivc.appSettings.rimeCandidateCommentFontSize)
        )
      ),
      autocompleteBackground: .init(cornerRadius: 5)
    )

    self.keyboardLayout = ivc.keyboardLayoutProvider.keyboardLayout(for: ivc.keyboardContext)

    // 键盘总高度
    let height = Double(keyboardLayout.itemRows.count) *
      keyboardLayout.idealItemHeight
      + keyboardLayout.idealItemInsets.top + keyboardLayout.idealItemInsets.bottom + 40
    Logger.shared.log.debug("keyboard height \(height)")

    self._hamsterKeyboardSize = State(initialValue: CGSize(width: 0, height: height))
  }

  var hamsterColor: ColorSchema {
    rimeEngine.currentColorSchema
  }

  var backgroundColor: Color {
    return hamsterColor.backColor ?? Color.standardKeyboardBackground
  }

  var body: some View {
    ZStack {
      // 正常键盘状态
      if keyboardStatus == .normal, let ivc = ivc {
        AlphabetKeyboard(keyboardInputViewController: ivc, keyboardStatus: $keyboardStatus)
          .frame(height: hamsterKeyboardSize.height)
      }

      // 全区域展示候选键盘
      if keyboardStatus == .KeyboardAreaToExpandCandidates {
        HStack(alignment: .top, spacing: 0) {
          // 纵向候选区
          CandidateVStackView(style: style, hamsterColor: hamsterColor, suggestions: $rimeEngine.suggestions) { [weak ivc] item in
            guard let ivc = ivc else { return }
            ivc.selectCandidateIndex(index: item.index)
            keyboardStatus = .normal
          }
          .frame(height: hamsterKeyboardSize.height)
          .background(backgroundColor)
          .transition(.move(edge: .top).combined(with: .opacity))

          VStack(alignment: .center, spacing: 0) {
            // 收起按钮
            CandidateBarArrowButton(hamsterColor: hamsterColor, keyboardStatus: keyboardStatus, action: {
              withAnimation(.linear) {
                keyboardStatus = .normal
              }
            })
            Spacer()
            // TODO: 这里可以增加删除按钮
            // Image.keyboardBackspace
          }
        }
        .transition(.move(edge: .top))
        .background(backgroundColor)
      }
    }
  }

  // 键盘大小连动
  struct KeyboardSizeGeometryPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
      value = nextValue()
    }

    typealias Value = CGSize
  }
}
