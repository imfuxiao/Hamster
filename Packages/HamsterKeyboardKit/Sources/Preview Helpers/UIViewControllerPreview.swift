//
//  UIViewControllerPreview.swift
//
//
//  Created by morse on 2023/8/10.
//

import UIKit

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
  func updateUIViewController(_ uiViewController: ViewController, context: Context) {}

  let viewController: ViewController

  init(_ builder: @escaping () -> ViewController) {
    viewController = builder()
  }

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> ViewController {
    viewController
  }
}
#endif
