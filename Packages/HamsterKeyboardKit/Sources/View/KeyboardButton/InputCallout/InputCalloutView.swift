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
  private var oldFrame: CGRect = .zero
  private var cacheCalloutPath = [CGSize: UIBezierPath]()

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
    if let path = cacheCalloutPath[self.oldFrame.size] {
      return path
    }
    let path = CAShapeLayer.inputCalloutPath(size: self.oldFrame.size, cornerRadius: style.callout.buttonCornerRadius)
    cacheCalloutPath[self.oldFrame.size] = path
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
    guard oldFrame != self.frame else { return }
    oldFrame = self.bounds
    // callout 按钮 mask
    let calloutPath = calloutPath.cgPath
    maskShapeLayer.path = calloutPath
    boardLayer.path = calloutPath
  }
}
