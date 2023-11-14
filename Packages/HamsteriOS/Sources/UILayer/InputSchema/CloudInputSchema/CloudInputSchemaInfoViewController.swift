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
            alertTitle: "替换安装",
            message: "使用下载方案替换当前Rime目录，替换后原Rime路径下文件不可恢复，是否确认替换？",
            confirmTitle: "确认",
            confirmCallback: { [unowned self] in
              Task {
                await inputSchemaViewModel.installInputSchemaByReplace(info)
              }
            }
          )
        } else {
          self.alertConfirm(
            alertTitle: "覆盖安装",
            message: "使用下载方案覆盖当前Rime目录，覆盖后原Rime路径下相同文件名文件会被覆盖，是否确认覆盖",
            confirmTitle: "确认",
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
