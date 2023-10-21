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

  /// 弹出一个确认对话框
  public func alertConfirm(alertTitle: String, message: String? = nil, confirmTitle: String, confirmCallback: @escaping () -> Void) {
    let optionMenu = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)

    let confirmAction = UIAlertAction(title: confirmTitle, style: .destructive) { _ in
      confirmCallback()
    }
    optionMenu.addAction(confirmAction)

    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
    optionMenu.addAction(cancelAction)

    present(optionMenu, animated: true)
  }

  /// 弹出包含一个文本框的对话框
  public func alertText(alertTitle: String? = nil, submitTitle: String, submitCallback: @escaping (UITextField) -> Void) {
    let optionMenu = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
    optionMenu.addTextField()

    let submitAction = UIAlertAction(title: submitTitle, style: .default) { [unowned optionMenu] _ in
      let textField = optionMenu.textFields![0]
      submitCallback(textField)
    }
    optionMenu.addAction(submitAction)

    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
    optionMenu.addAction(cancelAction)

    present(optionMenu, animated: true)
  }

  /// 弹出选择列表对话表
  public func alertOptionSheet(alertTitle: String? = nil, addAlertOptions: @escaping (UIAlertController) -> Void) {
    let optionMenu = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)

    addAlertOptions(optionMenu)

    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
    optionMenu.addAction(cancelAction)

    present(optionMenu, animated: true)
  }
}
