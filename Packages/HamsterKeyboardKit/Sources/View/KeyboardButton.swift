//
//  KeyboardButton.swift
//
//
//  Created by morse on 2023/8/6.
//

import UIKit

/// 键盘键盘
public class KeyboardButton: UIControl {
  typealias ButtonWidth = CGFloat
  
  // MARK: - Properties
  
  /// 按键对应的操作
  private let action: KeyboardAction
  
  /// 按键对应操作的处理类
  private let actionHandler: KeyboardActionHandler
  
  /// 键盘上下文
  private let keyboardContext: KeyboardContext
  
  /// 键盘外观
  private let appearance: KeyboardAppearance
  
  /// 设备方向
  private let interfaceOrientation: InterfaceOrientation
  
  /// 按键内容视图
  private var buttonContentView: KeyboardButtonContentView!
  
  /// 按键阴影路径缓存
  private var shadowPathCache = [ButtonWidth: UIBezierPath]()
  
  /// 按键 underPath 缓存
  private var underPathCache = [ButtonWidth: UIBezierPath]()
  
  /// 按钮背景图
  private lazy var backgroundView: ShapeView = {
    let view = ShapeView()
    view.isOpaque = false
    view.layer.shouldRasterize = true
    view.layer.rasterizationScale = UIScreen.main.scale
    return view
  }()

  // MARK: - 计算属性
  
  private var buttonStyle: KeyboardButtonStyle {
    appearance.buttonStyle(for: action, isPressed: isSelected)
  }
  
  // MARK: - Initializations
  
  init(
    action: KeyboardAction,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    appearance: KeyboardAppearance)
  {
    self.action = action
    self.actionHandler = actionHandler
    self.keyboardContext = keyboardContext
    self.appearance = appearance
    self.interfaceOrientation = keyboardContext.interfaceOrientation
    
    super.init(frame: .zero)
    
    self.buttonContentView = KeyboardButtonContentView(
      action: action,
      style: buttonStyle,
      appearance: appearance,
      keyboardContext: keyboardContext)
    
    setupView()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Layout Functions
  
  override public var isSelected: Bool {
    didSet {
      print("button isSelected")
      buttonContentView.style = buttonStyle
      updateButtonStyle()
    }
  }

  func setupView() {
    addSubview(buttonContentView)
    buttonContentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      buttonContentView.topAnchor.constraint(equalTo: topAnchor),
      buttonContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      buttonContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      buttonContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    insertSubview(backgroundView, belowSubview: buttonContentView)
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      backgroundView.topAnchor.constraint(equalTo: topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
    
    // 不变的样式
    buttonContentView.layer.cornerRadius = cornerRadius
    backgroundView.shapeLayer.lineWidth = 1
    backgroundView.shapeLayer.fillColor = UIColor.clear.cgColor
    backgroundView.layer.shadowOpacity = Float(0.2)
    backgroundView.layer.masksToBounds = false
  }
  
  func updateButtonStyle() {
    let style = buttonStyle
    let isPressed = isSelected
    
    // 按钮样式
    buttonContentView.layer.borderColor = style.border?.color.cgColor ?? UIColor.clear.cgColor
    if isPressed {
      buttonContentView.backgroundColor = style.pressedOverlayColor ?? .clear
    } else {
      buttonContentView.backgroundColor = style.backgroundColor ?? .clear
    }
    
    // 按键底部深色样式
    backgroundView.shapeLayer.path = underPath.cgPath
    backgroundView.shapeLayer.strokeColor = (style.shadow?.color ?? UIColor.clear).cgColor
    
    // 按键阴影样式
    backgroundView.layer.shadowPath = shadowPath.cgPath
    backgroundView.layer.shadowColor = (style.shadow?.color ?? UIColor.clear).cgColor
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    updateButtonStyle()
  }
}

// MARK: - background view style

extension KeyboardButton {
  var cornerRadius: CGFloat {
    buttonStyle.cornerRadius ?? .zero
  }
  
  /// 按钮阴影路径
  var shadowPath: UIBezierPath {
//    let buttonWidth: ButtonWidth = bounds.width
    // TODO: 缓存存在问题, UI显示的路径不正确
//    if let path = shadowPathCache[buttonWidth] {
//      return path
//    }
    let shadowSize = buttonStyle.shadow?.size ?? 1
    let path = UIBezierPath(roundedRect: .init(x: 0, y: bounds.height, width: bounds.width, height: shadowSize), cornerRadius: shadowSize)
//    shadowPathCache[buttonWidth] = path
    return path
  }

  /// 按钮底部深色样式路径
  var underPath: UIBezierPath {
//    let buttonWidth: ButtonWidth = bounds.width
    // TODO: 缓存存在问题, UI显示的路径不正确
//    if let path = underPathCache[buttonWidth] {
//      return path
//    }
    
    let cornerRadius = cornerRadius
    let delta: CGFloat = 0.5 // 线宽的一半，backgroundView.shapeLayer.lineWidth = 1
    let maxX = bounds.width - delta
    let maxY = bounds.height + delta
    
    // 按钮底部边框
    let underPath: UIBezierPath = {
      // 按钮底部右下圆角
      let path = UIBezierPath(
        arcCenter: CGPoint(x: maxX - cornerRadius, y: maxY - cornerRadius), // 圆心
        radius: cornerRadius,
        startAngle: 0,
        endAngle: CGFloat.pi / 2,
        clockwise: true)

      let point = CGPoint(x: cornerRadius + delta, y: maxY)
      path.addLine(to: point)

      // 按钮底部左下圆角
      path.addArc(
        withCenter: CGPoint(x: cornerRadius + delta, y: maxY - cornerRadius), // 圆心
        radius: cornerRadius,
        startAngle: CGFloat.pi / 2,
        endAngle: CGFloat.pi,
        clockwise: true)
      return path
    }()
    
//    underPathCache[buttonWidth] = underPath
    
    return underPath
  }
}

/// layer 层为 CAShapeLayer 的 UIView
class ShapeView: UIView {
  var shapeLayer: CAShapeLayer!
  
  override class var layerClass: AnyClass {
    return CAShapeLayer.self
  }
  
  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    
    self.shapeLayer = layer as? CAShapeLayer
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct KeyboardButtonView_Previews: PreviewProvider {
  static func button(for action: KeyboardAction) -> some View {
    return UIViewPreview {
      let button = KeyboardButton(
        action: action,
        actionHandler: .preview,
        keyboardContext: .preview,
        appearance: .preview)
      
      button.frame = .init(x: 0, y: 0, width: 80, height: 80)
      return button
    }
  }

  static var previews: some View {
    VStack {
      button(for: .backspace)
      button(for: .space)
      button(for: .nextKeyboard)
      button(for: .character("a"))
      button(for: .character("A"))
    }
    .padding()
    .background(Color.gray)
    .cornerRadius(10)
    .environment(\.sizeCategory, .extraExtraLarge)
  }
}

#endif
