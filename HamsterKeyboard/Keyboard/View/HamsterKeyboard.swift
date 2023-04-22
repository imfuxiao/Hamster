//
//  HamsterKeyboard.swift
//  HamsterKeyboard
//
//  Created by morse on 20/4/2023.
//

import KeyboardKit
import SwiftUI

/// Hamster键盘
@available(iOS 14, *)
struct HamsterKeyboard: View {
  weak var ivc: HamsterKeyboardViewController?
  var style: AutocompleteToolbarStyle
  var keyboardLayout: KeyboardLayout

  // MARK: 自身状态变量

  // 键盘尺寸
  @State var hamsterKeyboardSize: CGSize

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
    Logger.shared.log.debug("HamsterKeyboard init")
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

    // 计算键盘总高度
    let height = Double(keyboardLayout.itemRows.count)
      * keyboardLayout.idealItemHeight
      + keyboardLayout.idealItemInsets.top
      + keyboardLayout.idealItemInsets.bottom
      + (ivc.appSettings.enableInputEmbeddedMode ? 40 : 50)

    Logger.shared.log.debug("keyboard idealItemHeight \(keyboardLayout.idealItemHeight)")
    Logger.shared.log.debug("keyboard idealItemInsets.top \(keyboardLayout.idealItemInsets.top)")
    Logger.shared.log.debug("keyboard idealItemInsets.bottom \(keyboardLayout.idealItemInsets.bottom)")
    Logger.shared.log.debug("keyboard total height \(height)")

    self._hamsterKeyboardSize = State(initialValue: CGSize(width: 0, height: height))
  }

  var hamsterColor: ColorSchema {
    rimeEngine.currentColorSchema
  }

  var backgroundColor: Color {
    return hamsterColor.backColor ?? Color.standardKeyboardBackground
  }

  // 全键盘展示候选字
  var expandCandidatesView: some View {
    ExpandCandidatesView(style: style) { [weak ivc] item in
      guard let ivc = ivc else { return }
      ivc.selectCandidateIndex(index: item.index)
      appSettings.keyboardStatus = .normal
    }
  }

  // 输入方案切换视图
  var switchInputSchemaView: some View {
    SelectInputSchemaView(
      hamsterKeyboardSize: hamsterKeyboardSize,
      hamsterColor: hamsterColor,
      schemas: rimeEngine.getSchemas()
    )
  }

  var body: some View {
    ZStack {
      // 正常键盘状态
      if appSettings.keyboardStatus == .normal {
        AlphabetKeyboard(
          keyboardInputViewController: ivc ?? NextKeyboardController.shared as! HamsterKeyboardViewController
        )
        .frame(height: hamsterKeyboardSize.height)
      }

      // 全区域展示候选键盘
      if appSettings.keyboardStatus == .keyboardAreaToExpandCandidates {
        expandCandidatesView
          .frame(height: hamsterKeyboardSize.height)
      }

      // 输入方案切换视图
      if appSettings.keyboardStatus == .switchInputSchema {
        switchInputSchemaView
          .foregroundColor(hamsterColor.candidateTextColor ?? Color.standardButtonForeground(for: keyboardContext))
          .frame(height: hamsterKeyboardSize.height)
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

/// 切换输入方案视图
struct SelectInputSchemaView: View {
  var hamsterKeyboardSize: CGSize
  var hamsterColor: ColorSchema
  var schemas: [Schema]

  var backgroundColor: Color {
    return hamsterColor.backColor ?? Color.standardKeyboardBackground
  }

  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var rimeEngine: RimeEngine

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      CollectionView(
        collection: schemas,
        scrollDirection: .vertical,
        contentSize: .crossAxisFilled(mainAxisLength: 60),
        itemSpacing: .init(mainAxisSpacing: 0, crossAxisSpacing: 0),
        rawCustomize: { collectionView in
          collectionView.showsHorizontalScrollIndicator = false
          collectionView.showsVerticalScrollIndicator = false
          collectionView.contentOffset.x = .zero
        },
        contentForData: {
          InputSchemaCell(schema: $0, isSelect: appSettings.rimeInputSchema == $0.schemaId, showDivider: false, action: {
            appSettings.rimeInputSchema = $0.schemaId
            let handled = rimeEngine.setSchema($0.schemaId)
            Logger.shared.log.debug("switch input schema: \($0.schemaId), handled: \(handled)")
            rimeEngine.reset()
            appSettings.keyboardStatus = .normal
          })
        }
      )
      .frame(height: hamsterKeyboardSize.height)

      // 收起按钮
      CandidateBarArrowButton(hamsterColor: hamsterColor, action: {
        appSettings.keyboardStatus = .normal
      })
    }
    .frame(minWidth: 0, maxWidth: .infinity)
    .frame(height: hamsterKeyboardSize.height)
    .background(backgroundColor)
  }
}
