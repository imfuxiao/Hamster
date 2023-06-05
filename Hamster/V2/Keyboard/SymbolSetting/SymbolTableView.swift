//
//  SymbolTableView.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//
import ProgressHUD
import UIKit

class SymbolTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
  init(parentController: SymbolSettingsViewController, appSettings: HamsterAppSettings) {
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
  private unowned let parentController: SymbolSettingsViewController
}

// implementation UITableViewDelegate, UITableViewDataSource

extension SymbolTableView {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      return ButtonTableViewCell(text: "成对上屏符号 - 恢复默认值", textTintColor: .systemRed) { [unowned self] in
        appSettings.pairsOfSymbols = HamsterAppSettingKeys.defaultPairsOfSymbols
        parentController.pairsOfSymbolsTableView.reloadData()
        ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
      }
    case 1:
      return ButtonTableViewCell(text: "光标居中符号 - 恢复默认值", textTintColor: .systemRed) { [unowned self] in
        appSettings.cursorBackOfSymbols = HamsterAppSettingKeys.defaultCursorBackOfSymbols
        parentController.cursorBackOfSymbolsTableView.reloadData()
        ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
      }
    case 2:
      return ButtonTableViewCell(text: "返回主键盘符号 - 恢复默认值", textTintColor: .systemRed) { [unowned self] in
        appSettings.returnToPrimaryKeyboardOfSymbols =
          HamsterAppSettingKeys.defaultReturnToPrimaryKeyboardOfSymbols
        parentController.returnToPrimaryKeyboardOfSymbolsTableView.reloadData()
        ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
      }
    default:
      return UITableViewCell()
    }
  }
}
