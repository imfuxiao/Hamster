//
//  SymbolSettingsRootView.swift
//
//
//  Created by morse on 13/7/2023.
//

import Combine
import HamsterUIKit
import UIKit

class SymbolSettingsRootView: NibLessView {
  private var subscriptions = Set<AnyCancellable>()

  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  lazy var segmentedView: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: ["设置", "成对上屏", "光标居中", "返回主键盘"])
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.addTarget(
      keyboardSettingsViewModel,
      action: #selector(keyboardSettingsViewModel.symbolsSegmentedControlChange(_:)),
      for: .valueChanged
    )
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    return segmentedControl
  }()

  lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .secondarySystemBackground
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var symbolSettingView: SymbolSettingsView = {
    let view = SymbolSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  lazy var pairsOfSymbolsView: UIView = SymbolEditorView(
    headerTitle: "成对上屏符号列表",
    symbols: keyboardSettingsViewModel.pairsOfSymbols,
    symbolsDidSet: { [unowned self] in
      keyboardSettingsViewModel.pairsOfSymbols = $0
    },
    symbolTableIsEditingPublished: keyboardSettingsViewModel.$symbolTableIsEditing.eraseToAnyPublisher()
  )

  lazy var cursorBackOfSymbolsView: UIView = SymbolEditorView(
    headerTitle: "光标居中符号列表",
    symbols: keyboardSettingsViewModel.symbolsOfCursorBack,
    symbolsDidSet: { [unowned self] in
      keyboardSettingsViewModel.symbolsOfCursorBack = $0
    },
    symbolTableIsEditingPublished: keyboardSettingsViewModel.$symbolTableIsEditing.eraseToAnyPublisher()
  )

  lazy var symbolsOfReturnToMainKeyboardView: UIView = SymbolEditorView(
    headerTitle: "返回主键盘符号列表",
    symbols: keyboardSettingsViewModel.symbolsOfReturnToMainKeyboard,
    symbolsDidSet: { [unowned self] in
      keyboardSettingsViewModel.symbolsOfReturnToMainKeyboard = $0
    },
    symbolTableIsEditingPublished: keyboardSettingsViewModel.$symbolTableIsEditing.eraseToAnyPublisher()
  )

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)
  }

  // MARK: methods

  override func constructViewHierarchy() {
    backgroundColor = .secondarySystemBackground
    addSubview(segmentedView)
    addSubview(containerView)
  }

  override func activateViewConstraints() {
    NSLayoutConstraint.activate([
      segmentedView.topAnchor.constraint(equalToSystemSpacingBelow: safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
      segmentedView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      segmentedView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

      containerView.topAnchor.constraint(equalToSystemSpacingBelow: segmentedView.bottomAnchor, multiplier: 1.0),
      containerView.bottomAnchor.constraint(equalTo: CustomKeyboardLayoutGuideNoSafeArea.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  func presentTabView(_ tabIndex: Int) {
    switch tabIndex {
    case 0:
      changeTabView(tabView: symbolSettingView)
    case 1:
      changeTabView(tabView: pairsOfSymbolsView)
    case 2:
      changeTabView(tabView: cursorBackOfSymbolsView)
    case 3:
      changeTabView(tabView: symbolsOfReturnToMainKeyboardView)
    default:
      return
    }
  }

  private func changeTabView(tabView: UIView) {
    containerView.subviews.forEach { $0.removeFromSuperview() }

    containerView.addSubview(tabView)

    NSLayoutConstraint.activate([
      tabView.topAnchor.constraint(equalTo: containerView.topAnchor),
      tabView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      tabView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      tabView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
    ])
  }
}

extension SymbolSettingsRootView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()

    keyboardSettingsViewModel.selectedSegmentIndexOfSymbolsSettingPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentTabView($0)
      }
      .store(in: &subscriptions)
  }
}
