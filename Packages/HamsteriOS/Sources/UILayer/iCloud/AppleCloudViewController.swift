//
//  AppleCloudViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//
import HamsterUIKit
import ProgressHUD
import UIKit

protocol AppleCloudViewModelFactory {
  func makeAppleCloudViewModel() -> AppleCloudViewModel
}

class AppleCloudViewController: NibLessViewController {
  // MARK: properties

  let appleCloudViewModelFactory: AppleCloudViewModelFactory

  // MARK: methods

  init(appleCloudViewModelFactory: AppleCloudViewModelFactory) {
    self.appleCloudViewModelFactory = appleCloudViewModelFactory
    super.init()
  }
}

// MARK: override UIViewController

extension AppleCloudViewController {
  override func loadView() {
    title = "iCloud同步"
    let viewModel = appleCloudViewModelFactory.makeAppleCloudViewModel()
    view = AppleCloudRootView(viewModel: viewModel)
  }
}
