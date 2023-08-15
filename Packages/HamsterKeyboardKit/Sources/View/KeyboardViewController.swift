//
//  KeyboardViewController.swift
//
//
//  Created by morse on 2023/8/15.
//

import UIKit

class KeyboardViewController: UIViewController {
  private let rootView: UIView

  init(view: UIView) {
    self.rootView = view
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeFromParent()
    view.removeFromSuperview()
  }

  /**
   将 KeyboardViewController 添加到 KeyboardInputViewController 中，并设置约束条件，以便在内容大小发生变化时调整键盘扩展的大小。
   */
  public func add(to controller: KeyboardInputViewController) {
    controller.addChild(self)
    controller.view.addSubview(view)
    didMove(toParent: controller)
    view.backgroundColor = .clear
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
      view.topAnchor.constraint(equalTo: controller.view.topAnchor),
      view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
    ])
  }

  override func loadView() {
    super.loadView()

    view = rootView
    rootView.backgroundColor = .clear
  }
}
