//
//  SymbolTableView.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//
import HamsterUIKit
import ProgressHUD
import UIKit

class SymbolSettingsView: NibLessView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    return tableView
  }()

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)
  }
}

extension SymbolSettingsView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return keyboardSettingsViewModel.buttonSettingItems.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath)

    guard let cell = cell as? ButtonTableViewCell else { return cell }

    cell.settingItem = keyboardSettingsViewModel.buttonSettingItems[indexPath.row]
    return cell
  }
}
