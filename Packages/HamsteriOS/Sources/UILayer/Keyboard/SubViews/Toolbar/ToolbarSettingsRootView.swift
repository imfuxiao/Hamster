//
//  ToolbarSettingsRootView.swift
//
//
//  Created by morse on 14/7/2023.
//

import HamsterUIKit
import UIKit

class ToolbarSettingsRootView: NibLessView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.allowsSelection = false
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.register(StepperTableViewCell.self, forCellReuseIdentifier: StepperTableViewCell.identifier)
    return tableView
  }()

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)

    setupTableView()
  }

  func setupTableView() {
    constructViewHierarchy()
    activateViewConstraints()
  }

  override func constructViewHierarchy() {
    addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func activateViewConstraints() {
    tableView.fillSuperview()
  }
}

extension ToolbarSettingsRootView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    keyboardSettingsViewModel.toolbarSettings.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    keyboardSettingsViewModel.toolbarSettings[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let setting = keyboardSettingsViewModel.toolbarSettings[indexPath.section].items[indexPath.row]
    if setting.type == .step {
      let cell = tableView.dequeueReusableCell(withIdentifier: StepperTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? StepperTableViewCell else { return cell }
      cell.updateWithSettingItem(setting)
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? ToggleTableViewCell else { return cell }
    cell.updateWithSettingItem(setting)
    return cell
  }
}
