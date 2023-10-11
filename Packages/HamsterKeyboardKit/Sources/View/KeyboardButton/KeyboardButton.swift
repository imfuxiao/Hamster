//
//  KeyboardButton.swift
//
//
//  Created by morse on 2023/8/6.
//

import Combine
import HamsterKit
import OSLog
import UIKit

/// 键盘键盘
public class KeyboardButton: UIControl {
  typealias ButtonBounds = CGRect
  
  // MARK: - Properties
  
  /// 布局中所处行，从 0 开始
  let row: Int
  
  /// 布局中所处列，从 0 开始
  let column: Int
  
  /// 是否用来填充空白
  /// 如: 标准键盘第二行 A 键的右边, L 键的左边等
  let isSpacer: Bool
  
  /// 对应布局的 item，存储按键的 action 信息
  /// 注意：item中尺寸信息在自动布局中不在使用了，这些信息在 SwiftUI 布局中使用
  let item: KeyboardLayoutItem
  
  /// 按键对应的操作
  let action: KeyboardAction
  
  /// 按键对应操作的处理类
  let actionHandler: KeyboardActionHandler
  
  /// 键盘上下文
  let keyboardContext: KeyboardContext
  
  let rimeContext: RimeContext
  
  /// 键盘外观
  let appearance: KeyboardAppearance
  
  /// 呼出的上下文
  let calloutContext: KeyboardCalloutContext
  
  /// 需要动态调整大小的约束
  var topConstraints = [NSLayoutConstraint]()
  var bottomConstraints = [NSLayoutConstraint]()
  var leadingConstraints = [NSLayoutConstraint]()
  var trailingConstraints = [NSLayoutConstraint]()
  
  /// 设备方向
  var interfaceOrientation: InterfaceOrientation
  
  /// 按键阴影路径缓存
  var shadowPathCache = [ButtonBounds: UIBezierPath]()
  
  /// 按键 underPath 缓存
  var underPathCache = [ButtonBounds: UIBezierPath]()
  
  // MARK: - touch state
  
  // 按钮按下状态
  var isPressed = false
  
  /// 按钮长按开始时间
  var longPressDate: Date? = nil
  
  /// 按钮重复开始时间
  var repeatDate: Date? = nil
  
  /// 手势开始时间戳
  var touchBeginTimestamp: TimeInterval? = nil
  
  /// 轻扫手势处理
  var swipeGestureHandle: (() -> Void)?
  
  /// 拖动开始位置
  var dragStartLocation: CGPoint? = nil
  
  /// 最后一次拖拽的位置
  var lastDragLocation: CGPoint? = nil
  
  /// 是否触发 .release 操作
  /// 注意：
  /// 1. 长按空格状态下不应该触发 release
  /// 2. 在 calloutContext 呼出开始显示的时候，不应触发 release
  var shouldApplyReleaseAction = true
  
  /// 在按钮 bounds 外，仍然可以触发 .release 操作的区域大小的百分比
  /// 默认为 `0.75`，即把按钮 bounds 的 size 在扩大这个值
  /// 注意：这个值需要与划动的阈值相配合
  let releaseOutsideTolerance: Double = 0.75
  
  let repeatTimer: RepeatGestureTimer = .shared
  
  lazy var longPressDelay: TimeInterval = {
    if let longPressDelay = keyboardContext.longPressDelay {
      return longPressDelay
    }
    return GestureButtonDefaults.longPressDelay
  }()
  
  let repeatDelay: TimeInterval = GestureButtonDefaults.repeatDelay
  
  var userInterfaceStyle: UIUserInterfaceStyle
  
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: - subview
  
  /// 按键内容视图
  lazy var buttonContentView: KeyboardButtonContentView = {
    let contentView = KeyboardButtonContentView(
      item: item,
      style: buttonStyle,
      appearance: appearance,
      keyboardContext: keyboardContext,
      rimeContext: rimeContext)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    return contentView
  }()
  
