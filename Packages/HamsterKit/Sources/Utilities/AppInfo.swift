//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation

public enum AppInfo {
  static let infoDictionary = Bundle.main.infoDictionary ?? [:]

  public static let appVersion: String = {
    (Self.infoDictionary["CFBundleShortVersionString"] as? String ?? "")
      + "(" + (Self.infoDictionary["CFBundleVersion"] as? String ?? "") + ")"
  }()

  public static let rimeVersion: String = {
    Self.infoDictionary["rimeVersion"] as? String ?? ""
  }()
}
