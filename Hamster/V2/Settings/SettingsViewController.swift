//
//  SettingsViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/12.
//

import SwiftUI
import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  init(appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self.appSettings = appSettings
    self.rimeContext = rimeContext
    self.settingViewModel = SettingViewModel(appSettings: appSettings)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var appSettings: HamsterAppSettings
  private var rimeContext: RimeContext
  private let settingViewModel: SettingViewModel

  lazy var settingSections: [SettingSection] = Self.settingSections(parentController: self, appSettings: appSettings, rimeContext: rimeContext)

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    return tableView
  }()
}

// MARK: override UIViewController

extension SettingsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "输入法设置"
//    navigationController?.navigationBar.prefersLargeTitles = true

    let tableView = tableView
    tableView.delegate = self
    tableView.dataSource = self
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    if appSettings.isFirstLaunch {}
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: false)
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    settingViewModel.appLoadData()
  }
}

// MARK: implementation UITableViewDataSource UITableViewDelegate

extension SettingsViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    settingSections.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    settingSections[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath)
    if let cell = cell as? SettingTableViewCell {
      let model = settingSections[indexPath.section].items[indexPath.row]
      cell.setting = model
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let model = settingSections[indexPath.section].items[indexPath.row]
    if let navigationLink = model.navigationLink {
      navigationController?.pushViewController(navigationLink(), animated: true)
    }
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

// MARK: 初始设置页面数据配置

extension SettingsViewController {
  static func settingSections(parentController: SettingsViewController, appSettings: HamsterAppSettings, rimeContext: RimeContext) -> [SettingSection] {
    [
      .init(title: "输入相关", items: [
        .init(
          icon: UIImage(systemName: "highlighter")!.withTintColor(.yellow),
          text: "输入方案设置",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            InputSchemaViewController(appSettings: appSettings, rimeContext: rimeContext)
          }
        ),
        .init(
          icon: UIImage(systemName: "network")!,
          text: "输入方案上传",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            UploadInputSchemaViewController()
          }
        ),
        .init(
          icon: UIImage(systemName: "folder")!,
          text: "方案文件管理",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            FileManagerViewController(appSettings: appSettings, rimeContext: rimeContext)
          }
        ),
      ]),
      .init(title: "键盘相关", items: [
        // TODO: 键盘界面设置包含颜色方案设置
        .init(
          icon: UIImage(systemName: "keyboard")!,
          text: "键盘设置",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            KeyboardSettingViewController(appSettings: appSettings)
          }
        ),
        .init(
          icon: UIImage(systemName: "paintpalette")!,
          text: "键盘配色",
          accessoryType: .disclosureIndicator,
          navigationLinkLabel: { appSettings.enableRimeColorSchema ? "启用" : "禁用" },
          navigationLink: {
            ColorSchemaSettingViewController(parentController: parentController, appSettings: appSettings)
          }
        ),
        .init(
          icon: UIImage(systemName: "speaker.wave.3")!,
          text: "按键音与震动",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            KeyboardFeedbackViewController(appSettings: appSettings)
          }
        ),
        .init(icon: UIImage(systemName: "hand.draw")!, text: "按键滑动设置", accessoryType: .disclosureIndicator),
      ]),
      .init(title: "同步与备份", items: [
        // TODO: 键盘界面设置包含颜色方案
        .init(
          icon: UIImage(systemName: "externaldrive.badge.icloud")!,
          text: "iCloud同步",
          accessoryType: .disclosureIndicator,
          navigationLinkLabel: { appSettings.enableAppleCloud ? "启用" : "禁用" },
          navigationLink: {
            AppleCloudViewController(parentController: parentController, appSettings: appSettings)
          }
        ),
        .init(
          icon: UIImage(systemName: "externaldrive.badge.timemachine")!,
          text: "软件备份",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            BackupViewController(appSettings: appSettings)
          }
        ),
      ]),
      .init(title: "RIME", items: [
        .init(
          icon: UIImage(systemName: "r.square")!,
          text: "RIME",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            RimeViewController(appSettings: appSettings, rimeContext: rimeContext)
          }
        ),
      ]),
      .init(title: "关于", items: [
        .init(
          icon: UIImage(systemName: "info.circle")!,
          text: "关于",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            AboutViewController(appSettings: appSettings)
          }
        ),
      ]),
    ]
  }
}
