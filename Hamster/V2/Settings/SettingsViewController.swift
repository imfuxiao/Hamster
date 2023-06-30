//
//  SettingsViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/12.
//

import ProgressHUD
import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  init(appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self.appSettings = appSettings
    self.rimeContext = rimeContext
    self.settingViewModel = SettingViewModel(appSettings: appSettings)
    self.rimeViewModel = RimeViewModel(appSettings: appSettings, rimeContext: rimeContext)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var appSettings: HamsterAppSettings
  private var rimeContext: RimeContext
  private let settingViewModel: SettingViewModel
  let rimeViewModel: RimeViewModel

  lazy var settingSections: [SettingSectionModel] = {
    // TODO:
    // 偏好设置，可动态添加快捷
    let preferenceSettings: [SettingSectionModel] = Self.preferenceSettingSections(controller: self)

    return preferenceSettings + Self.settingSections(parentController: self, appSettings: appSettings, rimeContext: rimeContext)
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
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
    view.addSubview(tableView)
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
    let model = settingSections[indexPath.section].items[indexPath.row]
    if model.type == .button {
      return ButtonTableViewCell(
        text: model.text,
        textTintColor: model.textTintColor,
        favoriteButton: model.favoriteButton,
        favoriteButtonHandler: { [unowned self] in
          self.restSettingSections()
        },
        buttonAction: {
          model.buttonAction?()
        }
      )
    }

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

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0, !UserDefaults.standard.getFavoriteButtons().isEmpty {
      return "快捷区域"
    }
    return nil
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 0, !UserDefaults.standard.getFavoriteButtons().isEmpty {
      return Self.favoriteRemark
    }
    return nil
  }
}

// MARK: custom method

extension SettingsViewController {
  func restSettingSections() {
    settingSections = Self.preferenceSettingSections(controller: self) + Self.settingSections(parentController: self, appSettings: appSettings, rimeContext: rimeContext)
    tableView.reloadData()
  }

  // 快捷设置
  static func preferenceSettingSections(controller: SettingsViewController) -> [SettingSectionModel] {
    let favoriteButtons = UserDefaults.standard.getFavoriteButtons()
    if favoriteButtons.isEmpty { return [] }

    // TODO: 对收藏的button做处理
    let sectionItems: [SettingItemModel] = favoriteButtons.map {
      switch $0 {
      case .appBackup:
        return SettingItemModel(text: "应用备份", type: .button, favoriteButton: $0, buttonAction: {
          controller.settingViewModel.backup()
        })
      case .rimeDeploy:
        return SettingItemModel(text: "重新部署", type: .button, favoriteButton: $0, buttonAction: {
          controller.rimeViewModel.rimeDeploy()
        })
      case .rimeSync:
        return SettingItemModel(text: "RIME同步", type: .button, favoriteButton: $0, buttonAction: {
          controller.rimeViewModel.rimeSync()
        })
      case .rimeRest:
        return SettingItemModel(text: "RIME重置", textTintColor: .systemRed, type: .button, favoriteButton: $0, buttonAction: {
          controller.rimeViewModel.rimeRest()
        })
      }
    }
    return [
      .init(title: "快捷区域", footer: Self.favoriteRemark, items: sectionItems),
    ]
  }

  static func settingSections(parentController: SettingsViewController, appSettings: HamsterAppSettings, rimeContext: RimeContext) -> [SettingSectionModel] {
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
        .init(
          icon: UIImage(systemName: "hand.draw")!,
          text: "按键滑动设置",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            SwipeSettingsViewController(appSettings: appSettings)
          }
        ),
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
            BackupViewController(parentController: parentController, appSettings: appSettings)
          }
        ),
      ]),
      .init(title: "RIME", items: [
        .init(
          icon: UIImage(systemName: "r.square")!,
          text: "RIME",
          accessoryType: .disclosureIndicator,
          navigationLink: {
            RimeViewController(parentController: parentController, appSettings: appSettings, rimeContext: rimeContext)
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

extension SettingsViewController {
  static let favoriteRemark = """
  长按设置按钮可添加或移除至快捷区域；
  """
}
