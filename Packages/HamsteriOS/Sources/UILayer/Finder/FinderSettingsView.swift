//
//  FinderSettingsView.swift
//
//
//  Created by morse on 2023/7/11.
//

import HamsterUIKit
import UIKit

class FinderSettingsView: NibLessView {
  private let finderViewModel: FinderViewModel

  lazy var settingTableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()

  init(frame: CGRect = .zero, finderViewModel: FinderViewModel) {
    self.finderViewModel = finderViewModel

    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    addSubview(settingTableView)
  }

  override func activateViewConstraints() {
    settingTableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      settingTableView.topAnchor.constraint(equalTo: topAnchor),
      settingTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      settingTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      settingTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}

extension FinderSettingsView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()
  }
}

extension FinderSettingsView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 0 {
      return "指后缀为“.txt”及文件夹名包含“.userdb”下的文件"
    }
    return nil
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
      case (0, 0):
        return ButtonTableViewCell(settingItem: .init(
          text: "拷贝键盘词库文件至应用",
          buttonAction: { [unowned self] in
            Task {
              try await self.finderViewModel.copyAppGroupDictFileToAppDocument()
            }
          }
        ))
      case (1, 0):
        return ButtonTableViewCell(settingItem: .init(
          text: "使用键盘文件覆盖应用文件",
          buttonAction: { [unowned self] in
            self.finderViewModel.overrideDirectoryConform {
              Task {
                try await self.finderViewModel.overrideAppDocument()
              }
            }
          }
        ))
      default:
        return UITableViewCell(frame: .zero)
    }
  }
}

extension FinderSettingsView: UITableViewDelegate {}
