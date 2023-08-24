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
  typealias ButtonWidth = CGFloat
  
  // MARK: - Properties
  
  /// 布局中所处行，从 0 开始
  public let row: Int
  
  /// 布局中所处列，从 0 开始
  public let column: Int
  
  /// 是否用来填充空白
  /// 如: 标准键盘第二行 A 键的右边, L 键的左边等
  public let isSpacer: Bool
  
  /// 对应布局的 item，存储按键的 action 信息
  /// 注意：item中尺寸信息在自动布局中不在使用了，这些信息在 SwiftUI 布局中使用
  public let item: KeyboardLayoutItem
  
  /// 按键对应的操作
  private let action: KeyboardAction
  
  /// 按键对应操作的处理类
  private let actionHandler: KeyboardActionHandler
  
  /// 键盘上下文
  private let keyboardContext: KeyboardContext
  
  /// 键盘外观
  private let appearance: KeyboardAppearance
  
  /// 呼出的上下文
  private let calloutContext: KeyboardCalloutContext
  
  /// 需要动态调整大小的约束
  public var topConstraints = [NSLayoutConstraint]()
  public var bottomConstraints = [NSLayoutConstraint]()
  public var leadingConstraints = [NSLayoutConstraint]()
  public var trailingConstraints = [NSLayoutConstraint]()
  
  /// 设备方向
  private var interfaceOrientation: InterfaceOrientation
  
  /// 按键内容视图
  private var buttonContentView: KeyboardButtonContentView!
  
  /// 按键阴影路径缓存
  private var shadowPathCache = [ButtonWidth: UIBezierPath]()
  
  /// 按键 underPath 缓存
  private var underPathCache = [ButtonWidth: UIBezierPath]()
  
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: - touch state
  
  // 按钮按下状态
  @Published
  private var isPressed = false
  
  /// 按钮长按开始时间
  private var longPressDate: Date? = nil
  
  /// 按钮重复开始时间
  private var repeatDate: Date? = nil
  
  /// 拖动开始位置
  private var dragStartLocation: CGPoint? = nil
  
  /// 最后一次拖拽的位置
  private var lastDragValue: CGPoint? = nil
  
  /// 是否应用 .release 操作
  /// 注意：在 calloutContext 呼出开始显示的时候是不会应用 release 的
  private var shouldApplyReleaseAction = true
  
  /// 在按钮 bounds 外，仍然可以触发 .release 的区域大小的百分比
  /// 默认为 `0.75`，即把按钮 bounds 的 size 在扩大 这个值
  /// 注意：这个值需要与滑动的阈值相配合
  private let releaseOutsideTolerance: Double = 0.75
  
  private let repeatTimer: RepeatGestureTimer = .shared
  private let longPressDelay: TimeInterval = GestureButtonDefaults.longPressDelay
  private let doubleTapTimeout: TimeInterval = GestureButtonDefaults.doubleTapTimeout
  private let repeatDelay: TimeInterval = GestureButtonDefaults.repeatDelay
  
  // MARK: - subview
  
  // 按钮背景图
  private lazy var backgroundView: ShapeView = {
    let view = ShapeView()
    return view
  }()
  
  private lazy var inputCalloutView: InputCalloutView = {
    let view = InputCalloutView(
      calloutContext: calloutContext.input,
      keyboardContext: keyboardContext,
      style: inputCalloutStyle)
    return view
  }()
  
  // MARK: - 计算属性
  
  /// 按钮样式
  /// 注意：action 与 是否按下的状态 isPressed 决定按钮样式
  private var buttonStyle: KeyboardButtonStyle {
    appearance.buttonStyle(for: item.action, isPressed: isPressed)
  }
  
  /// 布局配置
  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }
  
  /// input呼出样式
  private var inputCalloutStyle: KeyboardInputCalloutStyle {
    var style = appearance.inputCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = insets
    return style
  }
  
  /// 长按呼出样式
  private var actionCalloutStyle: KeyboardActionCalloutStyle {
    var style = appearance.actionCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = insets
    return style
  }
  
  // MARK: - Initializations
  
  init(
    row: Int,
    column: Int,
    item: KeyboardLayoutItem,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
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
    self.calloutContext = calloutContext
    self.appearance = appearance
    self.interfaceOrientation = keyboardContext.interfaceOrientation
    
    super.init(frame: .zero)
    
    self.buttonContentView = KeyboardButtonContentView(
      action: action,
      style: buttonStyle,
      appearance: appearance,
      keyboardContext: keyboardContext)
    
    setupSubview()
    
    $isPressed
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        let layoutConfig = layoutConfig
        updateButtonStyle(layoutConfig)
      }
      .store(in: &subscriptions)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Layout Functions
  
  func setupSubview() {
    /// spacer 类型不可见
    alpha = isSpacer ? 0 : 1
    
    let layoutConfig = layoutConfig
    setupContentView(layoutConfig)
    setupBackgroundView(layoutConfig)
    
    NSLayoutConstraint.activate(topConstraints + bottomConstraints + leadingConstraints + trailingConstraints)
  }

  /// 设置按钮内容视图
  func setupContentView(_ layoutConfig: KeyboardLayoutConfiguration) {
    // 不变的样式
    buttonContentView.layer.cornerRadius = cornerRadius
    
    addSubview(buttonContentView)
    buttonContentView.translatesAutoresizingMaskIntoConstraints = false
    let insets = layoutConfig.buttonInsets
    topConstraints.append(buttonContentView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top))
    bottomConstraints.append(buttonContentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom))
    leadingConstraints.append(buttonContentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left))
    trailingConstraints.append(buttonContentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right))
  }
  
  /// 设置按钮背景视图，如底部阴影及暗线
  func setupBackgroundView(_ layoutConfig: KeyboardLayoutConfiguration) {
    // 不变的样式
    backgroundView.shapeLayer.lineWidth = 1
    backgroundView.shapeLayer.fillColor = UIColor.clear.cgColor
    backgroundView.shapeLayer.shadowOpacity = Float(0.2)
    backgroundView.shapeLayer.masksToBounds = false
    
    insertSubview(backgroundView, belowSubview: buttonContentView)
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    let insets = layoutConfig.buttonInsets
    topConstraints.append(backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top))
    bottomConstraints.append(backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom))
    leadingConstraints.append(backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left))
    trailingConstraints.append(backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right))
  }
  
  /// 设置 inputCallout 样式
  func setupInputCallout() {
    guard let superview = superview else { return }
    inputCalloutView.translatesAutoresizingMaskIntoConstraints = false
    superview.addSubview(inputCalloutView)
//    insertSubview(inputCalloutView, aboveSubview: buttonContentView)
    NSLayoutConstraint.activate([
      inputCalloutView.widthAnchor.constraint(equalTo: buttonContentView.widthAnchor, multiplier: 2),
      inputCalloutView.heightAnchor.constraint(equalTo: buttonContentView.heightAnchor, multiplier: 2),
      inputCalloutView.centerXAnchor.constraint(equalTo: buttonContentView.centerXAnchor),
      inputCalloutView.bottomAnchor.constraint(equalTo: buttonContentView.bottomAnchor),
    ])
    setNeedsDisplay()
  }
  
  func updateConstraints(_ layoutConfig: KeyboardLayoutConfiguration) {
    guard interfaceOrientation != keyboardContext.interfaceOrientation else { return }

    interfaceOrientation = keyboardContext.interfaceOrientation

    let insets = layoutConfig.buttonInsets

    // Logger.statistics.debug("KeyboardButtonRowItem layoutSubviews() rowHeight: \(layoutConfig.rowHeight), buttonInsets [left: \(insets.left), top: \(insets.top), right: \(insets.right), bottom: \(insets.bottom)]")

    topConstraints.forEach { $0.constant = insets.top }
    bottomConstraints.forEach { $0.constant = -insets.bottom }
    leadingConstraints.forEach { $0.constant = insets.left }
    trailingConstraints.forEach { $0.constant = -insets.right }
  }
  
  func updateButtonStyle(_ layoutConfig: KeyboardLayoutConfiguration) {
    let style = buttonStyle
    
    buttonContentView.style = style
    
    // 按键底部深色样式
    backgroundView.shapeLayer.borderColor = style.border?.color.cgColor ?? UIColor.clear.cgColor
    backgroundView.shapeLayer.strokeColor = (style.shadow?.color ?? UIColor.clear).cgColor
    
    // 按键阴影样式
    backgroundView.layer.shadowPath = shadowPath.cgPath
    backgroundView.layer.shadowColor = (style.shadow?.color ?? UIColor.clear).cgColor
    
    // 按钮样式
    if isPressed {
      buttonContentView.backgroundColor = style.backgroundColor ?? .clear
      backgroundView.shapeLayer.opacity = 0
      // TODO: 按键气泡重新调整
      // showInputCallout()
    } else {
      buttonContentView.backgroundColor = style.backgroundColor ?? .clear
      backgroundView.shapeLayer.path = underPath.cgPath
      backgroundView.shapeLayer.opacity = 1
      // hideInputCallout()
    }
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    let layoutConfig = layoutConfig
    updateConstraints(layoutConfig)
    updateButtonStyle(layoutConfig)
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
    if !action.isInputAction {
      return
    }
    
    if action == .space {
      return
    }

    inputCalloutView.alpha = 1
    inputCalloutView.shapeLayer.zPosition = 1000
    inputCalloutView.label.text = action.inputCalloutText
    inputCalloutView.updateStyle()
    setupInputCallout()
  }
  
  func hideInputCallout() {
    inputCalloutView.alpha = 0
    inputCalloutView.removeFromSuperview()
  }
}

