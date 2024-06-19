//
//  UploadInputSchemaViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import HamsterUIKit
import ProgressHUD
import UIKit

protocol UploadInputSchemaViewModelFactory {
  func makeUploadInputSchemaViewModel() -> UploadInputSchemaViewModel
}

public class UploadInputSchemaViewController: NibLessViewController {
  private let viewModel: UploadInputSchemaViewModel

  init(uploadInputSchemaViewModelFactory: UploadInputSchemaViewModelFactory) {
    self.viewModel = uploadInputSchemaViewModelFactory.makeUploadInputSchemaViewModel()

    super.init()
  }
}

// MARK: override UIViewController

public extension UploadInputSchemaViewController {
  override func loadView() {
    title = L10n.InputSchema.Upload.title2
    view = UploadInputSchemaRootView(uploadInputSchemaViewModel: viewModel)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    UIApplication.shared.isIdleTimerDisabled = true
    viewModel.startWiFiMonitor()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    UIApplication.shared.isIdleTimerDisabled = false
    viewModel.stopFileServer()
  }
}
