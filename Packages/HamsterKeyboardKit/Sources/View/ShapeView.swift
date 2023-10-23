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

public extension CAShapeLayer {
  /// 按钮底部深色样式路径
  ///
  /// @Parameter size: 图形 Size
  /// @parameter cornerRadius: 圆角半径
  static func underPath(size: CGSize, cornerRadius: CGFloat) -> UIBezierPath {
    let offset: CGFloat = 1
    let maxX: CGFloat = size.width
    let maxY: CGFloat = size.height

    let underPath: UIBezierPath = {
      let path = UIBezierPath()

      // 右下底部圆角起始点
      var point = CGPoint(x: maxX, y: maxY - cornerRadius)
      path.move(to: point)

      // 右下圆角（从 0 度到 90度，顺时针）
      path.addArc(
        withCenter: CGPoint(x: maxX - cornerRadius, y: maxY - cornerRadius),
        radius: cornerRadius,
        startAngle: 0,
        endAngle: CGFloat.pi / 2,
        clockwise: true)

      // 左下圆角起始点
      point = CGPoint(x: cornerRadius, y: maxY)
      path.addLine(to: point)

      // 左下圆角（从 90 度到 180 度，顺时针）
      path.addArc(
        withCenter: CGPoint(x: cornerRadius, y: maxY - cornerRadius),
        radius: cornerRadius,
        startAngle: CGFloat.pi / 2,
        endAngle: CGFloat.pi,
        clockwise: true)

      // 左下偏移点
      point = CGPoint(x: 0, y: maxY - cornerRadius - offset)
      path.addLine(to: point)

      // 左下偏移圆角（从 180 度到 90 度，逆时针）
      path.addArc(
        withCenter: CGPoint(x: cornerRadius, y: maxY - cornerRadius - offset),
        radius: cornerRadius,
        startAngle: CGFloat.pi,
        endAngle: CGFloat.pi / 2,
        clockwise: false)

      // 右下偏移点
      point = CGPoint(x: maxX - cornerRadius, y: maxY - offset)
      path.addLine(to: point)

      // 右下偏移圆角（从 90 度到 0 度，逆时针）
      path.addArc(
        withCenter: CGPoint(x: maxX - cornerRadius, y: maxY - cornerRadius - offset),
        radius: cornerRadius,
        startAngle: CGFloat.pi / 2,
        endAngle: 0,
        clockwise: false)

      path.close()

      return path
    }()
    return underPath
  }
}
