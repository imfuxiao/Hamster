//
//  OpenProjectViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import HamsterUIKit
import UIKit

protocol OpenSourceViewModelFactory {
  func makeOpenSourceViewModel() -> OpenSourceViewModel
}

class OpenSourceViewController: NibLessViewController {
  private let openSourceViewModel: OpenSourceViewModel

  init(openSourceViewModelFactory: OpenSourceViewModelFactory) {
    self.openSourceViewModel = openSourceViewModelFactory.makeOpenSourceViewModel()
    super.init()
  }
}

// override UIViewController

extension OpenSourceViewController {
  override func loadView() {
    title = L10n.About.Oss.title
    view = OpenSourceRootView(openSourceViewModel: openSourceViewModel)
  }
}