// MARK: - Event Handled

public extension KeyboardButton {
  // TODO: 如果开启滑动输入则统一在 TouchView 处理手势
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard bounds.contains(point) else { return nil }
    Logger.statistics.debug("\(self.row)-\(self.column) button hitTest")
    return self
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      Logger.statistics.debug("\(self.row)-\(self.column) button touchesBegan")
      tryHandlePress(touch)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      Logger.statistics.debug("\(self.row)-\(self.column) button touchesMoved")
      tryHandleDrag(touch)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      Logger.statistics.debug("\(self.row)-\(self.column) button touchesEnded")
      tryHandleRelease(touch)
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      Logger.statistics.debug("\(self.row)-\(self.column) button touchesMoved")
      tryHandleRelease(touch)
    }
  }
  
  func tryHandlePress(_ touch: UITouch) {
    guard !isPressed else { return }
    isPressed = true
    pressAction()
    if touch.tapCount > 1 {
      doubleTapAction()
    }
    dragStartLocation = touch.location(in: self)
    tryTriggerLongPressAfterDelay()
    tryTriggerRepeatAfterDelay()
  }
  
  func tryHandleRelease(_ touch: UITouch) {
    guard isPressed else { return }
    isPressed = false
    dragStartLocation = nil
    longPressDate = nil
    repeatDate = nil
    repeatTimer.stop()
    
    // 判断手势区域是否超出当前 bounds
    let currentPoint = touch.location(in: self)
    if bounds.contains(currentPoint) {
      handleReleaseInside()
    } else {
      handleReleaseOutside(currentPoint)
    }
    
    endAction()
  }
  
  func tryTriggerLongPressAfterDelay() {
    let date = Date.now
    longPressDate = date
    DispatchQueue.main.asyncAfter(deadline: .now() + longPressDelay) {
      guard self.longPressDate == date else { return }
      self.longPressAction()
    }
  }
  
  func tryTriggerRepeatAfterDelay() {
    let date = Date.now
    repeatDate = date
    DispatchQueue.main.asyncAfter(deadline: .now() + repeatDelay) {
      guard self.repeatDate == date else { return }
      self.repeatTimer.start(action: self.repeatAction)
    }
  }
  
  func tryHandleDrag(_ touch: UITouch) {
    guard let startLocation = dragStartLocation else { return }
    let currentPoint = touch.location(in: self)
    lastDragValue = currentPoint
    // TODO: 更新呼出选择位置
    dragAction(start: startLocation, current: currentPoint)
  }
  
  func handleReleaseInside() {
    updateShouldApplyReleaseAction()
    guard shouldApplyReleaseAction else { return }
    Logger.statistics.debug("inside release")
    releaseAction()
  }
  
  func handleReleaseOutside(_ currentPoint: CGPoint) {
    guard shouldApplyReleaseOutsize(for: currentPoint) else { return }
    handleReleaseInside()
  }
  
  // TODO: 手势结束处理
  func endAction() {
    calloutContext.action.endDragGesture()
    calloutContext.input.resetWithDelay()
    calloutContext.action.reset()
    resetGestureState()
  }
  
  func shouldApplyReleaseOutsize(for currentPoint: CGPoint) -> Bool {
    guard let _ = lastDragValue else { return false }
    let rect = CGRect.releaseOutsideToleranceArea(for: bounds.size, tolerance: releaseOutsideTolerance)
    let isInsideRect = rect.contains(currentPoint)
    return isInsideRect
  }
  
  func updateShouldApplyReleaseAction() {
    let context = calloutContext.action
    shouldApplyReleaseAction = shouldApplyReleaseAction && !context.hasSelectedAction
  }
  
  func resetGestureState() {
    lastDragValue = nil
    shouldApplyReleaseAction = true
  }
  
  func pressAction() {
    Logger.statistics.debug("pressAction()")
    actionHandler.handle(.press, on: action)
  }
  
  func doubleTapAction() {
    Logger.statistics.debug("doubleTapAction()")
    actionHandler.handle(.doubleTap, on: action)
  }
  
  func longPressAction() {
    guard shouldApplyReleaseAction, action != .space else { return }
    Logger.statistics.debug("longPressAction()")
    actionHandler.handle(.longPress, on: action)
  }
  
  func releaseAction() {
    Logger.statistics.debug("releaseAction()")
    actionHandler.handle(.release, on: action)
  }
  
  func repeatAction() {
    Logger.statistics.debug("repeatAction()")
    actionHandler.handle(.repeatPress, on: action)
  }
  
  func dragAction(start: CGPoint, current: CGPoint) {
    actionHandler.handleDrag(on: action, from: start, to: current)
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
    let rect = CGRect(
      x: 0,
      y: backgroundView.bounds.height,
      width: backgroundView.bounds.width,
      height: shadowSize)
    let path = UIBezierPath(
      roundedRect: rect,
      cornerRadius: shadowSize)
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
    let maxX = backgroundView.frame.width - delta
    let maxY = backgroundView.frame.height + delta
    
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

private extension CGRect {
  /// 此函数返回一个带填充的矩形，在该矩形中应应用外部释放。
  static func releaseOutsideToleranceArea(
    for size: CGSize,
    tolerance: Double) -> CGRect
  {
    let rect = CGRect(origin: .zero, size: size)
      .insetBy(dx: -size.width * tolerance, dy: -size.height * tolerance)
    return rect
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
        item: .init(action: action, size: .init(width: .input, height: 54), insets: .zero),
        actionHandler: .preview,
        keyboardContext: .preview,
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
