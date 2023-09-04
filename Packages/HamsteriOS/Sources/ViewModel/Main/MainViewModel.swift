//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Foundation

public class MainViewModel: ObservableObject {
  @Published
  public var subView: SettingsSubView = .none

  /// 导航到输入方案页面
  public func navigationToInputSchema() {
    subView = .inputSchema
  }
}
