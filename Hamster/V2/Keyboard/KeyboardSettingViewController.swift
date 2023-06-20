//
//  KeyboardUISettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import UIKit

class KeyboardSettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  init(appSettings: HamsterAppSettings) {
    self.appSettings = appSettings
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let appSettings: HamsterAppSettings

  lazy var settingsItems: [SettingSectionModel] = [
    .init(
      footer: Self.enableKeyboardAutomaticallyLowercaseRemark,
      items: [
        .init(
          text: "显示按键气泡",
          type: .toggle,
          toggleValue: appSettings.showKeyPressBubble,
          toggleHandled: { [unowned self] in
            appSettings.showKeyPressBubble = $0
          }),
        .init(
          text: "启用空格滑动",
          type: .toggle,
          toggleValue: appSettings.enableSpaceSliding,
          toggleHandled: { [unowned self] in
            appSettings.enableSpaceSliding = $0
          }),
        .init(
          text: "显示键盘收起图标",
          type: .toggle,
          toggleValue: appSettings.showKeyboardDismissButton,
          toggleHandled: { [unowned self] in
            appSettings.showKeyboardDismissButton = $0
          }),
        .init(
          text: "Shift自动转小写",
          type: .toggle,
          toggleValue: appSettings.enableKeyboardAutomaticallyLowercase,
          toggleHandled: { [unowned self] in
            appSettings.enableKeyboardAutomaticallyLowercase = $0
          })

      ]),
    .init(
      items: [
        .init(
          text: "启用空格左侧按键",
          type: .toggle,
          toggleValue: appSettings.showSpaceLeftButton,
          toggleHandled: { [unowned self] in
            appSettings.showSpaceLeftButton = $0
          }),
        .init(
          text: "左侧按键键值",
          type: .textField,
          textValue: appSettings.spaceLeftButtonValue,
          textHandled: { [unowned self] in
            appSettings.spaceLeftButtonValue = $0
          }),
        .init(
          text: "启用空格右侧按键",
          type: .toggle,
          toggleValue: appSettings.showSpaceRightButton,
          toggleHandled: { [unowned self] in
            appSettings.showSpaceRightButton = $0
          }),
        .init(
          text: "右侧按键键值",
          type: .textField,
          textValue: appSettings.spaceRightButtonValue,
          textHandled: { [unowned self] in
            appSettings.spaceRightButtonValue = $0
          })
      ]),

    .init(
      footer: "选项“按键位于空格左侧”：关闭状态则位于空格右侧，开启则位于空格左侧",
      items: [
        .init(
          text: "启用中英切换按键",
          type: .toggle,
          toggleValue: appSettings.showSpaceRightSwitchLanguageButton,
          toggleHandled: { [unowned self] in
            appSettings.showSpaceRightSwitchLanguageButton = $0
          }),
        .init(
          text: "按键位于空格左侧",
          type: .toggle,
          toggleValue: appSettings.switchLanguageButtonInSpaceLeft,
          toggleHandled: { [unowned self] in
            appSettings.switchLanguageButtonInSpaceLeft = $0
          })
      ]),
    .init(
      items: [
        .init(
          text: "候选栏设置",
          type: .navigation,
          navigationLinkLabel: { [unowned self] in appSettings.enableCandidateBar ? "启用" : "禁用" },
          navigationLink: { [unowned self] in CandidateTextBarSettingViewController(parentController: self, appSettings: appSettings) })
      ]),
    .init(
      footer: Self.symbolKeyboardRemark,
      items: [
        .init(
          text: "启用分号按键",
          type: .toggle,
          toggleValue: appSettings.showSemicolonButton,
          toggleHandled: { [unowned self] in
            appSettings.showSemicolonButton = $0
          }),
        .init(
          text: "数字九宫格",
          type: .navigation,
          navigationLinkLabel: { [unowned self] in appSettings.enableNumberNineGrid ? "启用" : "禁用" },
          navigationLink: { [unowned self] in NumberNineGridSettingViewController(appSettings: appSettings, parentController: self) }),
        .init(
          text: "符号设置",
          type: .navigation,
          navigationLink: { [unowned self] in SymbolSettingsViewController(appSettings: appSettings) }),
        .init(
          text: "符号键盘",
          type: .navigation,
          navigationLinkLabel: { [unowned self] in appSettings.enableSymbolKeyboard ? "启用" : "禁用" },
          navigationLink: { [unowned self] in SymbolKeyboardSettingViewController(appSettings: appSettings, parentController: self) })
      ]),
    .init(
      items: [
      ])
  ]

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
}

// MARK: override UIViewController

extension KeyboardSettingViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "键盘设置"
//    view.backgroundColor = .secondarySystemBackground

    let tableView = tableView
    tableView.dataSource = self
    tableView.delegate = self
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.CustomKeyboardLayoutGuideNoSafeArea.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: false)
    }
  }
}

// MARK: implementation UITableViewDataSource, UITableViewDelegate

extension KeyboardSettingViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    return settingsItems.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingsItems[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let setting = settingsItems[indexPath.section].items[indexPath.row]
    switch setting.type {
    case .navigation:
      if let navigationHandled = setting.navigationLink {
        return NavigationTableViewCell(text: setting.text, secondaryText: setting.navigationLinkLabel(), navigationLink: navigationHandled, controller: self)
      }
      return UITableViewCell()
    case .toggle:
      return ToggleTableViewCell(text: setting.text, secondaryText: setting.secondaryText, toggleValue: setting.toggleValue, toggleHandled: setting.toggleHandled)
    case .textField:
      return TextFieldTableViewCell(iconName: "square.and.pencil", text: setting.textValue ?? "", textHandled: setting.textHandled ?? { _ in })
    case .button:
      return ButtonTableViewCell(text: setting.text, textTintColor: setting.textTintColor, buttonAction: {
        setting.buttonAction?()
      })
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return settingsItems[section].title
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return settingsItems[section].footer
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let setting = settingsItems[indexPath.section].items[indexPath.row]
    if setting.type == .navigation {
      if let navigationHandled = setting.navigationLink {
        navigationController?.pushViewController(navigationHandled(), animated: true)
      }
    }
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

// MARK: static

extension KeyboardSettingViewController {
  static let symbolKeyboardRemark = "启用后，常规符号键盘将被替换为符号键盘。常规符号键盘布局类似系统自带键盘符号布局。"
  static let enableKeyboardAutomaticallyLowercaseRemark = "默认键盘大小写会保持自身状态. 开启此选项后, 当在大写状态在下输入一个字母后会自动转为小写状态. 注意: 双击Shift会保持锁定"
}
