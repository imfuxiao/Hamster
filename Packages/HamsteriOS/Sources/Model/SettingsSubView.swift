//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Foundation

/// 主页设置子页面
public enum SettingsSubView {
  /// 设置主页面
  case root
  
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
  
  /// 滑动设置页面
  case swipeSettings
  
  /// iCloud页面
  case iCloud
  
  /// 备份页面
  case backup
  
  /// RIME 页面
  case rime
  
  /// 关于页面
  case about
  
  /// 使用的开源列表
  case openSource
  
  /// 表示返回根页面
  case none
}
