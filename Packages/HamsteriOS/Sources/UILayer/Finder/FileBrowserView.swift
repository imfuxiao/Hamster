//
//  FinderViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import Combine
import HamsterUIKit
import ProgressHUD
import UIKit

/// 文件浏览
class FileBrowserView: NibLessView {
  // MARK: properties

  let finderViewModel: FinderViewModel
  let fileBrowserViewModel: FileBrowserViewModel

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.register(FinderViewCell.self, forCellReuseIdentifier: FinderViewCell.identifier)
    tableView.rowHeight = 60
    return tableView
  }()

  private var subscription = Set<AnyCancellable>()

  // MARK: methods

  init(frame: CGRect = .zero, finderViewModel: FinderViewModel, fileBrowserViewModel: FileBrowserViewModel) {
    self.finderViewModel = finderViewModel
    self.fileBrowserViewModel = fileBrowserViewModel

    super.init(frame: frame)

    constructViewHierarchy()
    activateViewConstraints()

    self.fileBrowserViewModel.$files
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        tableView.reloadData()
      }
      .store(in: &subscription)
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      self.fileBrowserViewModel.files = self.fileBrowserViewModel.currentPathFiles()
    }
  }

  override func constructViewHierarchy() {
    addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
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

  func showFileEditorSheet(fileURL: URL) {
    finderViewModel.openFileEditorController(fileURL: fileURL)
  }
}

extension FileBrowserView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    fileBrowserViewModel.files.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FinderViewCell.identifier, for: indexPath)
    if let cell = cell as? FinderViewCell {
      cell.updateWithFileInfo(fileBrowserViewModel.files[indexPath.row])
    }
    return cell
  }
}

extension FileBrowserView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let fileInfo = fileBrowserViewModel.files[indexPath.row]
    guard let fileResourceType = fileInfo.fileResourceType else { return }

    if fileResourceType == .directory {
      if fileInfo.url.path == ".." {
        _ = fileBrowserViewModel.pathStack.popLast()
      } else {
        fileBrowserViewModel.pathStack.append(fileInfo.url.lastPathComponent)
      }
      return
    }

    if fileResourceType == .regular {
      finderViewModel.openFileEditorController(fileURL: fileInfo.url)
    }
  }

  public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard fileBrowserViewModel.enableEditorState else { return nil }
    let fileInfo = fileBrowserViewModel.files[indexPath.row]

    let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [unowned self] _, _, _ in
      self.finderViewModel.deleteFileConform { [unowned self] in
        self.fileBrowserViewModel.deleteFile(fileInfo: fileInfo)
      }
    }

    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}
