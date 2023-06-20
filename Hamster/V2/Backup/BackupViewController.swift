//
//  BackupViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import UIKit

class BackupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  init(parentController: SettingsViewController, appSettings: HamsterAppSettings) {
    self.parentController = parentController
    self.appSettings = appSettings
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  unowned let parentController: SettingsViewController
  let appSettings: HamsterAppSettings
  lazy var backupViewModel: BackupViewModel = .init(controller: self)
  let finderViewModel = FinderViewModel(rootURL: RimeContext.sandboxBackupDirectory)
  var backupFiles: [FileInfo] = []

  // 暂存
  var selectFile: FileInfo?

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(FinderViewCell.self, forCellReuseIdentifier: FinderViewCell.identifier)
    return tableView
  }()

  static let backupRemark = """
  1. 向左滑动操作文件；
  2. 软件恢复后,请手动执行“重新部署”；
  """
}

// MARK: custom method

extension BackupViewController {
  func loadBackupFiles() {
    backupFiles = finderViewModel.currentPathFiles().filter { $0.url.pathExtension.lowercased() == "zip" }
  }
}

// MARK: override UIViewController

extension BackupViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "备份与恢复"

    let tableView = tableView
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    loadBackupFiles()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    parentController.restSettingSections()
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension BackupViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }
    return backupFiles.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return ButtonTableViewCell(text: "软件备份", favoriteButton: .appBackup) { [unowned self] in
        backupViewModel.backup()
        loadBackupFiles()
      }
    }

    let fileInfo = backupFiles[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: FinderViewCell.identifier, for: indexPath)
    if let cell = cell as? FinderViewCell {
      cell.fileInfo = fileInfo
    }

    return cell
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 0 {
      return Self.backupRemark
    }
    return nil
  }

  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let fileInfo = backupFiles[indexPath.row]
    selectFile = fileInfo

    let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [unowned self] _, _, completion in
      let alert = UIAlertController(title: "是否删除？", message: "文件删除后无法恢复，确认删除？", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { [unowned self] _ in
        finderViewModel.deleteFile(fileInfo: fileInfo)
        loadBackupFiles()
        tableView.reloadData()
        completion(true)
      }))
      alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in completion(false) }))
      self.present(alert, animated: true, completion: nil)
    }

    let restoreAction = UIContextualAction(style: .normal, title: "恢复") { [unowned self] _, _, completion in
      backupViewModel.restore(fileInfo: fileInfo)
      completion(true)
    }
    restoreAction.backgroundColor = .systemYellow.withAlphaComponent(0.5)

    let editAction = UIContextualAction(style: .normal, title: "修改名称") { [unowned self] _, _, completion in
      let alertController = UIAlertController(title: "修改备份文件名称", message: nil, preferredStyle: .alert)
      alertController.addTextField { $0.placeholder = "新文件名称" }
      alertController.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { [unowned self, alertController] _ in
        guard let textFields = alertController.textFields else { return }
        let newFileName = textFields[0].text ?? ""
        self.backupViewModel.rename(at: fileInfo.url, newFileName: newFileName)
        completion(true)
      }))
      alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in completion(false) }))
      self.present(alertController, animated: true)
    }
    editAction.backgroundColor = .systemBlue.withAlphaComponent(0.5)

    return UISwipeActionsConfiguration(actions: [editAction, restoreAction, deleteAction])
  }
}
