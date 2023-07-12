//
//  ConformAlert.swift
//
//
//  Created by morse on 2023/7/12.
//

import UIKit

public struct Conform {
  public var title: String
  public var message: String
  public var okTitle: String
  public var cancelTitle: String
  public var okAction: () -> Void
  public var cancelAction: () -> Void

  public init(
    title: String,
    message: String,
    okTitle: String = "确定",
    cancelTitle: String = "取消",
    okAction: @escaping () -> Void,
    cancelAction: @escaping () -> Void = {}
  ) {
    self.title = title
    self.message = message
    self.okTitle = okTitle
    self.cancelTitle = cancelTitle
    self.okAction = okAction
    self.cancelAction = cancelAction
  }
}
