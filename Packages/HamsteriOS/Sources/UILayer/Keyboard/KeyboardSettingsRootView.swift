//
//  KeyboardSettingsRootView.swift
//
//
//  Created by morse on 2023/7/12.
//

import HamsterUIKit
import UIKit

class KeyboardSettingsRootView: NibLessView {
  // MARK: properties

  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    tableView.dataSource = self
    tableView.delegate = self
    addSubview(tableView)
  }

  override func activateViewConstraints() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.bottomAnchor.constraint(equalTo: CustomKeyboardLayoutGuideNoSafeArea.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }
}

extension KeyboardSettingsRootView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()

    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: false)
    }
  }
}

extension KeyboardSettingsRootView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return keyboardSettingsViewModel.keyboardSettingsItems.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return keyboardSettingsViewModel.keyboardSettingsItems[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let setting = keyboardSettingsViewModel.keyboardSettingsItems[indexPath.section].items[indexPath.row]
    switch setting.type {
    case .navigation:
      let tableCell: SettingTableViewCell
      if let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier), let cell = cell as? SettingTableViewCell {
        tableCell = cell
      } else {
        tableCell = SettingTableViewCell(style: .default, reuseIdentifier: SettingTableViewCell.identifier)
      }
      tableCell.setting = setting
      return tableCell
    case .toggle:
      let toggleCell: ToggleTableViewCell
      if let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier), let cell = cell as? ToggleTableViewCell {
        toggleCell = cell
        toggleCell.settingItem = setting
      } else {
        toggleCell = ToggleTableViewCell(settingItem: setting)
      }
      return toggleCell
    case .textField:
      let textFieldCell: TextFieldTableViewCell
      if let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier), let cell = cell as? TextFieldTableViewCell {
        textFieldCell = cell
        textFieldCell.settingItem = setting
      } else {
        textFieldCell = TextFieldTableViewCell(settingItem: setting)
      }
      return textFieldCell
    case .button:
      let buttonCell: ButtonTableViewCell
      if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier), let cell = cell as? ButtonTableViewCell {
        buttonCell = cell
        buttonCell.settingItem = setting
      } else {
        buttonCell = ButtonTableViewCell(settingItem: setting)
      }
      return buttonCell
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return keyboardSettingsViewModel.keyboardSettingsItems[section].title
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return keyboardSettingsViewModel.keyboardSettingsItems[section].footer
  }
}

extension KeyboardSettingsRootView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let setting = keyboardSettingsViewModel.keyboardSettingsItems[indexPath.section].items[indexPath.row]
    if setting.type == .navigation {
//      if let navigationHandled = setting.navigationLink {
//        navigationController?.pushViewController(navigationHandled(), animated: true)
//      }
    }
    tableView.deselectRow(at: indexPath, animated: false)
  }
}
