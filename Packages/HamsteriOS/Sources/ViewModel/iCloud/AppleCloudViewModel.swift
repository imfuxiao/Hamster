//
//  File.swift
//
//
//  Created by morse on 2023/7/6.
//

import Foundation
import HamsterKit
import UIKit

public class AppleCloudViewModel: ObservableObject {
  public let settingsViewModel: SettingsViewModel

  public var regexOnCopyFile: String {
    get {
      HamsterAppDependencyContainer.shared.configuration.general?.regexOnCopyFile?.joined(separator: ",") ?? ""
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.general?.regexOnCopyFile = (newValue.split(separator: ",").map { String($0) })
    }
  }

  lazy var settings: [SettingItemModel] = [
    .init(
      text: "iCloud",
      type: .toggle,
      toggleValue: settingsViewModel.enableAppleCloud,
      toggleHandled: { [unowned self] in
        settingsViewModel.enableAppleCloud = $0
      }
    ),
    .init(
      text: "拷贝应用文件至iCloud",
      type: .button,
      buttonAction: { [unowned self] in
        do {
          let regexList = regexOnCopyFile.split(separator: ",").map { String($0) }
          try FileManager.copySandboxSharedSupportDirectoryToAppleCloud(regexList)
          try FileManager.copySandboxUserDataDirectoryToAppleCloud(regexList)
        } catch {
          throw error
        }
      }
    ),
    .init(
      icon: UIImage(systemName: "square.and.pencil"),
      text: regexOnCopyFile,
      placeholder: "正则过滤",
      textHandled: { [unowned self] in
        regexOnCopyFile = $0
      }
    )
  ]

  init(settingsViewModel: SettingsViewModel) {
    self.settingsViewModel = settingsViewModel
  }
}
