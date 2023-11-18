//
//  AddKeySwipeRootView.swift
//
//
//  Created by morse on 2023/10/19.
//

import HamsterKeyboardKit
import HamsterUIKit
import ProgressHUD
import UIKit

class AddKeySwipeRootView: NibLessView {
  private let KeyboardSettingsViewModel: KeyboardSettingsViewModel
  private var keyboardType: KeyboardType
  private var key: Key
  private var keySwipe: KeySwipe
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

  init(KeyboardSettingsViewModel: KeyboardSettingsViewModel, key: Key, keyboardType: KeyboardType) {
    self.KeyboardSettingsViewModel = KeyboardSettingsViewModel
    self.keyboardType = keyboardType
    self.key = key
    self.keySwipe = .init(direction: .up, action: .none, label: .empty)
    super.init(frame: .zero)

    self.settingItems = getSettingItems()
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

  func getSettingItems() -> [SettingSectionModel] {
    KeyboardSettingsViewModel.addKeySwipeSettingItems(
      key,
      keySwipe: keySwipe,
      setDirection: { [unowned self] direction in
        keySwipe.direction = direction
        realod()
      },
      setActionOption: { [unowned self] actionOption in
        KeyboardSettingsViewModel.addAlertSwipeSettingSubject.send((
          actionOption,
          { [unowned self] action in
            keySwipe.action = action
            realod()
          }
        ))
      },
      setLabelText: { [unowned self] in
        keySwipe.label = KeyLabel(loadingText: "", text: $0)
        realod()
      },
      setShowLabel: { [unowned self] in
        keySwipe.display = $0
        realod()
      },
      setProcessByRIME: { [unowned self] in
        keySwipe.processByRIME = $0
        realod()
      },
      saveHandle: { [unowned self] in
        if let _ = key.swipe.first(where: { swipe in swipe.direction == keySwipe.direction }) {
          ProgressHUD.failed("划动方向:\(keySwipe.direction.labelText) 配置已存在")
          return
        }
        if keySwipe.action == .none {
          ProgressHUD.failed("划动Action不能为空")
          return
        }

        key.swipe.append(keySwipe)
        KeyboardSettingsViewModel.saveKeySwipe(key, keyboardType: keyboardType)
        KeyboardSettingsViewModel.addAlertSwipeSettingDismissSubject.send((key, keyboardType))
      }
    )
  }

  func realod() {
    self.settingItems = getSettingItems()
    self.tableView.reloadData()
  }
}

extension AddKeySwipeRootView: UITableViewDataSource {
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

extension AddKeySwipeRootView: UITableViewDelegate {}
