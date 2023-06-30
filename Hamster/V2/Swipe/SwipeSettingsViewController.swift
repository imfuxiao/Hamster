//
//  SwipeSettingsViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/25.
//

import UIKit

class SwipeSettingsViewController: UIViewController {
  init(appSettings: HamsterAppSettings) {
    self.appSettings = appSettings
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let appSettings: HamsterAppSettings
}

// MARK: override UIViewController

extension SwipeSettingsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
