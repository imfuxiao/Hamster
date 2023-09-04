//
//  AboutViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import Combine
import HamsterUIKit
import UIKit

protocol AboutViewModelFactory {
  func makeAboutViewModel() -> AboutViewModel
}

protocol OpenSourceViewControllerFactory {
  func makeOpenSourceViewController() -> OpenSourceViewController
}

class AboutViewController: NibLessViewController {
  private let aboutViewModel: AboutViewModel
  private let openSourceViewController: OpenSourceViewController
  private var subscriptions = Set<AnyCancellable>()

  init(aboutViewModelFactory: AboutViewModelFactory, openSourceViewControllerFactory: OpenSourceViewControllerFactory) {
    self.aboutViewModel = aboutViewModelFactory.makeAboutViewModel()
    self.openSourceViewController = openSourceViewControllerFactory.makeOpenSourceViewController()
    super.init()
  }

  override func loadView() {
    super.loadView()

    title = "关于"
    view = AboutRootView(aboutViewModel: aboutViewModel)

    aboutViewModel.$displayOpenSourceView
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard $0 else { return }
        presentOpenSourceView()
      }
      .store(in: &subscriptions)
  }

  func presentOpenSourceView() {
    navigationController?.pushViewController(openSourceViewController, animated: true)
  }
}
