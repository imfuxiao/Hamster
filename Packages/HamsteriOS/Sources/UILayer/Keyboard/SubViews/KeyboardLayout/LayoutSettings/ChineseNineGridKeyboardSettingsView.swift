//
//  ChineseNineGridKeyboardSettingsView.swift
//
//
//  Created by morse on 2023/9/14.
//

import HamsterUIKit
import UIKit

/// 中文九宫格键盘布局设置
class ChineseNineGridKeyboardSettingsView: NibLessView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  lazy var symbolsView: UIView = SymbolEditorView(
    headerTitle: "左侧划动符号栏",
    getSymbols: { [unowned self] in keyboardSettingsViewModel.symbolsOfChineseNineGridKeyboard },
    symbolsDidSet: { [unowned self] in
      keyboardSettingsViewModel.symbolsOfChineseNineGridKeyboard = $0
    },
    symbolTableIsEditingPublished: keyboardSettingsViewModel.$symbolsOfChineseNineGridIsEditing.eraseToAnyPublisher(),
    reloadDataPublished: keyboardSettingsViewModel.resetSignPublished,
    needRestButton: true,
    restButtonAction: { [unowned self] in
      guard let defaultConfiguration = HamsterAppDependencyContainer.shared.defaultConfiguration else {
        throw "未找到系统默认配置"
      }
      guard let defaultPairsOfSymbols = defaultConfiguration.keyboard?.symbolsOfChineseNineGridKeyboard else {
        throw "未找到默认值"
      }
      keyboardSettingsViewModel.symbolsOfChineseNineGridKeyboard = defaultPairsOfSymbols
      keyboardSettingsViewModel.resetSignSubject.send(true)
    }
  )

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: .zero)

    backgroundColor = .secondarySystemBackground
    addSubview(symbolsView)
    symbolsView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      symbolsView.topAnchor.constraint(equalTo: topAnchor),
      symbolsView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
      symbolsView.leadingAnchor.constraint(equalTo: leadingAnchor),
      symbolsView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}