  // 按钮底部立体阴影视图
  lazy var underShadowView: ShapeView = {
    let view = ShapeView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var inputCalloutView: InputCalloutView = {
    let view = InputCalloutView(
      calloutContext: calloutContext.input,
      keyboardContext: keyboardContext,
      style: inputCalloutStyle)
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  // MARK: - 计算属性
  
  /// 按钮样式
  /// 注意：action 与 是否按下的状态 isPressed 决定按钮样式
  var buttonStyle: KeyboardButtonStyle {
    appearance.buttonStyle(for: item.action, isPressed: isHighlighted)
  }
  
  /// 布局配置
  var layoutConfig: KeyboardLayoutConfiguration {
    return .standard(for: keyboardContext)
  }
  
  /// input呼出样式
  var inputCalloutStyle: KeyboardInputCalloutStyle {
    var style = appearance.inputCalloutStyle
    let insets = item.insets
    style.callout.buttonInset = insets
    return style
  }
  
  /// 长按呼出样式
  var actionCalloutStyle: KeyboardActionCalloutStyle {
    var style = appearance.actionCalloutStyle
    let insets = item.insets
    style.callout.buttonInset = insets
    return style
  }
  
  override public var isHighlighted: Bool {
    didSet {
      updateButtonStyle(isPressed: isHighlighted)
    }
  }
  
  // MARK: - Initializations
  
  init(
    row: Int,
    column: Int,
    item: KeyboardLayoutItem,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    rimeContext: RimeContext,
    calloutContext: KeyboardCalloutContext,
    appearance: KeyboardAppearance)
  {
    self.row = row
    self.column = column
    self.item = item
    self.action = item.action
    self.isSpacer = item.action.isSpacer
    self.actionHandler = actionHandler
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext
    self.calloutContext = calloutContext
    self.appearance = appearance
    self.interfaceOrientation = keyboardContext.interfaceOrientation
    self.userInterfaceStyle = keyboardContext.traitCollection.userInterfaceStyle
    
    super.init(frame: .zero)
    
    // 系统外观发生变化，键盘颜色随亦随之变化
    keyboardContext.$traitCollection
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard userInterfaceStyle != $0.userInterfaceStyle else { return }
        userInterfaceStyle = $0.userInterfaceStyle
        
        let style = appearance.buttonStyle(for: item.action, isPressed: isPressed)
        buttonContentView.style = style
      }
      .store(in: &subscriptions)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    repeatTimer.stop()
  }
  
  // MARK: - Layout Functions
  
  override public func didMoveToWindow() {
    super.didMoveToWindow()
    
    // fix: 系统为 light mode， 而部分状态(safari 隐私模式，App搜索页面)下为 dark mode, 导致键盘按钮颜色异常
    if keyboardContext.traitCollection.userInterfaceStyle != traitCollection.userInterfaceStyle {
      keyboardContext.traitCollection = traitCollection
    }
    
    setupSubview()
  }
  
  func setupSubview() {
    /// spacer 类型不可见
    alpha = isSpacer ? 0 : 1
    
    let layoutConfig = layoutConfig
    setupContentView(layoutConfig)
    setupUnderShadowView(layoutConfig)
    updateButtonStyle(isPressed: isHighlighted)
    
    NSLayoutConstraint.activate(topConstraints + bottomConstraints + leadingConstraints + trailingConstraints)
  }

  /// 设置按钮内容视图
  func setupContentView(_ layoutConfig: KeyboardLayoutConfiguration) {
    // 不变的样式
    buttonContentView.layer.cornerRadius = cornerRadius
    
    addSubview(buttonContentView)
    buttonContentView.translatesAutoresizingMaskIntoConstraints = false
    let insets = item.insets
    
    let buttonContentTrailingConstraint = buttonContentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)
    buttonContentTrailingConstraint.identifier = "buttonContent-\(row)-\(column)-trailing"
    buttonContentTrailingConstraint.priority = .defaultHigh
    
    topConstraints.append(buttonContentView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top))
    bottomConstraints.append(buttonContentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom))
    leadingConstraints.append(buttonContentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left))
    // trailingConstraints.append(buttonContentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right))
    trailingConstraints.append(buttonContentTrailingConstraint)
  }
  
  /// 设置按钮底部阴影及暗线
  func setupUnderShadowView(_ layoutConfig: KeyboardLayoutConfiguration) {
    // 不变的样式
    underShadowView.shapeLayer.lineWidth = 1
    underShadowView.shapeLayer.fillColor = UIColor.clear.cgColor
    underShadowView.shapeLayer.masksToBounds = false
//    underShadowView.shapeLayer.shadowOpacity = Float(0.2)
    
    insertSubview(underShadowView, belowSubview: buttonContentView)
    NSLayoutConstraint.activate([
      underShadowView.topAnchor.constraint(equalTo: buttonContentView.topAnchor),
      underShadowView.bottomAnchor.constraint(equalTo: buttonContentView.bottomAnchor),
      underShadowView.leadingAnchor.constraint(equalTo: buttonContentView.leadingAnchor),
      underShadowView.trailingAnchor.constraint(equalTo: buttonContentView.trailingAnchor),
    ])
  }
  
  /// 设置 inputCallout 样式
  func setupInputCallout() {
    guard keyboardContext.displayButtonBubbles else { return }
    guard inputCalloutView.superview == nil else { return }
    guard let superview = superview else { return }
    superview.addSubview(inputCalloutView)
    NSLayoutConstraint.activate([
      inputCalloutView.widthAnchor.constraint(equalTo: buttonContentView.widthAnchor, multiplier: 2),
      inputCalloutView.heightAnchor.constraint(equalTo: buttonContentView.heightAnchor, multiplier: 2),
      inputCalloutView.centerXAnchor.constraint(equalTo: buttonContentView.centerXAnchor),
      inputCalloutView.bottomAnchor.constraint(equalTo: buttonContentView.bottomAnchor),
    ])
  }
  
  func updateSubviewConstraints() {
    guard interfaceOrientation != keyboardContext.interfaceOrientation else { return }
    interfaceOrientation = keyboardContext.interfaceOrientation

    Logger.statistics.debug("\(self.row)-\(self.column) updateSubviewConstraints()")
    
    let insets = item.insets

    // Logger.statistics.debug("KeyboardButtonRowItem layoutSubviews() rowHeight: \(layoutConfig.rowHeight), buttonInsets [left: \(insets.left), top: \(insets.top), right: \(insets.right), bottom: \(insets.bottom)]")

    topConstraints.forEach { $0.constant = insets.top }
    bottomConstraints.forEach { $0.constant = -insets.bottom }
    leadingConstraints.forEach { $0.constant = insets.left }
    trailingConstraints.forEach { $0.constant = -insets.right }
  }
  
  func updateButtonStyle(isPressed: Bool) {
    // Logger.statistics.debug("updateButtonStyle(), isPressed: \(isPressed), isHighlighted: \(self.isHighlighted)")
    let style = appearance.buttonStyle(for: item.action, isPressed: isPressed)
    buttonContentView.style = style
      
    // 按键底部深色样式
    underShadowView.shapeLayer.strokeColor = (style.shadow?.color ?? UIColor.clear).cgColor
      
    // 按键阴影样式
//    underShadowView.shapeLayer.shadowPath = shadowPath.cgPath
//    underShadowView.shapeLayer.shadowOffset = .init(width: 0, height: 1)
//    underShadowView.shapeLayer.shadowColor = (style.shadow?.color ?? UIColor.clear).cgColor
      
    // 按钮样式
    buttonContentView.backgroundColor = style.backgroundColor
    if isPressed {
      underShadowView.shapeLayer.opacity = 0
      // TODO: 按键气泡重新调整
      showInputCallout()
    } else {
      underShadowView.shapeLayer.path = underPath.cgPath
      underShadowView.shapeLayer.opacity = 0.7
      hideInputCallout()
    }
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    setupInputCallout()
    updateSubviewConstraints()
    updateButtonStyle(isPressed: isHighlighted)
  }
  
  // MARK: debuger
  
  override public var debugDescription: String {
    let description = super.debugDescription
    return "\(row)-\(column) button: \(description)"
  }
}

