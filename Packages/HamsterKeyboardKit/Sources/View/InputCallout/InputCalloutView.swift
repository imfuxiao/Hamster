//
//  InputCalloutView.swift
//
//
//  Created by morse on 2023/8/17.
//

import UIKit

public class InputCalloutView: ShapeView {
  private var calloutContext: InputCalloutContext
  private var keyboardContext: KeyboardContext
  private let style: KeyboardInputCalloutStyle
  private var oldBounds: CGRect?

  public let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.baselineAdjustment = UIBaselineAdjustment.alignCenters
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.2
    label.numberOfLines = 1
    return label
  }()

  ///  用来做 callout 按钮的 mask
  public lazy var maskShapeLayer: CAShapeLayer = {
    let maskShapeLayer = CAShapeLayer()
    return maskShapeLayer
  }()

  /// 用来做 callout 按钮 board + shadow 样式
  public lazy var boardLayer: CAShapeLayer = {
    let boardLayer = CAShapeLayer()
    boardLayer.fillColor = UIColor.clear.cgColor
    boardLayer.strokeColor = style.callout.borderColor.cgColor
    boardLayer.borderWidth = 1
    boardLayer.opacity = 0.5
//    boardLayer.shadowRadius = style.callout.shadowRadius
//    boardLayer.shadowColor = style.callout.shadowColor.cgColor
//    boardLayer.shadowColor = UIColor.red.cgColor
//    boardLayer.shadowOffset = CGSize(width: 0, height: -1)
    return boardLayer
  }()

  public var calloutPath: UIBezierPath {
    let path = UIBezierPath()

    print("width: \(frame.width), height: \(frame.height)")

    let calloutStyle = style.callout

    let width = frame.width / 4

    let buttonCornerRadius = calloutStyle.buttonCornerRadius
    let rightMaxX: CGFloat = frame.width
    let rightMinX: CGFloat = rightMaxX - width
    let leftMinX: CGFloat = 0
    let leftMaxX: CGFloat = width

    let minY = keyboardContext.interfaceOrientation.isPortrait ? frame.height / 2 : frame.height / 3
    let maxY = frame.height

    // 从按钮右下圆角启始点开始
    var point = CGPoint(x: rightMinX, y: maxY - buttonCornerRadius)
    path.move(to: point)

    // 右下圆角
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

    // 左上竖线
    point = CGPoint(x: leftMinX, y: buttonCornerRadius)
    path.addLine(to: point)

    // 左上圆角
    path.addArc(
      withCenter: CGPoint(x: leftMinX + buttonCornerRadius, y: buttonCornerRadius),
      radius: buttonCornerRadius,
      startAngle: CGFloat.pi,
      endAngle: CGFloat.pi / 2 * 3,
      clockwise: true)

    // 顶部横线
    point = CGPoint(x: rightMaxX - buttonCornerRadius, y: 0)
    path.addLine(to: point)

    // 右上圆角
    point = CGPoint(x: rightMaxX - buttonCornerRadius, y: 0 + buttonCornerRadius)
    path.addArc(
      withCenter: point,
      radius: buttonCornerRadius,
      startAngle: CGFloat.pi / 2 * 3,
      endAngle: 0,
      clockwise: true)

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

    path.close()
    return path
  }

  init(calloutContext: InputCalloutContext, keyboardContext: KeyboardContext, style: KeyboardInputCalloutStyle) {
    self.calloutContext = calloutContext
    self.keyboardContext = keyboardContext
    self.style = style

    super.init(frame: .zero)

    setupView()
  }

  func setupView() {
    let calloutStyle = style.callout
    backgroundColor = calloutStyle.backgroundColor

    label.textColor = calloutStyle.textColor
    label.font = style.font.font

    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
    ])

    shapeLayer.mask = maskShapeLayer
    shapeLayer.insertSublayer(boardLayer, at: 0)
  }

  func updateStyle() {
    guard oldBounds != self.bounds else { return }
    oldBounds = self.bounds
    // callout 按钮 mask
    let calloutPath = calloutPath.cgPath
    maskShapeLayer.path = calloutPath
    boardLayer.path = calloutPath
  }
}
