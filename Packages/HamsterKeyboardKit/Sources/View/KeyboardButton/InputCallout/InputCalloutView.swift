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
  private var popBounds: CGRect = .zero
  private var oldFrame: CGRect = .zero

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

  /// 用来做 callout 按钮 board 样式
  public lazy var boardLayer: CAShapeLayer = {
    let boardLayer = CAShapeLayer()
    boardLayer.fillColor = UIColor.clear.cgColor
    boardLayer.strokeColor = style.callout.borderColor.cgColor
    boardLayer.borderWidth = 1
    boardLayer.opacity = 0.5
    return boardLayer
  }()

  public var calloutPath: UIBezierPath {
    if let superview = superview {
      let superviewFrame = keyboardContext.enableToolbar
        ? CGRect(
          x: superview.frame.minX,
          y: superview.frame.minX - keyboardContext.heightOfToolbar,
          width: superview.frame.width,
          height: superview.frame.height + keyboardContext.heightOfToolbar
        )
        : superview.frame

      // 检测气泡左右点是否超出父视图范围
      let leftTopPoint = CGPoint(x: frame.minX, y: frame.minY)
      let rightTopPoint = CGPoint(x: frame.minX + frame.width, y: frame.minY)
      let leftTopPointContainsSuperview = superviewFrame.contains(leftTopPoint)
      let rightTopPointContainsSuperview = superviewFrame.contains(rightTopPoint)

      if !leftTopPointContainsSuperview, rightTopPointContainsSuperview {
        label.textAlignment = .right
        trailingAnchor.constraint(equalToSystemSpacingAfter: label.trailingAnchor, multiplier: 1.5).isActive = true
      } else if leftTopPointContainsSuperview, !rightTopPointContainsSuperview {
        label.textAlignment = .left
        label.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1.5).isActive = true
      } else {
        label.textAlignment = .center
      }

      let path = CAShapeLayer.inputCalloutPath(
        size: popBounds.size,
        cornerRadius: style.callout.buttonCornerRadius,
        leftTopPointContainsSuperview: leftTopPointContainsSuperview,
        rightTopPointContainsSuperview: rightTopPointContainsSuperview
      )

      return path
    }

    return UIBezierPath()
  }

  init(calloutContext: InputCalloutContext, keyboardContext: KeyboardContext, style: KeyboardInputCalloutStyle) {
    self.calloutContext = calloutContext
    self.keyboardContext = keyboardContext
    self.style = style

    super.init(frame: .zero)

    setupView()
  }

  func setupView() {
    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.widthAnchor.constraint(equalTo: widthAnchor),
      label.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
    ])

    shapeLayer.mask = maskShapeLayer
    shapeLayer.insertSublayer(boardLayer, at: 0)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    guard self.superview != nil else { return }
    guard self.frame != .zero, oldFrame != self.frame else { return }

    // 将 size 扩大两倍，作为气泡的基础大小
    popBounds = self.bounds
      .applying(CGAffineTransform(scaleX: 2, y: 2))

    // x 轴居中，y 轴底部对齐
    let tempFrame = self.frame
      .applying(CGAffineTransform(translationX: -self.bounds.width / 2, y: -self.bounds.height))

    self.frame = CGRect(origin: tempFrame.origin, size: popBounds.size)
    self.oldFrame = self.frame

    // callout 按钮 mask
    let calloutPath = calloutPath
    maskShapeLayer.path = calloutPath.cgPath
    boardLayer.path = calloutPath.cgPath

    setupAppearance()
  }

  func setupAppearance() {
    self.shapeLayer.zPosition = 1000
    let calloutStyle = style.callout
    backgroundColor = calloutStyle.backgroundColor

    label.textColor = calloutStyle.textColor
    label.font = style.font.font
  }
}
