//
//  CloudInputSchemaViewController.swift
//
//
//  Created by morse on 2023/11/11.
//

import Combine
import HamsterUIKit
import UIKit

class CloudInputSchemaViewController: NibLessViewController {
  private let inputSchemaViewModel: InputSchemaViewModel
  private var subscriptions = Set<AnyCancellable>()

  init(inputSchemaViewModel: InputSchemaViewModel) {
    self.inputSchemaViewModel = inputSchemaViewModel

    super.init()

    combine()
  }

  func combine() {
    inputSchemaViewModel.inputSchemaDetailsPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentInputSchemaInfoView($0)
      }
      .store(in: &subscriptions)

    inputSchemaViewModel.presentDocumentPickerPublisher
      .receive(on: DispatchQueue.main)
      .sink {
        switch $0 {
        case .uploadCloudInputSchema: self.presentUploadInputSchemaView()
        case .inputSchema: self.presentInputSchema()
        default: return
        }
      }
      .store(in: &subscriptions)

    inputSchemaViewModel.presentUploadInputSchemaZipFileSubject
      .eraseToAnyPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        presentDocumentPickerView()
      }
      .store(in: &subscriptions)
  }

  override func loadView() {
    view = CloudInputSchemaRootView(inputSchemaViewModel: inputSchemaViewModel)
    title = "开源输入方案"
  }

  func presentInputSchemaInfoView(_ info: InputSchemaViewModel.InputSchemaInfo) {
    let vc = CloudInputSchemaInfoViewController(inputSchemaViewModel: inputSchemaViewModel, inputSchemaInfo: info)
    navigationController?.pushViewController(vc, animated: true)
  }

  func presentUploadInputSchemaView() {
    let vc = CreateInputSchemaViewController(inputSchemaViewModel: inputSchemaViewModel)
    navigationController?.pushViewController(vc, animated: true)
  }

  func presentDocumentPickerView() {
    let vc = UIDocumentPickerViewController(forOpeningContentTypes: [.zip], asCopy: true)
    vc.delegate = self
    vc.allowsMultipleSelection = false
    present(vc, animated: true)
  }

  func presentInputSchema() {
    HamsterAppDependencyContainer.shared.mainViewModel.navigation(.inputSchema)
  }
}

// MARK: - implementation UIDocumentPickerDelegate

extension CloudInputSchemaViewController: UIDocumentPickerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard !urls.isEmpty else { return }
    inputSchemaViewModel.uploadInputSchemaPickerFileSubject.send(urls[0])
  }
}
