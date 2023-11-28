//
//  CloudInputSchemaDetailsViewController.swift
//
//
//  Created by morse on 2023/11/12.
//

import Combine
import HamsterUIKit
import UIKit

class CloudInputSchemaInfoViewController: NibLessViewController {
  private let inputSchemaViewModel: InputSchemaViewModel
  private let inputSchemaInfo: InputSchemaViewModel.InputSchemaInfo
  private var subscriptions = Set<AnyCancellable>()

  init(inputSchemaViewModel: InputSchemaViewModel, inputSchemaInfo: InputSchemaViewModel.InputSchemaInfo) {
    self.inputSchemaViewModel = inputSchemaViewModel
    self.inputSchemaInfo = inputSchemaInfo

    super.init()

    combine()
  }

  override func loadView() {
    view = CloudInputSchemaInfoView(inputSchemaInfo: inputSchemaInfo, inputSchemaViewModel: inputSchemaViewModel)
    title = inputSchemaInfo.title
  }

  func combine() {
    inputSchemaViewModel.installInputSchemaSubject
      .eraseToAnyPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] type, info in
        if case .replace = type {
          self.alertConfirm(
            alertTitle: L10n.InputSchema.Cloud.AlertReplace.title,
            message: L10n.InputSchema.Cloud.AlertReplace.message,
            confirmTitle: L10n.confirm,
            confirmCallback: { [unowned self] in
              Task {
                await inputSchemaViewModel.installInputSchemaByReplace(info)
              }
            }
          )
        } else {
          self.alertConfirm(
            alertTitle: L10n.InputSchema.Cloud.AlertOverwrite.title,
            message: L10n.InputSchema.Cloud.AlertOverwrite.message,
            confirmTitle: L10n.confirm,
            confirmCallback: { [unowned self] in
              Task {
                await inputSchemaViewModel.installInputSchemaByOverwrite(info)
              }
            }
          )
        }
      }
      .store(in: &subscriptions)
  }
}
