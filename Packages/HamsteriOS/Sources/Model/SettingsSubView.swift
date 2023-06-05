//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Foundation

/// 主页设置子页面
public enum SettingsSubView: String {
  /// 输入方案页面
  case inputSchema
  
  /// 输入方案上传页面
  case uploadInputSchema
  
  /// 文件管理页面
  case finder
  
  /// 键盘设置页面
  case keyboardSettings
  
  /// 键盘配色页面
  case colorSchema
  
  /// 反馈设置页面
  case feedback
  
  /// iCloud页面
  case iCloud
  
  /// 备份页面
  case backup
  
  /// RIME 页面
  case rime
  
  /// 关于页面
  case about

  /// 主页面
  case main


  /// 空页面
  case none
}
