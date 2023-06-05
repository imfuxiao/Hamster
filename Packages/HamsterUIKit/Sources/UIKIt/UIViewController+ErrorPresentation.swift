//
//  UIViewController+ErrorPresentation.swift
//
//
//  Created by morse on 2023/7/8.
//

import UIKit

public extension UIViewController {
  /// alert error message
  func presentError(error: ErrorMessage) {
    let errorAlertController = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "确认", style: .default)
    errorAlertController.addAction(okAction)
    present(errorAlertController, animated: true)
  }
}
