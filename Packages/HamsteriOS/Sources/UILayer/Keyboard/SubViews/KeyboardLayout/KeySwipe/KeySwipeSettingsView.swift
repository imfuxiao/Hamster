//
//  KeySwipeSettingsView.swift
//
//
//  Created by morse on 2023/9/15.
//

import HamsterKeyboardKit
import HamsterUIKit
import UIKit

/// 按键划动设置
class KeySwipeSettingsView: NibLessView {
  private let KeyboardSettingsViewModel: KeyboardSettingsViewModel
  private var keyboardType: KeyboardType? = nil
  private var key: Key? = nil
  private var settingItems: [SettingSectionModel]? = nil
  private let saveKeyHandled: ((Key) -> Void)? = nil

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    tableView.register(PullDownMenuCell.self, forCellReuseIdentifier: PullDownMenuCell.identifier)
    tableView.register(StepperTableViewCell.self, forCellReuseIdentifier: StepperTableViewCell.identifier)

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

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if let _ = window {
      if let key = key, let keyboardType = keyboardType {
        updateWithKey(key, for: keyboardType)
      }
    }
  }

  /// 更新 KeySwipeSettingsView 视图
  func updateWithKey(_ key: Key, for keyboardType: KeyboardType) {
    self.key = key
    self.keyboardType = keyboardType
    self.settingItems = KeyboardSettingsViewModel.getSettingsItems(key, keyboardType: keyboardType)
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
    case .pullDown:
      let cell = tableView.dequeueReusableCell(withIdentifier: PullDownMenuCell.identifier, for: indexPath)
      guard let cell = cell as? PullDownMenuCell else { return cell }
      cell.updateWithSettingItem(setting)
      return cell
    case .settings:
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? SettingTableViewCell else { return cell }
      cell.updateWithSettingItem(setting)
      return cell
    case .step:
      let cell = tableView.dequeueReusableCell(withIdentifier: StepperTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? SettingTableViewCell else { return cell }
      cell.updateWithSettingItem(setting)
      return cell
    }
  }
}

extension KeySwipeSettingsView: UITableViewDelegate {}
