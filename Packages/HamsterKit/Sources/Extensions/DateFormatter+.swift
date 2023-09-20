//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation

public extension DateFormatter {
  /// 年-月-日 时:分:秒 格式
  static var longTimeFormatStyle: DateFormatter {
    let format = DateFormatter()
    format.locale = Locale(identifier: "zh_Hans_SG")
    format.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return format
  }

  /// 年-月-日 格式
  static var shortTimeFormatStyle: DateFormatter {
    let format = DateFormatter()
    format.locale = Locale(identifier: "zh_Hans_SG")
    format.dateFormat = "yyyyMMdd"
    return format
  }

  /// 临时文件名
  static var tempFileNameStyle: DateFormatter {
    let format = DateFormatter()
    format.locale = Locale(identifier: "zh_Hans_SG")
    format.dateFormat = "yyyyMMdd-HHmmss"
    return format
  }
}
