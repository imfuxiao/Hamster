//
//  BackupRootView.swift
//
//
//  Created by morse on 2023/7/7.
//

import Combine
import HamsterUIKit
import ProgressHUD
import UIKit

class BackupRootView: NibLessView {
  private let backupViewModel: BackupViewModel
  private var subscriptions = Set<AnyCancellable>()

  init(frame: CGRect = .zero, backupViewModel: BackupViewModel) {
    self.backupViewModel = backupViewModel

    super.init(frame: frame)

    setupTableView()
  }

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(FinderViewCell.self, forCellReuseIdentifier: FinderViewCell.identifier)
    return tableView
  }()

  func setupTableView() {
    addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.fillSuperview()

    backupViewModel.$backupFiles
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        tableView.reloadData()
      }
      .store(in: &subscriptions)
  }
}

extension BackupRootView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      backupViewModel.loadBackupFiles()
    }
  }
}

extension BackupRootView: UITableViewDelegate {
  /// 划动处理
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard indexPath.section == 1 else { return nil }
    let fileInfo = backupViewModel.backupFiles[indexPath.row]
    backupViewModel.selectFile = fileInfo

    let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [unowned self] _, _, _ in
      backupViewModel.backupSwipeAction = .delete
    }
    deleteAction.backgroundColor = .systemRed

    let restoreAction = UIContextualAction(style: .normal, title: "恢复") { [unowned self] _, _, completion in
      Task {
        await backupViewModel.restore(fileInfo: fileInfo)
        completion(true)
      }
    }
    restoreAction.backgroundColor = .systemYellow

    let editAction = UIContextualAction(style: .normal, title: "修改名称") { [unowned self] _, _, _ in
      backupViewModel.backupSwipeAction = .rename
    }
    editAction.backgroundColor = .systemBlue
    return UISwipeActionsConfiguration(actions: [editAction, restoreAction, deleteAction])
  }
}

extension BackupRootView: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }
    return backupViewModel.backupFiles.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = ButtonTableViewCell(style: .default, reuseIdentifier: ButtonTableViewCell.identifier)
      cell.updateWithSettingItem(backupViewModel.settingItem)
      return cell
    }

    let fileInfo = backupViewModel.backupFiles[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: FinderViewCell.identifier, for: indexPath)
    if let cell = cell as? FinderViewCell {
      cell.updateWithFileInfo(fileInfo)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 0 {
      return Self.backupRemark
    }
    return nil
  }
}

extension BackupRootView {
  static let backupRemark = """
  1. 向左划动操作文件；
  2. 软件恢复后,请手动执行“重新部署”；
  """
}
