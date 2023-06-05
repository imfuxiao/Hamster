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
  private var rimeViewModel: RimeViewModel
  private var backupViewModel: BackupViewModel

  init(settingsViewModel: SettingsViewModel, rimeViewModel: RimeViewModel, backupViewModel: BackupViewModel) {
    self.settingsViewModel = settingsViewModel
    self.rimeViewModel = rimeViewModel
    self.backupViewModel = backupViewModel
    super.init()
  }
}

// MARK: override UIViewController

public extension SettingsViewController {
  override func loadView() {
    title = "输入法设置"
    view = SettingsRootView(settingsViewModel: settingsViewModel, rimeViewModel: rimeViewModel, backupViewModel: backupViewModel)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Task {
      do {
        try await self.settingsViewModel.loadAppData()
      } catch {
        ProgressHUD.failed("导入数据异常", interaction: false, delay: 2)
        Logger.statistics.error("load app data error: \(error)")
      }
    }
  }
}
