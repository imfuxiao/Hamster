//
//  KeyboardUISettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import Combine
import HamsterUIKit
import UIKit

protocol KeyboardSettingsSubViewControllerFactory {
  func makeNumberNineGridSettingsViewController() -> NumberNineGridSettingsViewController
  func makeSymbolSettingsViewController() -> SymbolSettingsViewController
  func makeSymbolKeyboardSettingsViewController() -> SymbolKeyboardSettingsViewController
  func makeToolbarSettingsViewController() -> ToolbarSettingsViewController
}

public class KeyboardSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private let keyboardSettingsSubViewControllerFactory: KeyboardSettingsSubViewControllerFactory
  private let numberNineGridSettingsViewController: NumberNineGridSettingsViewController
  private let toolbarSettingsViewController: ToolbarSettingsViewController
  private let symbolSettingsViewController: SymbolSettingsViewController
  private let symbolKeyboardSettingsViewController: SymbolKeyboardSettingsViewController

  private var subscriptions = Set<AnyCancellable>()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel, keyboardSettingsSubViewControllerFactory: KeyboardSettingsSubViewControllerFactory) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel
    self.keyboardSettingsSubViewControllerFactory = keyboardSettingsSubViewControllerFactory

    self.numberNineGridSettingsViewController = keyboardSettingsSubViewControllerFactory.makeNumberNineGridSettingsViewController()
    self.toolbarSettingsViewController = keyboardSettingsSubViewControllerFactory.makeToolbarSettingsViewController()
    self.symbolSettingsViewController = keyboardSettingsSubViewControllerFactory.makeSymbolSettingsViewController()
    self.symbolKeyboardSettingsViewController = keyboardSettingsSubViewControllerFactory.makeSymbolKeyboardSettingsViewController()

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
    case .symbolKeyboard:
      presentSymbolKeyboardSettings()
    case .toolbar:
      presentToolbar()
    }
  }

  func presentNumberNineGridSettings() {
    navigationController?.pushViewController(numberNineGridSettingsViewController, animated: true)
  }

  func presentSymbolSettings() {
    navigationController?.pushViewController(symbolSettingsViewController, animated: true)
  }

  func presentSymbolKeyboardSettings() {
    navigationController?.pushViewController(symbolKeyboardSettingsViewController, animated: true)
  }

  func presentToolbar() {
    navigationController?.pushViewController(toolbarSettingsViewController, animated: true)
  }
}

// MARK: override UIViewController

public extension KeyboardSettingsViewController {
  override func loadView() {
    super.loadView()

    title = "键盘设置"
    view = KeyboardSettingsRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }
}
