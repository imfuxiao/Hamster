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
  private var subscriptions = Set<AnyCancellable>()

  init(rimeViewModel: RimeViewModel) {
    self.rimeViewModel = rimeViewModel
    super.init()

    combine()
  }

  func combine() {
    self.rimeViewModel.rimeRestPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] rest in
        alertConfirm(alertTitle: "RIME 重置", message: "重置会恢复到初始安装状态，是否确认重置？" ,confirmTitle: "重置", confirmCallback: {
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
}
