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
    tableView.allowsSelection = false
    return tableView
  }()

  private var subscriptions = Set<AnyCancellable>()

  // MARK: methods

  public init(frame: CGRect = .zero, rimeViewModel: RimeViewModel) {
    self.rimeViewModel = rimeViewModel

    super.init(frame: frame)

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

  @objc func copySyncConfig() {
    UIPasteboard.general.string = Self.rimeSyncConfigSample
    ProgressHUD.showSuccess("复制成功", interaction: false, delay: 1.5)
  }
}

public extension RimeRootView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()
  }
}

extension RimeRootView: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    rimeViewModel.settings.count
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let settingItem = rimeViewModel.settings[indexPath.section]
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

    let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? ToggleTableViewCell else { return cell }
    cell.updateWithSettingItem(settingItem)
    return cell
  }

  public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "简繁切换"
    }
    return nil
  }

  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    switch section {
    case 0:
      return TableFooterView(footer: Self.rimeSimplifiedAndTraditionalSwitcherKeyRemark)
    case 1:
      return TableFooterView(footer: Self.overrideRemark)
    case 2:
      return TableFooterView(footer: "注意：Rime 根目录下 hamster.yaml 与 hamster.custom.yaml 配置文件会覆盖当前应用配置。")
    case 3:
      let footer = TableFooterView(footer: Self.rimeSyncRemark)
      let gesture = UITapGestureRecognizer(target: self, action: #selector(copySyncConfig))
      footer.addGestureRecognizer(gesture)
      return footer
    default:
      return nil
    }
  }
}

extension RimeRootView: UITableViewDelegate {}

extension RimeRootView {
  static let rimeSimplifiedAndTraditionalSwitcherKeyRemark = "配置文件中`switches`简繁转换选项的配置名称，仓用于中文简体与繁体之间快速切换。"
  static let overrideRemark = "如果您未使用自造词功能，请保持保持默认开启状态。"

  static let rimeSyncConfigSample = """
  # id可以自定义，但不能其他终端定义的ID重复
  installation_id: "hamster"
  # 仓的iOS中iCloud前缀路径固定为：/private/var/mobile/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents
  # iOS中的路径与MacOS及Windows的iCloud路径是不同的
  sync_dir: "/private/var/mobile/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents/sync"
  """

  static let rimeSyncRemark = """
  注意：
  1. RIME同步自定义参数，需要手工添加至Rime目录下的`installation.yaml`文件中(如果没有，需要则自行创建)；
  2. 同步配置示例：(点击可复制)
  ```
  \(RimeRootView.rimeSyncConfigSample)
  ```
  """
}
