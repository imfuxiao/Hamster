//
//  AddKeySwipeViewController.swift
//
//
//  Created by morse on 2023/10/19.
//

import Combine
import HamsterKeyboardKit
import HamsterUIKit
import ProgressHUD
import UIKit

class AddKeySwipeViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private let key: Key
  private let keyboardType: KeyboardType
  private var subscriptions = Set<AnyCancellable>()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel, key: Key, keyboardType: KeyboardType) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel
    self.key = key
    self.keyboardType = keyboardType

    super.init()

    self.keyboardSettingsViewModel.addAlertSwipeSettingDismissPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        self.keyboardSettingsViewModel.reloadKeySwipeSettingViewSubject.send(($0, $1))
        self.navigationController?.popViewController(animated: false)
      }
      .store(in: &subscriptions)

    self.keyboardSettingsViewModel.addAlertSwipeSettingSubject
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] option, saveAction in
        if option == .character || option == .symbol {
          alertText(alertTitle: "字符", submitTitle: "保存", submitCallback: { textField in
            guard let char = textField.text, !char.isEmpty else {
              ProgressHUD.failed("字符不能为空")
              return
            }
            let action: KeyboardAction = option == .character ? .character(char) : .symbol(Symbol(char: char))
            saveAction(action)
          })
          return
        }

        if option == .shortCommand {
          alertOptionSheet(alertTitle: "快捷指令修改", addAlertOptions: { optionMenu in
            ShortcutCommand.allCases.forEach { command in
              let alertAction = UIAlertAction(title: command.rawValue, style: .default) { _ in
                let action: KeyboardAction = .shortCommand(command)
                saveAction(action)
              }
              optionMenu.addAction(alertAction)
            }
          })
          return
        }

        if option == .keyboardType {
          alertOptionSheet(alertTitle: "键盘切换", addAlertOptions: { optionMenu in
            KeyboardSettingsViewModel.KeyboardTypeOption.allCases.forEach { keyboardTypeOption in
              let alertAction = UIAlertAction(title: keyboardTypeOption.option, style: .default) { _ in
                if keyboardTypeOption == .custom {
                  self.alertText(alertTitle: "自定义键盘名称", submitTitle: "保存", submitCallback: { textField in
                    guard let char = textField.text, !char.isEmpty else { return }
                    let action: KeyboardAction = .keyboardType(.custom(named: char, case: .lowercased))
                    saveAction(action)
                  })
                  return
                }

                guard let keyboardTypeOption = keyboardTypeOption.keyboardType else {
                  ProgressHUD.failed("无对应的键盘类型")
                  return
                }

                let action: KeyboardAction = .keyboardType(keyboardTypeOption)
                saveAction(action)
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
    title = "新增滑动"
    view = AddKeySwipeRootView(KeyboardSettingsViewModel: keyboardSettingsViewModel, key: key, keyboardType: keyboardType)
  }
}
