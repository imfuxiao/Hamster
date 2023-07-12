//
//  SymbolsKeyboardSettingsRootView.swift
//
//
//  Created by morse on 14/7/2023.
//

import HamsterUIKit
import UIKit

class SymbolKeyboardSettingsRootView: NibLessView {
  // MARK: properties

  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, keyboardSettingsViewModel: KeyboardSettingsViewModel) {
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

extension SymbolKeyboardSettingsRootView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return ToggleTableViewCell(settingItem: .init(
        text: "启用符号键盘",
        toggleValue: keyboardSettingsViewModel.enableSymbolKeyboard,
        toggleHandled: { [unowned self] in
          keyboardSettingsViewModel.enableSymbolKeyboard = $0
        }
      ))
    }

    return ButtonTableViewCell(settingItem: .init(
      text: "常用符号 - 恢复默认值",
      textTintColor: .systemRed,
      buttonAction: {
        // TODO: 补充重置符号逻辑
//        SymbolCategory.frequentSymbolProvider.rest()
//        ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
      }
    ))
  }
}
