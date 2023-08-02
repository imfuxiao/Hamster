//
//  UIView.swift
//
//
//  Created by morse on 21/7/2023.
//

import UIKit

public extension UIView {
  func fillSuperview(withConstant constant: CGFloat = .zero) {
    guard let superview = superview else { return }

    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: superview.topAnchor, constant: constant),
      superview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: constant),
      leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: constant),
      superview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: constant),
    ])
  }

  func fillSuperviewOnMarginsGuide() {
    guard let superview = superview else { return }

    translatesAutoresizingMaskIntoConstraints = false
    let layoutGuide = superview.layoutMarginsGuide
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: layoutGuide.topAnchor),
      bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
      leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
    ])
  }
}
