//
//  FinderViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import ProgressHUD
import UIKit

class FinderTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
  init(controller: UIViewController, rootDirectoryURL: URL) {
    self.controller = controller
    self.finderViewModel = FinderViewModel(rootURL: rootDirectoryURL)
    self.currentPathFiles = finderViewModel.currentPathFiles()
    super.init(frame: .zero, style: .plain)
    register(FinderViewCell.self, forCellReuseIdentifier: FinderViewCell.identifier)
    delegate = self
    dataSource = self
    rowHeight = 60
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  unowned let controller: UIViewController
  let finderViewModel: FinderViewModel
  var currentPathFiles: [FileInfo]
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension FinderTableView {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    currentPathFiles.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FinderViewCell.identifier, for: indexPath)
    if let cell = cell as? FinderViewCell {
      cell.fileInfo = currentPathFiles[indexPath.row]
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let fileInfo = currentPathFiles[indexPath.row]
    guard let fileResourceType = fileInfo.fileResourceType else { return }
    if fileResourceType == .directory {
      if fileInfo.url.path == ".." {
        _ = finderViewModel.pathStack.popLast()
      } else {
        finderViewModel.pathStack.append(fileInfo.url.lastPathComponent)
      }
      currentPathFiles = finderViewModel.currentPathFiles()
      tableView.reloadData()
      return
    }
    if fileResourceType == .regular {
      ProgressHUD.show()
      showFileEditorSheet(fileURL: fileInfo.url)
    }
  }

  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let fileInfo = currentPathFiles[indexPath.row]

    let action = UIContextualAction(style: .destructive, title: "删除") { [unowned self] _, _, completion in
      let alert = UIAlertController(title: "是否删除？", message: "文件删除后无法恢复，确认删除？", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { [unowned self] _ in
        finderViewModel.deleteFile(fileInfo: fileInfo)
        currentPathFiles = finderViewModel.currentPathFiles()
        tableView.reloadData()
        completion(true)
      }))
      alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in completion(false) }))
      self.controller.present(alert, animated: true, completion: nil)
    }

    return UISwipeActionsConfiguration(actions: [action])
  }

  func showFileEditorSheet(fileURL: URL) {
    // iOS15 版本后模式窗口有了新的方式 UISheetPresentationController
    // 模式窗口
    let textVC = TextEditViewController(fileURL: fileURL)
    controller.navigationController?.pushViewController(textVC, animated: true)
    ProgressHUD.dismiss()
  }

//  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//    currentPathFiles
//      .filter { $0.url.path != ".." }
//      .map { String($0.url.lastPathComponent.lowercased().first!) }
//      .reduce([String]()) { $0.contains($1) ? $0 : $0 + [$1] }
//  }
//
//  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//    let (index, _) = currentPathFiles.enumerated().first(where: { $1.url.lastPathComponent.lowercased().hasPrefix(title) }) ?? (0, nil)
//    return index
//  }
}
