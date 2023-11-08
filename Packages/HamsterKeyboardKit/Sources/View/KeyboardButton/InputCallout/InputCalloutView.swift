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
  private var originButtonBounds: CGRect = .zero
  private var oldFrame: CGRect = .zero

  private let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
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
    if let superview = superview, let rootView = superview.superview {
      // 气泡左右两侧顶点
      var leftTopPoint = superview.convert(CGPoint(x: frame.minX, y: frame.minY), to: rootView)
      var rightTopPoint = superview.convert(CGPoint(x: frame.minX + frame.width, y: frame.minY), to: rootView)

      // 检测气泡左右点是否超出父视图范围
      var leftTopPointContainsSuperview = rootView.frame.contains(leftTopPoint)
      var rightTopPointContainsSuperview = rootView.frame.contains(rightTopPoint)

      // 气泡尺寸
      var popSize = popBounds.size

      // 左右顶点都不在 rootView 时，尝试降低气泡高度
      if !leftTopPointContainsSuperview && !rightTopPointContainsSuperview {
        // 未开启工具栏，则首排不显示气泡
        if !keyboardContext.enableToolbar {
          return UIBezierPath()
        }

        let differenceHeight = rootView.frame.minY - leftTopPoint.y + 2

        leftTopPoint.y = leftTopPoint.y + differenceHeight
        rightTopPoint.y = rightTopPoint.y + differenceHeight
        popSize.height = popSize.height - differenceHeight

        // 注意：气泡 y 轴也需要降低
        self.frame = self.frame.offsetBy(dx: 0, dy: differenceHeight)

        leftTopPointContainsSuperview = rootView.frame.contains(leftTopPoint)
        rightTopPointContainsSuperview = rootView.frame.contains(rightTopPoint)
      }

      if !leftTopPointContainsSuperview, !rightTopPointContainsSuperview { // 降低高度后，仍不在 rootView 范围内，则不显示气泡
        return UIBezierPath()
      } else if !leftTopPointContainsSuperview, rightTopPointContainsSuperview {
        let diffSize = (popSize.width - originButtonBounds.width) / 2
        label.frame = CGRect(x: diffSize, y: 0, width: popSize.width - diffSize, height: popSize.height / 2)
      } else if leftTopPointContainsSuperview, !rightTopPointContainsSuperview {
        let diffSize = (popSize.width - originButtonBounds.width) / 2
        label.frame = CGRect(x: 0, y: 0, width: popSize.width - diffSize, height: popSize.height / 2)
      } else {
        label.frame = CGRect(x: 0, y: 0, width: popSize.width, height: popSize.height / 2)
      }

      let path = CAShapeLayer.inputCalloutPath(
        popSize: popSize,
        originButtonSize: originButtonBounds.size,
        cornerRadius: style.callout.cornerRadius,
        buttonCornerRadius: style.callout.buttonCornerRadius,
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
    shapeLayer.mask = maskShapeLayer
    shapeLayer.insertSublayer(boardLayer, at: 0)
  }

  func setText(_ text: String) {
    label.text = text
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    guard let _ = self.superview else { return }
    guard self.frame != .zero, oldFrame != self.frame else { return }

    // 将 size 扩大两倍，作为气泡的基础大小
    originButtonBounds = self.bounds
    popBounds = self.bounds.applying(CGAffineTransform(scaleX: 1.6, y: 2))

    // x 轴居中，y 轴底部对齐
    let tempFrame = self.frame
      .applying(CGAffineTransform(translationX: -(popBounds.width - self.bounds.width) / 2, y: -self.bounds.height))

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
