//
//  NumberNineGridSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import Combine
import HamsterUIKit
import ProgressHUD
import UIKit

class NumberNineGridSettingsViewController: NibLessViewController {
  private var subscriptions = Set<AnyCancellable>()

  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  lazy var segmentedView: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: ["设置", "符号列表"])
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.addTarget(
      keyboardSettingsViewModel,
      action: #selector(keyboardSettingsViewModel.numberNineGridSegmentedControlChange(_:)),
      for: .valueChanged
    )
    return segmentedControl
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }
}

// MARK: override UIViewController

extension NumberNineGridSettingsViewController {
  override func loadView() {
    super.loadView()

    navigationItem.titleView = segmentedView
    view = NumberNineGridSettingsRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)

    keyboardSettingsViewModel.selectedSegmentIndexPublished
      .combineLatest(keyboardSettingsViewModel.$symbolTableIsEditing)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] index, isEditing in
        if index == 1 {
          let rightBarButtonItem = UIBarButtonItem(
            title: isEditing ? "编辑" : "完成",
            style: .plain,
            target: keyboardSettingsViewModel,
            action: #selector(keyboardSettingsViewModel.changeTableEditModel)
          )
          navigationItem.rightBarButtonItem = rightBarButtonItem
          return
        }
        navigationItem.rightBarButtonItem = nil
      }
      .store(in: &subscriptions)
  }
}
