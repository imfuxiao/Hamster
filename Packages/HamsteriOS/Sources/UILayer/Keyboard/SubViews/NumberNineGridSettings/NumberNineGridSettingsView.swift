//
//  NumberNineGridSettingTableView.swift
//  Hamster
//
//  Created by morse on 2023/6/16.
//

import HamsterUIKit
import ProgressHUD
import UIKit

class NumberNineGridSettingsView: NibLessView {
  // MARK: properties

  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    return tableView
  }()

  // MARK: methods

  public init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  override func activateViewConstraints() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}

extension NumberNineGridSettingsView: UITableViewDataSource {
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
        settingItem: .init(
          text: "启用数字九宫格",
          toggleValue: keyboardSettingsViewModel.enableNineGridOfNumericKeyboard,
          toggleHandled: { [unowned self] in
            keyboardSettingsViewModel.enableNineGridOfNumericKeyboard = $0
          }
        )
      )
    case 1:
      return ToggleTableViewCell(
        settingItem: .init(
          text: "是否直接上屏",
          toggleValue: keyboardSettingsViewModel.enterDirectlyOnScreenByNineGridOfNumericKeyboard,
          toggleHandled: { [unowned self] in
            keyboardSettingsViewModel.enterDirectlyOnScreenByNineGridOfNumericKeyboard = $0
          }
        )
      )
    case 2:
      return ButtonTableViewCell(
        settingItem: .init(
          text: "符号列表 - 恢复默认值",
          textTintColor: .systemRed,
          buttonAction: { [unowned self] in
            // TODO: 恢复默认值
//            appSettings.numberNineGridSymbols = HamsterAppSettingKeys.defaultNumberNineGridSymbols
//            parentController.symbolsTableView.reloadData()
//            ProgressHUD.showSuccess("重置成功")
          }
        ))
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

extension NumberNineGridSettingsView: UITableViewDelegate {}

extension NumberNineGridSettingsView {
  static let enableNumberNineGridInputOnScreenModeRemark = "开启此选项后，字符与数字会直接上屏，不在经过RIME引擎处理。"
}
