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
    tableView.register(StepperTableViewCell.self, forCellReuseIdentifier: StepperTableViewCell.identifier)
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel
    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func activateViewConstraints() {
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.bottomAnchor.constraint(equalTo: CustomKeyboardLayoutGuideNoSafeArea.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}

extension ToolbarSettingsRootView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return keyboardSettingsViewModel.toolbarToggles.count
    }
    return keyboardSettingsViewModel.toolbarSteppers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? ToggleTableViewCell else { return cell }
      cell.settingItem = keyboardSettingsViewModel.toolbarToggles[indexPath.row]
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: StepperTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? StepperTableViewCell else { return cell }
    cell.stepperModel = keyboardSettingsViewModel.toolbarSteppers[indexPath.row]

    return cell
  }
}
