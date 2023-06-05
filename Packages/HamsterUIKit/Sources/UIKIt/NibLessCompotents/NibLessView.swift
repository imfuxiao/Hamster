//
//  NilLessView.swift
//
//
//  Created by morse on 2023/7/5.
//

import UIKit

open class NibLessView: UIView {
  override public init(frame: CGRect) {
    super.init(frame: frame)
  }

  @available(*, unavailable,
             message: "Loading this view from a nib is unsupported in favor of initializer dependency injection.")
  public required init?(coder aDecoder: NSCoder) {
    fatalError("Loading this view from a nib is unsupported in favor of initializer dependency injection.")
  }

  /// 构建视图层次
  open func constructViewHierarchy() {}

  /// 激活视图约束
  open func activateViewConstraints() {}

  /// 设置 View 样式
  open func setupAppearance() {}
}
