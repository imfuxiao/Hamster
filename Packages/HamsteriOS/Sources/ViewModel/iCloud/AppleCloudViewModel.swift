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
      text: "iCloud",
      type: .toggle,
      toggleValue: { [unowned self] in settingsViewModel.enableAppleCloud },
      toggleHandled: { [unowned self] in
        settingsViewModel.enableAppleCloud = $0
      }
    ),
    .init(
      text: "拷贝应用文件至iCloud",
      type: .button,
      buttonAction: { [unowned self] in
        Task {
          await copyFileToiCloud()
        }
      }
    ),
    .init(
      //      icon: UIImage(systemName: "square.and.pencil"),
      text: "正则过滤",
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
      await ProgressHUD.animate("拷贝中……", interaction: false)
      let regexList = regexOnCopyFile.split(separator: ",").map { String($0) }
      try FileManager.copySandboxSharedSupportDirectoryToAppleCloud(regexList)
      try FileManager.copySandboxUserDataDirectoryToAppleCloud(regexList)
      await ProgressHUD.success("拷贝成功", interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("apple cloud copy to iCloud error: \(error)")
      await ProgressHUD.failed("拷贝失败: \(error.localizedDescription)", interaction: false, delay: 1.5)
    }
  }
}
