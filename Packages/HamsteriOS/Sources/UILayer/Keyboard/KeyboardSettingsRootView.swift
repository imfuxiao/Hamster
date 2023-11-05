//
//  KeyboardSettingsRootView.swift
//
//
//  Created by morse on 2023/7/12.
//

import Combine
import HamsterUIKit
import UIKit

class KeyboardSettingsRootView: NibLessView {
  // MARK: properties

  private var subscriptions = Set<AnyCancellable>()
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    tableView.register(PullDownMenuCell.self, forCellReuseIdentifier: PullDownMenuCell.identifier)
    tableView.register(StepperTableViewCell.self, forCellReuseIdentifier: StepperTableViewCell.identifier)
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)

    setupView()
  }

  func setupView() {
    addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.fillSuperview()

//    keyboardSettingsViewModel.$enableSymbolKeyboard
//      .combineLatest(keyboardSettingsViewModel.$enableNineGridOfNumericKeyboard, keyboardSettingsViewModel.$enableToolbar)
//      .sink { [unowned self] _ in
//        tableView.reloadData()
//      }
//      .store(in: &subscriptions)
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      tableView.reloadData()
    }
  }
}

extension KeyboardSettingsRootView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return keyboardSettingsViewModel.keyboardSettingsItems.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return keyboardSettingsViewModel.keyboardSettingsItems[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let setting = keyboardSettingsViewModel.keyboardSettingsItems[indexPath.section].items[indexPath.row]

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

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return keyboardSettingsViewModel.keyboardSettingsItems[section].title
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return keyboardSettingsViewModel.keyboardSettingsItems[section].footer
  }
}

extension KeyboardSettingsRootView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let setting = keyboardSettingsViewModel.keyboardSettingsItems[indexPath.section].items[indexPath.row]
    setting.navigationAction?()
    tableView.deselectRow(at: indexPath, animated: false)
  }
}
