//
//  ColorSchemaSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import HamsterUIKit
import UIKit

protocol ColorSchemaViewModelFactory {
  func makeColorSchemaViewModel() -> ColorSchemaViewModel
}

class ColorSchemaSettingViewController: NibLessViewController {
  private let colorSchemaViewModel: ColorSchemaViewModel

  init(colorSchemaViewModelFactory: ColorSchemaViewModelFactory) {
    self.colorSchemaViewModel = colorSchemaViewModelFactory.makeColorSchemaViewModel()

    super.init()
  }
}

// MARK: override UIViewController

extension ColorSchemaSettingViewController {
  override func loadView() {
    super.loadView()

    title = "键盘配色"
    view = ColorSchemaRootView(colorSchemaViewModel: colorSchemaViewModel)
  }
}
