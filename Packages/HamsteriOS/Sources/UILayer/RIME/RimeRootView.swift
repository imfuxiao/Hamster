//
//  RimeRootView.swift
//
//
//  Created by morse on 2023/7/10.
//

import HamsterUIKit
import ProgressHUD
import UIKit

public class RimeRootView: NibLessView {
  // MARK: properties

  private let rimeViewModel: RimeViewModel

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.allowsSelection = false
    return tableView
  }()

  // MARK: methods

  public init(frame: CGRect = .zero, rimeViewModel: RimeViewModel) {
    self.rimeViewModel = rimeViewModel

    super.init(frame: frame)
  }

  override public func constructViewHierarchy() {
    addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  override public func activateViewConstraints() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
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
    5
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      return TextFieldTableViewCell(settingItem: .init(
        icon: UIImage(systemName: "square.and.pencil"),
        text: rimeViewModel.keyValueOfSwitchSimplifiedAndTraditional,
        placeholder: "简繁切换键值",
        textHandled: { [unowned self] in
          rimeViewModel.keyValueOfSwitchSimplifiedAndTraditional = $0
        }
      ))
    case 1:
      return ToggleTableViewCell(settingItem: .init(
        text: "部署时覆盖键盘词库文件",
        toggleValue: rimeViewModel.overrideDictFiles,
        toggleHandled: { [unowned self] in
          rimeViewModel.overrideDictFiles = $0
        }
      ))
    case 2:
      return ButtonTableViewCell(settingItem: .init(
        text: "重新部署",
        buttonAction: { [unowned self] in
          Task {
            try await rimeViewModel.rimeDeploy()
          }
        },
        favoriteButton: .rimeDeploy
      ))
    case 3:
      return ButtonTableViewCell(settingItem: .init(
        text: "RIME同步",
        buttonAction: { [unowned self] in
          Task {
            try await rimeViewModel.rimeSync()
          }
        },
        favoriteButton: .rimeSync
      ))
    case 4:
      return ButtonTableViewCell(settingItem: .init(
        text: "RIME重置", textTintColor: .systemRed, buttonAction: { [unowned self] in
          Task {
            try await rimeViewModel.rimeRest()
          }
        },
        favoriteButton: .rimeRest
      ))
    default:
      return UITableViewCell(frame: .zero)
    }
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
    case 4:
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
