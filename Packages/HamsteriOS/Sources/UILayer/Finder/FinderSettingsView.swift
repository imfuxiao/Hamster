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
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableView.automaticDimension
    return tableView
  }()

  init(frame: CGRect = .zero, finderViewModel: FinderViewModel) {
    self.finderViewModel = finderViewModel

    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    addSubview(settingTableView)
  }

  override func activateViewConstraints() {
    settingTableView.fillSuperview()
  }
}

extension FinderSettingsView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()
  }
}

extension FinderSettingsView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 0 {
      return "指后缀为“.txt”及文件夹名包含“.userdb”下的文件"
    }
    return nil
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? ButtonTableViewCell else { return cell }
    guard indexPath.section < finderViewModel.settingItems.count else { return cell }
    cell.settingItem = finderViewModel.settingItems[indexPath.section]
    return cell
  }
}

extension FinderSettingsView: UITableViewDelegate {}
