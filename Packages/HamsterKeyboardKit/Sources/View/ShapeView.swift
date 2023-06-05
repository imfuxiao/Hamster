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

  /// 按键气泡路径
  ///
  /// @Parameter size 按键气泡尺寸
  /// @Parameter cornerRadius 圆角半径, 用在 callout 的上部分
  /// @Parameter buttonCornerRadius 圆角半径, 用在 callout 的下部分，与重叠的按键圆角保持一致
  static func inputCalloutPath(popSize: CGSize, originButtonSize: CGSize, cornerRadius: CGFloat, buttonCornerRadius: CGFloat, leftTopPointContainsSuperview: Bool, rightTopPointContainsSuperview: Bool) -> UIBezierPath {
    let path = UIBezierPath()

    let diffWidth = (popSize.width - originButtonSize.width) / 2

    // 按键气泡沿 x 轴共4个点，已垂直平分线为中间点，左右两侧各两个点
    let rightMinX: CGFloat = popSize.width - diffWidth
    let rightMaxX: CGFloat = rightTopPointContainsSuperview ? popSize.width : rightMinX

    let leftMinX: CGFloat = leftTopPointContainsSuperview ? 0 : diffWidth
    let leftMaxX: CGFloat = diffWidth

    let minY = popSize.height / 2
    let maxY = popSize.height

    // 从按键右下圆角启始点开始
    var point = CGPoint(x: rightMinX, y: maxY - buttonCornerRadius)
    path.move(to: point)

    // 右下圆角(0度到90度，顺时针)
    point = CGPoint(x: rightMinX - buttonCornerRadius, y: maxY - buttonCornerRadius)
    path.addArc(
      withCenter: point,
      radius: buttonCornerRadius,
      startAngle: 0,
      endAngle: CGFloat.pi / 2,
      clockwise: true)

    // 底部横线
    point = CGPoint(x: leftMaxX + buttonCornerRadius, y: maxY)
    path.addLine(to: point)

    // 左下圆角
    point = CGPoint(x: leftMaxX + buttonCornerRadius, y: maxY - buttonCornerRadius)
    path.addArc(
      withCenter: point,
      radius: buttonCornerRadius,
      startAngle: CGFloat.pi / 2,
      endAngle: CGFloat.pi,
      clockwise: true)

    if leftTopPointContainsSuperview {
      // 左下竖线
      point = CGPoint(x: leftMaxX, y: maxY - minY / 2)
      path.addLine(to: point)

      // 左侧呼出曲线
      path.addCurve(
        to: CGPoint(x: leftMinX, y: minY),
        controlPoint1: CGPoint(
          x: point.x,
          y: minY + minY / 6),
        controlPoint2: CGPoint(
          x: leftMinX,
          y: minY + minY / 3))
    }

    // 左上竖线
    point = CGPoint(x: leftMinX, y: cornerRadius)
    path.addLine(to: point)

    // 左上圆角
    path.addArc(
      withCenter: CGPoint(x: leftMinX + cornerRadius, y: cornerRadius),
      radius: cornerRadius,
      startAngle: CGFloat.pi,
      endAngle: CGFloat.pi / 2 * 3,
      clockwise: true)

    // 顶部横线
    point = CGPoint(x: rightMaxX - cornerRadius, y: 0)
    path.addLine(to: point)

    // 右上圆角
    point = CGPoint(x: rightMaxX - cornerRadius, y: 0 + cornerRadius)
    path.addArc(
      withCenter: point,
      radius: cornerRadius,
      startAngle: CGFloat.pi / 2 * 3,
      endAngle: 0,
      clockwise: true)

    if rightTopPointContainsSuperview {
      // 右上竖线
      point = CGPoint(x: rightMaxX, y: minY)
      path.addLine(to: point)

      // 右侧曲线，与左侧曲线为对称
      path.addCurve(
        to: CGPoint(x: rightMinX, y: maxY - minY / 2),
        controlPoint1: CGPoint(
          x: point.x,
          y: minY + minY / 3),
        controlPoint2: CGPoint(
          x: rightMinX,
          y: minY + minY / 6))
    }

    path.close()
    return path
  }
}
