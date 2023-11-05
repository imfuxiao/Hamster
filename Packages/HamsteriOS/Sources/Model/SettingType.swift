//
//  SettingModel.swift
//  Hamster
//
//  Created by morse on 2023/6/12.
//

import UIKit

/// 设置类型
public enum SettingType: Hashable, Equatable {
  case navigation
  case toggle
  case textField
  case button

  // 下拉选项 cell
  case pullDown

  // 设置文本
  case settings

  case step
}
