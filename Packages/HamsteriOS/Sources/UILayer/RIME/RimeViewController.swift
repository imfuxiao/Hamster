//
//  RimeViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import Combine
import HamsterUIKit
import UIKit

public class RimeViewController: NibLessViewController {
  public let rimeViewModel: RimeViewModel
  private lazy var finderViewModel = FinderViewModel()
  private var subscriptions = Set<AnyCancellable>()
  private lazy var rimeLoggerViewController = RimeLoggerViewController(finderViewModel: finderViewModel)

  init(rimeViewModel: RimeViewModel) {
    self.rimeViewModel = rimeViewModel
    super.init()

    combine()
  }

  func combine() {
    self.rimeViewModel.openRimeLoggerViewPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        presentRimeLogger()
      }
      .store(in: &subscriptions)

    finderViewModel.presentTextEditorPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentTextEditor(fileURL: $0)
      }
      .store(in: &subscriptions)

    self.rimeViewModel.rimeRestPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] rest in
        alertConfirm(alertTitle: "RIME 重置", message: "重置会恢复到初始安装状态，是否确认重置？", confirmTitle: "重置", confirmCallback: {
          rest()
        })
      }
      .store(in: &subscriptions)
  }
}

// MARK: override UIViewController

public extension RimeViewController {
  override func loadView() {
    title = "RIME"
    view = RimeRootView(rimeViewModel: rimeViewModel)
  }

  func presentRimeLogger() {
    self.navigationController?.pushViewController(rimeLoggerViewController, animated: true)
  }

  func presentTextEditor(fileURL: URL) {
    let textVC = TextEditorViewController(fileURL: fileURL, enableEditorState: false)
    navigationController?.pushViewController(textVC, animated: true)
  }
}
