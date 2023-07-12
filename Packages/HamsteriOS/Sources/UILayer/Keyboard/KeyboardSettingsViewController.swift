//
//  KeyboardUISettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import Combine
import HamsterUIKit
import UIKit

protocol KeyboardSettingsViewModelFactory {
  func makeKeyboardSettingsViewModel() -> KeyboardSettingsViewModel
}

protocol KeyboardSettingsSubViewControllerFactory {
  func makeNumberNineGridSettingsViewController() -> NumberNineGridSettingsViewController
  func makeSymbolSettingsViewController() -> SymbolSettingsViewController
  func makeToolbarSettingsViewController() -> ToolbarSettingsViewController
}

class KeyboardSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private let keyboardSettingsViewModelFactory: KeyboardSettingsViewModelFactory
  private let keyboardSettingsSubViewControllerFactory: KeyboardSettingsSubViewControllerFactory

  private var subscriptions = Set<AnyCancellable>()

  init(keyboardSettingsViewModelFactory: KeyboardSettingsViewModelFactory, keyboardSettingsSubViewControllerFactory: KeyboardSettingsSubViewControllerFactory) {
    self.keyboardSettingsViewModelFactory = keyboardSettingsViewModelFactory
    self.keyboardSettingsSubViewControllerFactory = keyboardSettingsSubViewControllerFactory

    self.keyboardSettingsViewModel = keyboardSettingsViewModelFactory.makeKeyboardSettingsViewModel()

    super.init()

    keyboardSettingsViewModel.subViewPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentSubView(keyboardSettingsSubView: $0)
      }
      .store(in: &subscriptions)
  }

  func presentSubView(keyboardSettingsSubView: KeyboardSettingsSubView) {
    switch keyboardSettingsSubView {
    case .numberNineGrid:
      presentNumberNineGridSettings()
    case .symbols:
      presentSymbolSettings()
    case .toolbar:
      presentToolbar()
    }
  }

  func presentNumberNineGridSettings() {
    let controller = keyboardSettingsSubViewControllerFactory.makeNumberNineGridSettingsViewController()
    navigationController?.pushViewController(controller, animated: true)
  }

  func presentSymbolSettings() {
    let controller = keyboardSettingsSubViewControllerFactory.makeSymbolSettingsViewController()
    navigationController?.pushViewController(controller, animated: true)
  }

  func presentToolbar() {
    let controller = keyboardSettingsSubViewControllerFactory.makeToolbarSettingsViewController()
    navigationController?.pushViewController(controller, animated: true)
  }
}

// MARK: override UIViewController

extension KeyboardSettingsViewController {
  override func loadView() {
    super.loadView()

    title = "键盘设置"
    let keyboardSettingsViewModel = keyboardSettingsViewModelFactory.makeKeyboardSettingsViewModel()
    view = KeyboardSettingsRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }
}
