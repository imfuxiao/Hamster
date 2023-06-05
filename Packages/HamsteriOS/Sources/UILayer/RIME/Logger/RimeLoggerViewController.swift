//
//  RimeLoggerViewController.swift
//
//
//  Created by morse on 2023/11/8.
//

import HamsterUIKit
import UIKit

class RimeLoggerViewController: NibLessViewController {
  private let finderViewModel: FinderViewModel

  lazy var rimeLoggerFileBrowseView: FileBrowserView = {
    // 防止文件夹被删除而产生异常
    try? FileManager.createDirectory(override: false, dst: FileManager.sandboxRimeLogDirectory)
    let fileBrowserViewModel = FileBrowserViewModel(rootURL: FileManager.sandboxRimeLogDirectory, enableEditorState: false)
    return FileBrowserView(finderViewModel: finderViewModel, fileBrowserViewModel: fileBrowserViewModel)
  }()

  init(finderViewModel: FinderViewModel) {
    self.finderViewModel = finderViewModel
    super.init()
  }

  override func loadView() {
    view = rimeLoggerFileBrowseView
    title = "RIME 日志"
  }
}
