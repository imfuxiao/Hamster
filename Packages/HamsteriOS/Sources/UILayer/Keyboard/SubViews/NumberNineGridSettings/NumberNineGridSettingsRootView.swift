//
//  NumberNineGridSettingsRootView.swift
//
//
//  Created by morse on 13/7/2023.
//

import Combine
import HamsterUIKit
import UIKit

class NumberNineGridSettingsRootView: NibLessView {
  // MARK: properties

  private var subscriptions = Set<AnyCancellable>()

  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  lazy var settingsView: UIView = NumberNineGridSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)

  lazy var symbolsView: UIView = SymbolEditorView(
    headerTitle: "自定义数字九宫格左侧划动符号栏",
    getSymbols: { [unowned self] in keyboardSettingsViewModel.symbolsOfGridOfNumericKeyboard },
    symbolsDidSet: { [unowned self] in
      keyboardSettingsViewModel.symbolsOfGridOfNumericKeyboard = $0
    },
    symbolTableIsEditingPublished: keyboardSettingsViewModel.$symbolTableIsEditing.eraseToAnyPublisher(),
    reloadDataPublished: keyboardSettingsViewModel.resetSignPublished
  )

  // MARK: methods

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)

    combine()
  }

  func presentTabView(_ view: NumberNineGridTabView) {
    switch view {
    case .settings:
      presentTabView(settingsView)
    case .symbols:
      presentTabView(symbolsView)
    }
  }

  private func presentTabView(_ tabView: UIView) {
    subviews.forEach { $0.removeFromSuperview() }
    addSubview(tabView)
    tabView.fillSuperview()
  }

  func combine() {
    keyboardSettingsViewModel.numberNineGridSubviewSwitchPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentTabView($0)
      }
      .store(in: &subscriptions)
  }
}
