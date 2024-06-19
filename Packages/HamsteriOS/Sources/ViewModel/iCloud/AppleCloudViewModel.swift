//
//  File.swift
//
//
//  Created by morse on 2023/7/6.
//

import Foundation
import HamsterKit
import OSLog
import ProgressHUD
import UIKit

public class AppleCloudViewModel: ObservableObject {
  public let settingsViewModel: SettingsViewModel

  public var regexOnCopyFile: String {
    get {
      HamsterAppDependencyContainer.shared.configuration.general?.regexOnCopyFile?.joined(separator: ",") ?? ""
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.general?.regexOnCopyFile = (newValue.split(separator: ",").map { String($0) })
      HamsterAppDependencyContainer.shared.applicationConfiguration.general?.regexOnCopyFile = (newValue.split(separator: ",").map { String($0) })
    }
  }

  lazy var settings: [SettingItemModel] = [
    .init(
      text: L10n.ICloud.enableAppleCloud,
      type: .toggle,
      toggleValue: { [unowned self] in settingsViewModel.enableAppleCloud },
      toggleHandled: { [unowned self] in
        settingsViewModel.enableAppleCloud = $0
      }
    ),
    .init(
      text: L10n.ICloud.copyFileToICloud,
      type: .button,
      buttonAction: { [unowned self] in
        Task {
          await copyFileToiCloud()
        }
      }
    ),
    .init(
      //      icon: UIImage(systemName: "square.and.pencil"),
      text: L10n.ICloud.regexOnCopyFile,
      textValue: { [unowned self] in regexOnCopyFile },
      textHandled: { [unowned self] in
        regexOnCopyFile = $0
      }
    )
  ]

  init(settingsViewModel: SettingsViewModel) {
    self.settingsViewModel = settingsViewModel
  }

  func copyFileToiCloud() async {
    do {
      await ProgressHUD.animate(L10n.ICloud.Upload.copying, interaction: false)
      let regexList = regexOnCopyFile.split(separator: ",").map { String($0) }
      try FileManager.copySandboxSharedSupportDirectoryToAppleCloud(regexList)
      try FileManager.copySandboxUserDataDirectoryToAppleCloud(regexList)
      await ProgressHUD.success(L10n.ICloud.Upload.success, interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("apple cloud copy to iCloud error: \(error)")
      await ProgressHUD.failed(L10n.ICloud.Upload.failed(error.localizedDescription), interaction: false, delay: 1.5)
    }
  }
}
