//
//  NibLessViewController.swift
//
//
//  Created by morse on 2023/7/5.
//

import UIKit

/// Hamster 基类 UIViewController
open class NibLessViewController: UIViewController {
  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  @available(*, unavailable,
             message: "为了支持从 init 依赖注入，从 nib 加载这个视图控制器是不被支持的。")
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
