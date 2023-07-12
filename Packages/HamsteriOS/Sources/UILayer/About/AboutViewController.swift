//
//  AboutViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import HamsterUIKit
import UIKit

protocol AboutViewModelFactory {
  func makeAboutViewModel() -> AboutViewModel
}

class AboutViewController: NibLessViewController {
  private let aboutViewModel: AboutViewModel

  init(aboutViewModelFactory: AboutViewModelFactory) {
    self.aboutViewModel = aboutViewModelFactory.makeAboutViewModel()
    super.init()
  }

  override func loadView() {
    super.loadView()

    title = "关于"
    view = AboutRootView(aboutViewModel: aboutViewModel)
  }
}
