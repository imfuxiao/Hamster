//
//  UIEdgeInsets+Insets.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-02.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import CoreGraphics
import UIKit

extension UIEdgeInsets {
  /**
   Create an `UIEdgeInsets` with the same insets everywhere.
   */
  static func all(_ all: CGFloat) -> UIEdgeInsets {
    self.init(top: all, left: all, bottom: all, right: all)
  }

  /**
   Create an `UIEdgeInsets` with horizontal/vertical values.
   */
  static func horizontal(_ horizontal: CGFloat, vertical: CGFloat) -> UIEdgeInsets {
    self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
  }
}
