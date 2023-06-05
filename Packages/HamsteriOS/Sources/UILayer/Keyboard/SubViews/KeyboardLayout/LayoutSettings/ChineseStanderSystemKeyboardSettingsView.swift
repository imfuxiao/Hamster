//
//  StanderSystemKeyboardSettingsView.swift
//
//
//  Created by morse on 2023/9/13.
//

import Combine
import HamsterUIKit
import UIKit

/// 中文标准键盘设置
class ChineseStanderSystemKeyboardSettingsView: NibLessView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private var subscriptions = Set<AnyCancellable>()

  lazy var segmentedControl: UISegmentedControl = {
    let tags = ["设置", "划动设置"]
    let segmentedControl = UISegmentedControl(items: tags)
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.addTarget(
      keyboardSettingsViewModel,
      action: #selector(keyboardSettingsViewModel.chineseLayoutSegmentChangeAction(_:)),
      for: .valueChanged)
    return segmentedControl
  }()

  lazy var contentContainerView: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = .secondarySystemBackground
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

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

  lazy var swipeSettingView: UIView = {
    let view = ChineseStanderSystemKeyboardSwipeSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: .zero)

    backgroundColor = .secondarySystemBackground
    setupView()
  }

  func setupView() {
    addSubview(segmentedControl)
    addSubview(contentContainerView)
    NSLayoutConstraint.activate([
      segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      segmentedControl.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2.0),
      trailingAnchor.constraint(equalToSystemSpacingAfter: segmentedControl.trailingAnchor, multiplier: 2.0),

      contentContainerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
      contentContainerView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
      contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    contentContainerView.addSubview(tableView)
    contentContainerView.addSubview(swipeSettingView)
    tableView.fillSuperview()
    swipeSettingView.fillSuperview()
    swipeSettingView.isHidden = true

    keyboardSettingsViewModel.segmentActionPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] action in
        switch action {
        case .chineseLayoutSettings:
          tableView.isHidden = false
          swipeSettingView.isHidden = true
        case .chineseLayoutSwipeSettings:
          tableView.isHidden = true
          swipeSettingView.isHidden = false
//        default:
//          return
        }
      }
      .store(in: &subscriptions)
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      keyboardSettingsViewModel.chineseLayoutSegmentChangeAction(segmentedControl)
    }
  }
}

extension ChineseStanderSystemKeyboardSettingsView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return keyboardSettingsViewModel.chineseStanderSystemKeyboardSettingsItems.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return keyboardSettingsViewModel.chineseStanderSystemKeyboardSettingsItems[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let setting = keyboardSettingsViewModel.chineseStanderSystemKeyboardSettingsItems[indexPath.section].items[indexPath.row]

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
    return keyboardSettingsViewModel.chineseStanderSystemKeyboardSettingsItems[section].title
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return keyboardSettingsViewModel.chineseStanderSystemKeyboardSettingsItems[section].footer
  }
}

extension ChineseStanderSystemKeyboardSettingsView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let setting = keyboardSettingsViewModel.chineseStanderSystemKeyboardSettingsItems[indexPath.section].items[indexPath.row]
    setting.navigationAction?()
    tableView.deselectRow(at: indexPath, animated: false)
  }
}
