//
//  NumberNineGridSettingTableView.swift
//  Hamster
//
//  Created by morse on 2023/6/16.
//

import HamsterUIKit
import ProgressHUD
import UIKit

/// 数字九宫格设置页面
class NumberNineGridSettingsView: NibLessView {
  // MARK: properties

  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    return tableView
  }()

  // MARK: methods

  public init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)

    setupTableView()
  }

  func setupTableView() {
    addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.fillSuperview()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if let _ = window {
      tableView.reloadData()
    }
  }
}

extension NumberNineGridSettingsView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    keyboardSettingsViewModel.numberNineGridSettings.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let settingItem = keyboardSettingsViewModel.numberNineGridSettings[indexPath.section]
    if settingItem.type == .button {
      let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? ButtonTableViewCell else { return cell }
      cell.updateWithSettingItem(settingItem)
      return cell
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? ToggleTableViewCell else { return cell }
    cell.updateWithSettingItem(settingItem)
    return cell
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if section == 0 {
      return TableFooterView(footer: Self.enableNumberNineGridInputOnScreenModeRemark)
    }
    return nil
  }
}

extension NumberNineGridSettingsView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

extension NumberNineGridSettingsView {
  static let enableNumberNineGridInputOnScreenModeRemark = "开启此选项后，符号会直接上屏，不在经过RIME引擎处理。"
}
