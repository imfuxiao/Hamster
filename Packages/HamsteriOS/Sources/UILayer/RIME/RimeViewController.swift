//
//  RimeViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import HamsterUIKit
import UIKit

protocol RimeViewModelFactory {
  func makeRimeViewModel() -> RimeViewModel
}

public class RimeViewController: NibLessViewController {
  public let rimeViewModel: RimeViewModel
  init(rimeViewModelFactory: RimeViewModelFactory) {
    self.rimeViewModel = rimeViewModelFactory.makeRimeViewModel()
    super.init()
  }
}

// MARK: override UIViewController

public extension RimeViewController {
  override func loadView() {
    super.loadView()

    title = "RIME"
    view = RimeRootView(rimeViewModel: rimeViewModel)
  }
}
