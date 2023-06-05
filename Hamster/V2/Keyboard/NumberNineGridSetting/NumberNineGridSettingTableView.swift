//
//  NumberNineGridSettingTableView.swift
//  Hamster
//
//  Created by morse on 2023/6/16.
//

import ProgressHUD
import UIKit

class NumberNineGridSettingTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
  init(parentController: NumberNineGridSettingViewController, appSettings: HamsterAppSettings) {
    self.parentController = parentController
    self.appSettings = appSettings
    super.init(frame: .zero, style: .insetGrouped)
    self.delegate = self
    self.dataSource = self
    self.translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let appSettings: HamsterAppSettings
  private unowned let parentController: NumberNineGridSettingViewController
}

// implementation UITableViewDelegate, UITableViewDataSource

extension NumberNineGridSettingTableView {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      return ToggleTableViewCell(
        text: "启用数字九宫格",
        toggleValue: appSettings.enableNumberNineGrid,
        toggleHandled: { [unowned self] in
          appSettings.enableNumberNineGrid = $0
        }
      )
    case 1:
      return ToggleTableViewCell(
        text: "是否直接上屏",
        toggleValue: appSettings.enableNumberNineGridInputOnScreenMode,
        toggleHandled: { [unowned self] in
          appSettings.enableNumberNineGridInputOnScreenMode = $0
        }
      )
    case 2:
      return ButtonTableViewCell(text: "符号列表 - 恢复默认值", textTintColor: .systemRed) { [unowned self] in
        appSettings.numberNineGridSymbols = HamsterAppSettingKeys.defaultNumberNineGridSymbols
        parentController.symbolsTableView.reloadData()
        ProgressHUD.showSuccess("重置成功")
      }
    default:
      return UITableViewCell()
    }
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if section == 1 {
      return TableFooterView(footer: Self.enableNumberNineGridInputOnScreenModeRemark)
    }
    return nil
  }
}

// MARK: static

extension NumberNineGridSettingTableView {
  static let enableNumberNineGridInputOnScreenModeRemark = "开启此选项后，字符与数字会直接上屏，不在经过RIME引擎处理。"
}
