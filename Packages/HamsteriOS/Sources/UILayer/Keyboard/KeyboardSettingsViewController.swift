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
  func makeKeyboardLayoutViewController() -> KeyboardLayoutViewController
  func makeSpaceSettingsViewController() -> SpaceSettingsViewController
}

public class KeyboardSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private let keyboardSettingsSubViewControllerFactory: KeyboardSettingsSubViewControllerFactory
  private let numberNineGridSettingsViewController: NumberNineGridSettingsViewController
  private let toolbarSettingsViewController: ToolbarSettingsViewController
  private let symbolSettingsViewController: SymbolSettingsViewController
  private let symbolKeyboardSettingsViewController: SymbolKeyboardSettingsViewController
  private let keyboardLayoutViewController: KeyboardLayoutViewController
  private let spaceSettingsViewController: SpaceSettingsViewController

  private var subscriptions = Set<AnyCancellable>()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel, keyboardSettingsSubViewControllerFactory: KeyboardSettingsSubViewControllerFactory) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel
    self.keyboardSettingsSubViewControllerFactory = keyboardSettingsSubViewControllerFactory

    self.numberNineGridSettingsViewController = keyboardSettingsSubViewControllerFactory.makeNumberNineGridSettingsViewController()
    self.toolbarSettingsViewController = keyboardSettingsSubViewControllerFactory.makeToolbarSettingsViewController()
    self.symbolSettingsViewController = keyboardSettingsSubViewControllerFactory.makeSymbolSettingsViewController()
    self.symbolKeyboardSettingsViewController = keyboardSettingsSubViewControllerFactory.makeSymbolKeyboardSettingsViewController()
    self.keyboardLayoutViewController = keyboardSettingsSubViewControllerFactory.makeKeyboardLayoutViewController()
    self.spaceSettingsViewController = keyboardSettingsSubViewControllerFactory.makeSpaceSettingsViewController()

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
    case .keyboardLayout:
      presentKeyboardLayout()
    case .space:
      presentSpaceSettings()
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

  func presentKeyboardLayout() {
    navigationController?.pushViewController(keyboardLayoutViewController, animated: true)
  }

  func presentSpaceSettings() {
    navigationController?.pushViewController(spaceSettingsViewController, animated: true)
  }
}

// MARK: override UIViewController

public extension KeyboardSettingsViewController {
  override func loadView() {
    title = "键盘设置"
    view = KeyboardSettingsRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }
}
