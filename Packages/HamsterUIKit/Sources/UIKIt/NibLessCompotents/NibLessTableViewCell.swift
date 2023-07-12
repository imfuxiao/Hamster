//
//  NibLessTableViewCell.swift
//
//
//  Created by morse on 2023/7/5.
//

import UIKit

open class NibLessTableViewCell: UITableViewCell {
  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  @available(*, unavailable, message: "为了支持从 init 依赖注入，从 nib 加载这个视图控制器是不被支持的。")
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
