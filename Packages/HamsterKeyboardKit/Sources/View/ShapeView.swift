//
//  ShapeView.swift
//
//
//  Created by morse on 2023/8/17.
//

import UIKit

/// layer 层为 CAShapeLayer 的 UIView
public class ShapeView: UIView {
  public var shapeLayer: CAShapeLayer!

  override public class var layerClass: AnyClass {
    return CAShapeLayer.self
  }

  override public init(frame: CGRect = .zero) {
    super.init(frame: frame)

    self.shapeLayer = layer as? CAShapeLayer
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
