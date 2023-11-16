//
//  FinderSettingsView.swift
//
//
//  Created by morse on 2023/7/11.
//

import HamsterUIKit
import UIKit

class FinderSettingsView: NibLessView {
  private let finderViewModel: FinderViewModel

  lazy var settingTableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()

  init(frame: CGRect = .zero, finderViewModel: FinderViewModel) {
    self.finderViewModel = finderViewModel

    super.init(frame: frame)

    constructViewHierarchy()
    activateViewConstraints()
  }

  override func constructViewHierarchy() {
    addSubview(settingTableView)
  }

  override func activateViewConstraints() {
    settingTableView.fillSuperview()
  }
}

extension FinderSettingsView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    finderViewModel.settingItems.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 1 {
      return "指后缀为“.txt”及文件夹名包含“.userdb”下的文件"
    }
    return nil
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let settingItem = finderViewModel.settingItems[indexPath.section]

    if settingItem.type == .toggle {
      let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? ToggleTableViewCell else { return cell }
      cell.updateWithSettingItem(settingItem)
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? ButtonTableViewCell else { return cell }
    cell.updateWithSettingItem(settingItem)
    return cell
  }
}

extension FinderSettingsView: UITableViewDelegate {}
