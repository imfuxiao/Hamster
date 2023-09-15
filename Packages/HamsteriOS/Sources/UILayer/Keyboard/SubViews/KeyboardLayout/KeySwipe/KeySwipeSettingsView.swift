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
  private let key: Key? = nil
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
    addSubview(tableView)
    tableView.fillSuperview()
  }
}

extension KeySwipeSettingsView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    (key?.swipe.count ?? 0) + 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // section = 0: 显示按键定义部分
    if section == 0 {
      // 按键操作/按键显示 Label/是否由 RIME 处理
      return 3
    }

    // 其他 section 显示划动部分设置
    // 划动方向/划动操作/显示 Label /是否由 RIME 处理/是否在按键上显示
    return 5
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // TODO:
    let (section, item) = (indexPath.section, indexPath.row)
//    if section == 0, item == 0 {
//      let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath)
//      guard let cell = cell as? SettingTableViewCell else { return cell }
//      cell.setting = setting
//      return cell

//    }
    return UITableViewCell(frame: .zero)
  }
}

extension KeySwipeSettingsView: UITableViewDelegate {}
