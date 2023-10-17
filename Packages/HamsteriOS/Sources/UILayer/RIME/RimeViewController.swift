//
//  RimeViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import HamsterUIKit
import UIKit

public class RimeViewController: NibLessViewController {
  public let rimeViewModel: RimeViewModel

  init(rimeViewModel: RimeViewModel) {
    self.rimeViewModel = rimeViewModel
    super.init()
  }
}

// MARK: override UIViewController

public extension RimeViewController {
  override func loadView() {
    title = "RIME"
    view = RimeRootView(rimeViewModel: rimeViewModel)
  }
}
