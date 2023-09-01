//
//  SettingsViewController.swift
//
//  Created by morse on 2023/6/12.
//

import HamsterKit
import HamsterUIKit
import OSLog
import ProgressHUD
import UIKit

protocol SettingsViewModelFactory {
  func makeSettingsViewModel() -> SettingsViewModel
}

public class SettingsViewController: NibLessViewController {
  // MARK: - properties

  private var settingsViewModel: SettingsViewModel

  init(settingsViewModel: SettingsViewModel) {
    self.settingsViewModel = settingsViewModel
    super.init()
  }
}

// MARK: override UIViewController

public extension SettingsViewController {
  override func loadView() {
    title = "输入法设置"
    view = SettingsRootView(settingsViewModel: settingsViewModel)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Task {
      do {
        try await self.settingsViewModel.loadAppData()
      } catch {
        ProgressHUD.showError("导入数据异常", interaction: false, delay: 2)
        Logger.statistics.error("load app data error: \(error)")
      }
    }
  }
}