//
//  AppSettings+BundleInfo.swift
//  Hamster
//
//  Created by morse on 2023/3/25.
//

import Foundation

extension HamsterAppSettings {
  
  var appVersion: String {
    infoDictionary["CFBundleShortVersionString"] as? String ?? ""
  }

  var rimeVersion: String {
    infoDictionary["rimeVersion"] as? String ?? ""
  }
}