// MARK: - Input Callout

extension KeyboardButton {
  func showInputCallout() {
    guard keyboardContext.displayButtonBubbles else { return }
    // 屏幕横向无按键气泡
    guard keyboardContext.interfaceOrientation.isPortrait else { return }
    guard action.showKeyBubble else { return }
    inputCalloutView.isHidden = false
    inputCalloutView.label.text = item.key?.labelText ?? action.inputCalloutText?.uppercased()
    inputCalloutView.updateStyle()
  }
  
  func hideInputCallout() {
    guard keyboardContext.displayButtonBubbles else { return }
    // 屏幕横向无按键气泡
    guard keyboardContext.interfaceOrientation.isPortrait else { return }
    inputCalloutView.isHidden = true
  }
}

// MARK: - background view style

extension KeyboardButton {
  var cornerRadius: CGFloat {
    buttonStyle.cornerRadius ?? .zero
  }
  
  /// 按钮阴影路径
  var shadowPath: UIBezierPath {
    // 缓存 Path
    if let path = shadowPathCache[frame] {
      return path
    }
    let shadowSize = buttonStyle.shadow?.size ?? 1
    let rect = CGRect(
      x: 0,
      y: underShadowView.bounds.height,
      width: underShadowView.bounds.width,
      height: shadowSize)
    let path = UIBezierPath(
      roundedRect: rect,
      cornerRadius: shadowSize)
    shadowPathCache[frame] = path
    return path
  }

  /// 按钮底部深色样式路径
  var underPath: UIBezierPath {
    // 缓存 PATH
//    if let path = underPathCache[frame] {
//      return path
//    }
    let cornerRadius = cornerRadius
    let delta: CGFloat = 0.5 // 线宽的一半，backgroundView.shapeLayer.lineWidth = 1
    let maxX = underShadowView.frame.width - delta
    let maxY = underShadowView.frame.height + delta
    
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
//    underPathCache[frame] = underPath
    return underPath
  }
}

extension CGRect: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(origin.x)
    hasher.combine(origin.y)
    hasher.combine(size.width)
    hasher.combine(size.height)
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct KeyboardButtonView_Previews: PreviewProvider {
  static func button(for action: KeyboardAction) -> some View {
    return UIViewPreview {
      let button = KeyboardButton(
        row: 0,
        column: 0,
        item: .init(action: action, size: .init(width: .input, height: 54), insets: .zero, swipes: []),
        actionHandler: .preview,
        keyboardContext: .preview,
        rimeContext: RimeContext(),
        calloutContext: .disabled,
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
