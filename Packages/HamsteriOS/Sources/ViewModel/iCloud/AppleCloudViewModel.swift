//
//  File.swift
//
//
//  Created by morse on 2023/7/6.
//

import Foundation
import HamsterKit

public class AppleCloudViewModel: ObservableObject {
  public let settingsViewModel: SettingsViewModel

  @Published
  public var regexOnCopyFile: String
    = HamsterAppDependencyContainer.shared.configuration.general?.regexOnCopyFile?.joined(separator: ",") ?? ""
  {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.general?.regexOnCopyFile = (regexOnCopyFile.split(separator: ",").map { String($0) })
    }
  }

  init(settingsViewModel: SettingsViewModel) {
    self.settingsViewModel = settingsViewModel
  }
}
