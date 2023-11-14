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
    title = "上传开源输入方案"
  }

  func combine() {
    inputSchemaViewModel.uploadInputSchemaConfirmSubject
      .eraseToAnyPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] callback in
        alertConfirm(alertTitle: "上传输入方案", message: "请勿上传非自己创作且无版权的输入方案，不符合规范的方案会被定期清除。", confirmTitle: "确认上传", confirmCallback: {
          callback()
        })
      }
      .store(in: &subscriptions)
  }
}
