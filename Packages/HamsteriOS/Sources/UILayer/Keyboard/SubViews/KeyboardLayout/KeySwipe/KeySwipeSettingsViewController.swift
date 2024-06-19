//
//  KeySwipeSettingsViewController.swift
//
//
//  Created by morse on 2023/9/15.
//

import Combine
import HamsterKeyboardKit
import HamsterUIKit
import ProgressHUD
import UIKit

class KeySwipeSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private var subscriptions = Set<AnyCancellable>()
  private var key: Key?
  private var keyboardType: KeyboardType?

  private lazy var rootView: KeySwipeSettingsView = {
    let view = KeySwipeSettingsView(KeyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()

    combine()
  }

  func combine() {
    self.keyboardSettingsViewModel.reloadKeySwipeSettingViewPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        updateWithKey($0.0, for: $0.1)
      }
      .store(in: &subscriptions)

    self.keyboardSettingsViewModel.alertSwipeSettingDeleteConfirmPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] callback in
        alertConfirm(alertTitle: L10n.KB.SwipeSetting.deleteConfirm, confirmTitle: L10n.delete) { callback() }
      }
      .store(in: &subscriptions)

    self.keyboardSettingsViewModel.alertSwipeSettingPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] option, swipe, key, keyboardType in
        if option == .character || option == .symbol {
          alertText(alertTitle: L10n.KB.SwipeSetting.editCharacter, submitTitle: L10n.save, submitCallback: { textField in
            guard let char = textField.text, !char.isEmpty else { return }
            var key = key
            var swipe = swipe
            swipe.action = option == .character ? .character(char) : .symbol(Symbol(char: char))
            guard let index = key.swipe.firstIndex(where: { $0.direction == swipe.direction }) else { return }
            key.swipe[index] = swipe
            self.keyboardSettingsViewModel.saveKeySwipe(key, keyboardType: keyboardType)
            // 更新页面
            self.updateWithKey(key, for: keyboardType)
          })
          return
        }

        if option == .shortCommand {
          alertOptionSheet(alertTitle: L10n.KB.SwipeSetting.editCommand, addAlertOptions: { [unowned self] optionMenu in
            ShortcutCommand.allCases.forEach { command in

              let alertAction = UIAlertAction(title: command.rawValue, style: .default) {[unowned self] _ in
                if case .sendKeys = command {
                  alertText(alertTitle: "sendKeys", submitTitle: L10n.save, submitCallback: { textField in
                    guard let char = textField.text, !char.isEmpty else { return }
                    var key = key
                    var swipe = swipe
                    swipe.action = .shortCommand(.sendKeys(char))
                    guard let index = key.swipe.firstIndex(where: { $0.direction == swipe.direction }) else { return }
                    key.swipe[index] = swipe
                    self.keyboardSettingsViewModel.saveKeySwipe(key, keyboardType: keyboardType)
                    // 更新页面
                    self.updateWithKey(key, for: keyboardType)
                  })
                  return
                }

                var key = key
                var swipe = swipe
                swipe.action = .shortCommand(command)
                guard let index = key.swipe.firstIndex(where: { $0.direction == swipe.direction }) else { return }
                key.swipe[index] = swipe
                self.keyboardSettingsViewModel.saveKeySwipe(key, keyboardType: keyboardType)
                // 更新页面
                self.updateWithKey(key, for: keyboardType)
              }
              optionMenu.addAction(alertAction)
            }
          })
          return
        }

        if option == .keyboardType {
          alertOptionSheet(alertTitle: L10n.KB.SwipeSetting.switchKeyboard, addAlertOptions: { optionMenu in
            KeyboardSettingsViewModel.KeyboardTypeOption.allCases.forEach { keyboardTypeOption in
              let alertAction = UIAlertAction(title: keyboardTypeOption.option, style: .default) { _ in
                if keyboardTypeOption == .custom {
                  self.alertText(alertTitle: L10n.KB.SwipeSetting.customKeyboardName, submitTitle: L10n.save, submitCallback: { textField in
                    guard let char = textField.text, !char.isEmpty else { return }
                    var key = key
                    var swipe = swipe
                    swipe.action = .keyboardType(.custom(named: char, case: .lowercased))
                    guard let index = key.swipe.firstIndex(where: { $0.direction == swipe.direction }) else { return }
                    key.swipe[index] = swipe
                    self.keyboardSettingsViewModel.saveKeySwipe(key, keyboardType: keyboardType)
                    // 更新页面
                    self.updateWithKey(key, for: keyboardType)
                  })
                  return
                }

                guard let keyboardTypeOption = keyboardTypeOption.keyboardType else {
                  ProgressHUD.failed(L10n.KB.SwipeSetting.noCorrespondingKbType)
                  return
                }

                var key = key
                var swipe = swipe
                swipe.action = .keyboardType(keyboardTypeOption)
                guard let index = key.swipe.firstIndex(where: { $0.direction == swipe.direction }) else { return }
                key.swipe[index] = swipe
                self.keyboardSettingsViewModel.saveKeySwipe(key, keyboardType: keyboardType)
                // 更新页面
                self.updateWithKey(key, for: keyboardType)
              }
              optionMenu.addAction(alertAction)
            }
          })
          return
        }
      }
      .store(in: &subscriptions)
  }

  override func loadView() {
    title = L10n.KB.LayoutZh26.segmentSwipe
    self.view = rootView

    let action = UIAction { [unowned self] _ in
      if let key = key, let keyboardType = keyboardType {
        let addViewController = AddKeySwipeViewController(keyboardSettingsViewModel: keyboardSettingsViewModel, key: key, keyboardType: keyboardType)
        self.navigationController?.pushViewController(addViewController, animated: false)
      }
    }
    let rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: action)
    navigationItem.rightBarButtonItem = rightBarButtonItem
  }

  public func updateWithKey(_ key: Key, for keyboardType: KeyboardType) {
    self.key = key
    self.keyboardType = keyboardType
    title = key.action.labelText
    rootView.updateWithKey(key, for: keyboardType)
  }
}
