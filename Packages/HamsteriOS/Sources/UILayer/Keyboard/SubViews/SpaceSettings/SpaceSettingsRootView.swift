//
//  SpaceSettingsRootView.swift
//
//
//  Created by morse on 2023/10/12.
//

import HamsterUIKit
import UIKit

/// 空格设置 View
class SpaceSettingsRootView: NibLessView {
  // MARK: properties

  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.allowsSelection = false
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    tableView.register(StepperTableViewCell.self, forCellReuseIdentifier: StepperTableViewCell.identifier)
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)

    setupTableView()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      tableView.reloadData()
    }
  }

  func setupTableView() {
    addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.fillSuperview()
  }
}

extension SpaceSettingsRootView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    keyboardSettingsViewModel.spaceSettings.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    keyboardSettingsViewModel.spaceSettings[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let settingItem = keyboardSettingsViewModel.spaceSettings[indexPath.section].items[indexPath.row]

    if settingItem.type == .textField {
      let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? TextFieldTableViewCell else { return cell }
      cell.updateWithSettingItem(settingItem)
      return cell
    }

    if settingItem.type == .step {
      let cell = tableView.dequeueReusableCell(withIdentifier: StepperTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? StepperTableViewCell else { return cell }
      cell.updateWithSettingItem(settingItem)
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? ToggleTableViewCell else { return cell }
    cell.updateWithSettingItem(settingItem)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "空格加载文字"
    }
    if section == 1 {
      return "空格长显文字"
    }
    return nil
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 0 || section == 1 {
      return "1. 仅对内置键盘有效。\n2.自定义键盘在配置文件中设置。"
    }
    if section == 2 {
      return "1. 启用后，方案名称会覆盖长显文本。\n2. 以上两个选项对自定义键盘也适用。"
    }
    return keyboardSettingsViewModel.spaceSettings[section].footer
  }
}
