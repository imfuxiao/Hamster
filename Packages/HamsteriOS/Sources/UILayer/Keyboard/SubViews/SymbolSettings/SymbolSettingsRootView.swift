//
//  SymbolSettingsRootView.swift
//
//
//  Created by morse on 13/7/2023.
//

import Combine
import HamsterUIKit
import ProgressHUD
import UIKit

class SymbolSettingsRootView: NibLessView {
  private var subscriptions = Set<AnyCancellable>()

  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  lazy var segmentedView: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: ["成对上屏", "光标居中", "返回主键盘"])
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.addTarget(
      keyboardSettingsViewModel,
      action: #selector(keyboardSettingsViewModel.symbolsSegmentedControlChange(_:)),
      for: .valueChanged
    )
    return segmentedControl
  }()

  lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .secondarySystemBackground
    return view
  }()

//  lazy var symbolSettingView: SymbolSettingsView = {
//    let view = SymbolSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
//    return view
//  }()

  lazy var pairsOfSymbolsView: UIView = SymbolEditorView(
    getSymbols: { [unowned self] in keyboardSettingsViewModel.pairsOfSymbols },
    symbolsDidSet: { [unowned self] in
      keyboardSettingsViewModel.pairsOfSymbols = $0
    },
    symbolTableIsEditingPublished: keyboardSettingsViewModel.$symbolTableIsEditing.eraseToAnyPublisher(),
    reloadDataPublished: keyboardSettingsViewModel.resetSignPublished,
    needRestButton: true,
    restButtonAction: { [unowned self] in
      guard let defaultConfiguration = HamsterAppDependencyContainer.shared.defaultConfiguration else {
        throw "未找到系统默认配置"
      }
      guard let defaultOfSymbols = defaultConfiguration.keyboard?.pairsOfSymbols else {
        throw "未找到默认值"
      }
      keyboardSettingsViewModel.pairsOfSymbols = defaultOfSymbols
      keyboardSettingsViewModel.resetSignSubject.send(true)
    }
  )

  lazy var cursorBackOfSymbolsView: UIView = SymbolEditorView(
    getSymbols: { [unowned self] in keyboardSettingsViewModel.symbolsOfCursorBack },
    symbolsDidSet: { [unowned self] in
      keyboardSettingsViewModel.symbolsOfCursorBack = $0
    },
    symbolTableIsEditingPublished: keyboardSettingsViewModel.$symbolTableIsEditing.eraseToAnyPublisher(),
    reloadDataPublished: keyboardSettingsViewModel.resetSignPublished,
    needRestButton: true,
    restButtonAction: { [unowned self] in
      guard let defaultConfiguration = HamsterAppDependencyContainer.shared.defaultConfiguration else {
        throw "未找到系统默认配置"
      }
      guard let defaultOfSymbols = defaultConfiguration.keyboard?.symbolsOfCursorBack else {
        throw "未找到默认值"
      }
      keyboardSettingsViewModel.symbolsOfCursorBack = defaultOfSymbols
      keyboardSettingsViewModel.resetSignSubject.send(true)
    }
  )

  lazy var symbolsOfReturnToMainKeyboardView: UIView = SymbolEditorView(
    getSymbols: { [unowned self] in keyboardSettingsViewModel.symbolsOfReturnToMainKeyboard },
    symbolsDidSet: { [unowned self] in
      keyboardSettingsViewModel.symbolsOfReturnToMainKeyboard = $0
    },
    symbolTableIsEditingPublished: keyboardSettingsViewModel.$symbolTableIsEditing.eraseToAnyPublisher(),
    reloadDataPublished: keyboardSettingsViewModel.resetSignPublished,
    needRestButton: true,
    restButtonAction: { [unowned self] in
      guard let defaultConfiguration = HamsterAppDependencyContainer.shared.defaultConfiguration else {
        throw "未找到系统默认配置"
      }
      guard let defaultOfSymbols = defaultConfiguration.keyboard?.symbolsOfReturnToMainKeyboard else {
        throw "未找到默认值"
      }
      keyboardSettingsViewModel.symbolsOfReturnToMainKeyboard = defaultOfSymbols
      keyboardSettingsViewModel.resetSignSubject.send(true)
    }
  )

  // MARK: methods

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)

    setupSubview()

    keyboardSettingsViewModel.symbolSettingsSubviewPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentTabView($0)
      }
      .store(in: &subscriptions)
  }

  func setupSubview() {
    backgroundColor = .secondarySystemBackground
    addSubview(segmentedView)
    addSubview(containerView)

    segmentedView.translatesAutoresizingMaskIntoConstraints = false
    containerView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      segmentedView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      segmentedView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      segmentedView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

      containerView.topAnchor.constraint(equalToSystemSpacingBelow: segmentedView.bottomAnchor, multiplier: 1.0),
      containerView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  func presentTabView(_ tabIndex: Int) {
    switch tabIndex {
    case 0:
      changeTabView(tabView: pairsOfSymbolsView)
    case 1:
      changeTabView(tabView: cursorBackOfSymbolsView)
    case 2:
      changeTabView(tabView: symbolsOfReturnToMainKeyboardView)
    default:
      return
    }
  }

  private func changeTabView(tabView: UIView) {
    containerView.subviews.forEach { $0.removeFromSuperview() }

    containerView.addSubview(tabView)
    tabView.fillSuperview()
  }
}
