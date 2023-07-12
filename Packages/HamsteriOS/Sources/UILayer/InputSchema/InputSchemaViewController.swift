//
//  InputSchemaViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/12.
//

import Combine
import HamsterUIKit
import UIKit

class InputSchemaViewController: NibLessViewController {
  private let inputSchemaViewModel: InputSchemaViewModel
  private let documentPickerViewController: UIDocumentPickerViewController

  private var subscriptions = Set<AnyCancellable>()

  init(inputSchemaViewModel: InputSchemaViewModel, documentPickerViewController: UIDocumentPickerViewController) {
    self.inputSchemaViewModel = inputSchemaViewModel
    self.documentPickerViewController = documentPickerViewController

    super.init()

    self.documentPickerViewController.delegate = self

    // 导航栏导入按钮
    let importItem = UIBarButtonItem(systemItem: .add)
    importItem.action = #selector(inputSchemaViewModel.openDocumentPicker)
    importItem.target = inputSchemaViewModel
    navigationItem.rightBarButtonItem = importItem

    // 订阅 documentPicker 打开状态
    inputSchemaViewModel.presentDocumentPickerPublisher
      .receive(on: DispatchQueue.main)
      .sink { _ in
        self.presentZipDocument()
      }
      .store(in: &subscriptions)

    // 异常订阅
    inputSchemaViewModel.errorMessagePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentError(error: $0)
      }
      .store(in: &subscriptions)
  }

  func presentZipDocument() {
    // Present the document picker.
    present(documentPickerViewController, animated: true, completion: nil)
  }
}

// MARK: override UIViewController

extension InputSchemaViewController {
  override func loadView() {
    super.loadView()
    title = "输入方案设置"
    view = InputSchemaRootView(inputSchemaViewModel: inputSchemaViewModel)
  }
}

extension InputSchemaViewController: UIDocumentPickerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard !urls.isEmpty else {
      return
    }
    Task {
      await self.inputSchemaViewModel.importZipFile(fileURL: urls[0])
    }
  }
}
