//
//  RimeRootView.swift
//
//
//  Created by morse on 2023/7/10.
//

import Combine
import HamsterUIKit
import ProgressHUD
import UIKit

public class RimeRootView: NibLessView {
  // MARK: properties

  private let rimeViewModel: RimeViewModel

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    return tableView
  }()

  private var subscriptions = Set<AnyCancellable>()

  // MARK: methods

  public init(frame: CGRect = .zero, rimeViewModel: RimeViewModel) {
    self.rimeViewModel = rimeViewModel

    super.init(frame: frame)

    constructViewHierarchy()
    activateViewConstraints()

    self.rimeViewModel.reloadTablePublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        self.tableView.reloadData()
      }
      .store(in: &subscriptions)
  }

  override public func constructViewHierarchy() {
    addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  override public func activateViewConstraints() {
    tableView.fillSuperview()
  }

  override public func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      tableView.reloadData()
    }
  }

  @objc func copySyncConfig() {
    UIPasteboard.general.string = RimeViewModel.rimeSyncConfigSample
    ProgressHUD.success("复制成功", interaction: false, delay: 1.5)
  }
}

extension RimeRootView: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    rimeViewModel.settings.count
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rimeViewModel.settings[section].items.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let settingItem = rimeViewModel.settings[indexPath.section].items[indexPath.row]
    if settingItem.type == .textField {
      let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? TextFieldTableViewCell else { return cell }
      cell.updateWithSettingItem(settingItem)
      return cell
    }

    if settingItem.type == .button {
      let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? ButtonTableViewCell else { return cell }
      cell.updateWithSettingItem(settingItem)
      return cell
    }

    if settingItem.type == .navigation {
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? SettingTableViewCell else { return cell }
      cell.updateWithSettingItem(settingItem)
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? ToggleTableViewCell else { return cell }
    cell.updateWithSettingItem(settingItem)
    return cell
  }

  public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    rimeViewModel.settings[section].title
  }

  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard let footer = rimeViewModel.settings[section].footer else { return nil }
    let view = TableFooterView(footer: footer)
    if section == 4 {
      let gesture = UITapGestureRecognizer(target: self, action: #selector(copySyncConfig))
      view.addGestureRecognizer(gesture)
    }
    return view
  }
}

extension RimeRootView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let settingItem = rimeViewModel.settings[indexPath.section].items[indexPath.row]
    if settingItem.type == .navigation {
      settingItem.navigationAction?()
    }
  }
}
