//
//  KeySwipeSettingsView.swift
//
//
//  Created by morse on 2023/9/15.
//

import HamsterKeyboardKit
import HamsterUIKit
import UIKit

/// 按键划动配置
class KeySwipeSettingsView: NibLessView {
  private let KeyboardSettingsViewModel: KeyboardSettingsViewModel
  private var key: Key? = nil
  private var settingItems: [SettingSectionModel]? = nil
  private let saveKeyHandled: ((Key) -> Void)? = nil

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)

    tableView.dataSource = self
    tableView.delegate = self
    tableView.translatesAutoresizingMaskIntoConstraints = false

    return tableView
  }()

  init(KeyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.KeyboardSettingsViewModel = KeyboardSettingsViewModel

    super.init(frame: .zero)

    setupView()
  }

  func setupView() {
    backgroundColor = .secondarySystemBackground
    addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
    ])
  }

  func updateWithKey(_ key: Key?) {
    guard let key = key, key != self.key else { return }
    self.key = key
    self.settingItems = getSettingsItems(key)
    tableView.reloadData()
  }
}

extension KeySwipeSettingsView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    settingItems?.count ?? 0
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    settingItems?[section].items.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let setting = settingItems?[indexPath.section].items[indexPath.row] else {
      return UITableViewCell(frame: .zero)
    }

    switch setting.type {
    case .navigation:
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? SettingTableViewCell else { return cell }
      cell.updateWithSettingItem(setting)
      return cell
    case .toggle:
      let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? ToggleTableViewCell else { return cell }
      cell.updateWithSettingItem(setting)
      return cell
    case .textField:
      let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? TextFieldTableViewCell else { return cell }
      cell.updateWithSettingItem(setting)
      return cell
    case .button:
      let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? ButtonTableViewCell else { return cell }
      cell.updateWithSettingItem(setting)
      return cell
    }
  }
}

extension KeySwipeSettingsView: UITableViewDelegate {}

extension KeySwipeSettingsView {
  func setProcessByRIME(_ state: Bool) {
    key?.processByRIME = state
  }

  /// 将 key 变为设置属性, 方便 Tabel 展示
  func getSettingsItems(_ key: Key) -> [SettingSectionModel] {
    var swipeSettingsItem: [SettingSectionModel] = [
      .init(
        items: [
          .init(
            text: "按键操作",
            type: .textField,
            textValue: key.action.yamlString,
            textFieldShouldBeginEditing: false
          ),
          .init(
            text: "按键显示",
            type: .textField,
            textValue: key.labelText,
            textFieldShouldBeginEditing: false
          ),
        ]),
    ]

    for swipe in key.swipe {
      swipeSettingsItem.append(SettingSectionModel(
        items: [
          .init(
            text: "划动方向",
            type: .textField,
            textValue: swipe.direction.rawValue
          ),
          .init(
            text: "划动操作",
            type: .textField,
            textValue: swipe.action.yamlString
          ),
          .init(
            text: "键盘显示文本",
            type: .textField,
            textValue: swipe.label.text
          ),
          .init(
            text: "是否显示文本",
            type: .toggle,
            toggleValue: swipe.display
          ),
          .init(
            text: "是否由 RIME 处理",
            type: .toggle,
            toggleValue: swipe.processByRIME
          ),
        ]
      ))
    }

    return swipeSettingsItem
  }
}
