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
  private var cacheCalloutPath = [CGSize: UIBezierPath]()
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
    if let path = cacheCalloutPath[popBounds.size] {
      return path
    }

    let path = CAShapeLayer.inputCalloutPath(size: popBounds.size, cornerRadius: style.callout.buttonCornerRadius)
    cacheCalloutPath[popBounds.size] = path

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
    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
    ])

    shapeLayer.mask = maskShapeLayer
    shapeLayer.insertSublayer(boardLayer, at: 0)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    guard self.superview != nil else { return }
    guard self.frame != .zero, oldFrame != self.frame else { return }


    popBounds = self.bounds
      .applying(CGAffineTransform(scaleX: 2, y: 2))

    self.shapeLayer.zPosition = 1000

    let origin = self.frame
      .applying(CGAffineTransform(translationX: -self.bounds.width / 2, y: -self.bounds.height))
      .origin

    self.frame = CGRect(origin: origin, size: popBounds.size)
    self.oldFrame = self.frame

    // callout 按钮 mask
    let calloutPath = calloutPath
    maskShapeLayer.path = calloutPath.cgPath
    boardLayer.path = calloutPath.cgPath

    setupAppearance()
  }

  func setupAppearance() {
    let calloutStyle = style.callout
    backgroundColor = calloutStyle.backgroundColor

    label.textColor = calloutStyle.textColor
    label.font = style.font.font
  }
}
