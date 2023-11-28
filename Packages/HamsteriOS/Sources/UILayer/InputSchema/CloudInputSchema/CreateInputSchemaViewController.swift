//
//  UploadInputSchemaViewController.swift
//
//
//  Created by morse on 2023/11/13.
//

import Combine
import HamsterUIKit
import UIKit

class CreateInputSchemaViewController: NibLessViewController {
  private let inputSchemaViewModel: InputSchemaViewModel
  private var subscriptions = Set<AnyCancellable>()

  init(inputSchemaViewModel: InputSchemaViewModel) {
    self.inputSchemaViewModel = inputSchemaViewModel
    super.init()
    combine()
  }

  override func loadView() {
    view = CreateInputSchemaRootView(inputSchemaViewModel: inputSchemaViewModel)
    title = L10n.InputSchema.Create.title
  }

  func combine() {
    inputSchemaViewModel.uploadInputSchemaConfirmSubject
      .eraseToAnyPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] callback in
        alertConfirm(alertTitle: L10n.InputSchema.Create.alertTitle, message: L10n.InputSchema.Create.alertMessage, confirmTitle: L10n.InputSchema.Create.alertConfirm, confirmCallback: {
          callback()
        })
      }
      .store(in: &subscriptions)
  }
}
