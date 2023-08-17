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

  public let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.textAlignment = .center
    label.baselineAdjustment = UIBaselineAdjustment.alignCenters
//    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.numberOfLines = 1
    return label
  }()

  private lazy var calloutPath: UIBezierPath = {
    let path = UIBezierPath()

    return path
  }()

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
    layer.borderColor = calloutStyle.borderColor.cgColor

    addSubview(label)
    label.font = style.font.font
  }
}
