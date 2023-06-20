//
//  RimeViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import ProgressHUD
import UIKit

class RimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  init(parentController: SettingsViewController, appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self.parentController = parentController
    self.appSettings = appSettings
    self.rimeContext = rimeContext
    self.rimeViewModel = RimeViewModel(appSettings: appSettings, rimeContext: rimeContext)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  unowned let parentController: SettingsViewController
  let appSettings: HamsterAppSettings
  let rimeContext: RimeContext
  let rimeViewModel: RimeViewModel
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.allowsSelection = false
    return tableView
  }()
}

// MARK: override UIViewController

extension RimeViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "RIME"

    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    parentController.restSettingSections()
  }
}

// MARK: implementation UITableViewDelegate UITableViewDataSource

extension RimeViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    6
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      return TextFieldTableViewCell(
        iconName: "square.and.pencil",
        placeholder: "简繁切换键值",
        text: appSettings.rimeSimplifiedAndTraditionalSwitcherKey,
        textHandled: { [unowned self] in
          appSettings.rimeSimplifiedAndTraditionalSwitcherKey = $0
        }
      )
    case 1:
      return ToggleTableViewCell(
        text: "使用鼠须管配置文件",
        toggleValue: appSettings.rimeUseSquirrelSettings,
        toggleHandled: { [unowned self] in
          appSettings.rimeUseSquirrelSettings = $0
        }
      )
    case 2:
      return ToggleTableViewCell(
        text: "部署时覆盖键盘词库文件",
        toggleValue: appSettings.enableOverrideKeyboardUserDictFileOnRimeDeploy,
        toggleHandled: { [unowned self] in
          appSettings.enableOverrideKeyboardUserDictFileOnRimeDeploy = $0
        }
      )
    case 3:
      return ButtonTableViewCell(text: "重新部署", favoriteButton: .rimeDeploy, buttonAction: { [unowned self] in
        rimeViewModel.rimeDeploy()
      })
    case 4:
      return ButtonTableViewCell(text: "RIME同步", favoriteButton: .rimeSync, buttonAction: { [unowned self] in
        rimeViewModel.rimeSync()
      })
    case 5:
      return ButtonTableViewCell(text: "RIME重置", textTintColor: .systemRed, favoriteButton: .rimeRest, buttonAction: { [unowned self] in
        rimeViewModel.rimeRest()
      })
    default:
      return UITableViewCell(frame: .zero)
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "简繁切换"
    }
    return nil
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    switch section {
    case 0:
      return TableFooterView(footer: Self.rimeSimplifiedAndTraditionalSwitcherKeyRemark)
    case 1:
      return TableFooterView(footer: Self.rimeUseSquirrelSettingsRemark)
    case 2:
      return TableFooterView(footer: Self.overrideRemark)
    case 5:
      let footer = TableFooterView(footer: Self.rimeSyncRemark)
      let gesture = UITapGestureRecognizer(target: self, action: #selector(copySyncConfig))
      footer.addGestureRecognizer(gesture)
      return footer
    default:
      return nil
    }
  }

  @objc func copySyncConfig() {
    UIPasteboard.general.string = Self.rimeSyncConfigSample
    ProgressHUD.showSuccess("复制成功", interaction: false, delay: 1.5)
  }
}

extension RimeViewController {
  static let rimeSimplifiedAndTraditionalSwitcherKeyRemark = "配置文件中`switches`简繁转换选项的配置名称，仓用于中文简体与繁体之间快速切换。"
  static let rimeUseSquirrelSettingsRemark = "重新部署后生效. 默认使用鼠须管(squirrel)配置. 关闭此选项后, Rime引擎会使用仓(hamster)配置. 您必须保证hamster.yaml存在"
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
  \(RimeViewController.rimeSyncConfigSample)
  ```
  """
}
