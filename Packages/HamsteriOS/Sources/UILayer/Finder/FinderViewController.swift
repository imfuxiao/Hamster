//
//  FileManagerViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import Combine
import HamsterUIKit
import UIKit

protocol FinderViewModelFactory {
  func makeFinderViewModel() -> FinderViewModel
}

protocol FileBrowserViewModelFactory {
  func makeFileBrowserViewModel(rootURL: URL) -> FileBrowserViewModel
}

class FinderViewController: NibLessViewController {
  private let finderViewModel: FinderViewModel
  private let fileBrowserViewModelFactory: FileBrowserViewModelFactory
  private var subscription = Set<AnyCancellable>()

  init(finderViewModelFactory: FinderViewModelFactory, fileBrowserViewModelFactory: FileBrowserViewModelFactory) {
    self.finderViewModel = finderViewModelFactory.makeFinderViewModel()
    self.fileBrowserViewModelFactory = fileBrowserViewModelFactory

    super.init()
  }

  func presentTextEditor(fileURL: URL) {
    // iOS15 版本后模式窗口有了新的方式 UISheetPresentationController
    // 模式窗口
    let textVC = TextEditorViewController(fileURL: fileURL, isLineWrappingEnabled: finderViewModel.textEditorLineWrappingEnabled)
    navigationController?.pushViewController(textVC, animated: true)
  }

  func presentConformAlert(conform: Conform) {
    let alert = UIAlertController(
      title: conform.title,
      message: conform.message,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(
      title: conform.okTitle,
      style: .destructive,
      handler: { _ in
        conform.okAction()
      }
    ))
    alert.addAction(UIAlertAction(
      title: conform.cancelTitle,
      style: .cancel,
      handler: { _ in
        conform.cancelAction()
      }
    ))
    present(alert, animated: true, completion: nil)
  }
}

// MARK: override UIViewController

extension FinderViewController {
  override func loadView() {
    title = "方案文件管理"
    view = FinderRootView(finderViewModel: finderViewModel, fileBrowserViewModelFactory: fileBrowserViewModelFactory)

    finderViewModel.presentTextEditorPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentTextEditor(fileURL: $0)
      }
      .store(in: &subscription)

    finderViewModel.conformPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentConformAlert(conform: $0)
      }
      .store(in: &subscription)
  }
}
