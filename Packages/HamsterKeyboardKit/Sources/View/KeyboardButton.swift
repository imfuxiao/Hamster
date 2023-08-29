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
  
  private let rimeContext: RimeContext
  
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
  
  /// 手势开始时间戳
  private var touchBeginTimestamp: TimeInterval? = nil
  
  /// 轻扫手势处理
  private var swipeGestureHandle: (() -> Void)?
  
  /// 拖动开始位置
  private var dragStartLocation: CGPoint? = nil
  
  /// 最后一次拖拽的位置
  private var lastDragLocation: CGPoint? = nil
  
  /// 是否触发 .release 操作
  /// 注意：
  /// 1. 长按空格状态下不应该触发 release
  /// 2. 在 calloutContext 呼出开始显示的时候，不应触发 release
  private var shouldApplyReleaseAction = true
  
  /// 在按钮 bounds 外，仍然可以触发 .release 操作的区域大小的百分比
  /// 默认为 `0.75`，即把按钮 bounds 的 size 在扩大这个值
  /// 注意：这个值需要与滑动的阈值相配合
  private let releaseOutsideTolerance: Double = 0.75
  
  private let repeatTimer: RepeatGestureTimer = .shared
  private let longPressDelay: TimeInterval = GestureButtonDefaults.longPressDelay
  private let repeatDelay: TimeInterval = GestureButtonDefaults.repeatDelay
  
  // MARK: - subview
  
  // 按钮背景
  private lazy var backgroundView: ShapeView = {
    let view = ShapeView()
    return view
  }()
  
  private lazy var inputCalloutView: InputCalloutView = {
    let view = InputCalloutView(
      calloutContext: calloutContext.input,
      keyboardContext: keyboardContext,
      style: inputCalloutStyle)
    view.isHidden = true
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
    
    super.init(frame: .zero)
    
    self.buttonContentView = KeyboardButtonContentView(
      action: action,
      style: buttonStyle,
      appearance: appearance,
      keyboardContext: keyboardContext,
      rimeContext: rimeContext)
    
    setupSubview()
    
    $isPressed
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] isPressed in
        let layoutConfig = layoutConfig
        updateButtonStyle(layoutConfig, isPressed: isPressed)
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
    inputCalloutView.translatesAutoresizingMaskIntoConstraints = false
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
  
  func updateButtonStyle(_ layoutConfig: KeyboardLayoutConfiguration, isPressed: Bool) {
    Logger.statistics.debug("updateButtonStyle(), isPressed: \(isPressed), isHighlighted: \(self.isHighlighted), isSelected: \(self.isSelected)")
    let style = appearance.buttonStyle(for: item.action, isPressed: isPressed)
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
      showInputCallout()
    } else {
      buttonContentView.backgroundColor = style.backgroundColor ?? .clear
      backgroundView.shapeLayer.path = underPath.cgPath
      backgroundView.shapeLayer.opacity = 1
      hideInputCallout()
    }
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    Logger.statistics.debug("\(self.row)-\(self.column) layoutSubviews()")
    
    let layoutConfig = layoutConfig
    updateConstraints(layoutConfig)
    updateButtonStyle(layoutConfig, isPressed: isPressed)
    
    let displayButtonBubbles = keyboardContext.hamsterConfig?.Keyboard?.displayButtonBubbles ?? false
    if displayButtonBubbles {
      setupInputCallout()
    }
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
    guard action.isInputAction, action != .space else { return }
    inputCalloutView.isHidden = false
    inputCalloutView.shapeLayer.zPosition = 9999
    inputCalloutView.label.text = action.inputCalloutText?.uppercased()
    inputCalloutView.updateStyle()
  }
  
  func hideInputCallout() {
    inputCalloutView.isHidden = true
  }
}

// MARK: - Event Handled

public extension KeyboardButton {
  // TODO: 如果开启滑动输入则统一在 TouchView 处理手势
  // 注意： inputMargin 不可见的按钮也需要触发，所以必须重载 hitTest 方法
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard bounds.contains(point) else { return nil }
    Logger.statistics.debug("\(self.row)-\(self.column) button hitTest, bounds: \(self.bounds.debugDescription), point: \(point.debugDescription)")
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
      Logger.statistics.debug("\(self.row)-\(self.column) button touchesCancelled")
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
    touchBeginTimestamp = touch.timestamp
    dragStartLocation = touch.location(in: self)
    tryTriggerLongPressAfterDelay()
    tryTriggerRepeatAfterDelay()
  }
  
  func tryHandleRelease(_ touch: UITouch) {
    guard isPressed else { return }
    isPressed = false
    touchBeginTimestamp = nil
    dragStartLocation = nil
    longPressDate = nil
    repeatDate = nil
    repeatTimer.stop()
    
    // 取消状态不触发 .release
    if touch.phase != .cancelled {
      // 轻扫手势不触发 release
      if let swipeGestureHandle = swipeGestureHandle {
        swipeGestureHandle()
        self.swipeGestureHandle = nil
      } else {
        // 判断手势区域是否超出当前 bounds
        let currentPoint = touch.location(in: self)
        if bounds.contains(currentPoint) {
          handleReleaseInside()
        } else {
          handleReleaseOutside(currentPoint)
        }
      }
    }
    
    endAction()
  }
  
  func tryTriggerLongPressAfterDelay() {
    let date = Date.now
    longPressDate = date
    DispatchQueue.main.asyncAfter(deadline: .now() + longPressDelay) { [weak self] in
      guard let self = self else { return }
      guard self.longPressDate == date else { return }
      self.longPressAction()
    }
  }
  
  func tryTriggerRepeatAfterDelay() {
    let date = Date.now
    repeatDate = date
    DispatchQueue.main.asyncAfter(deadline: .now() + repeatDelay) { [weak self] in
      guard let self = self else { return }
      guard self.repeatDate == date else { return }
      self.repeatTimer.start(action: self.repeatAction)
    }
  }
  
  func tryHandleDrag(_ touch: UITouch) {
    // dragStartLocation 在 touchesBegan 阶段设置值，在 touchesEnd/touchesCancel 阶段取消值
    guard let startLocation = dragStartLocation else { return }
    let currentPoint = touch.location(in: self)
    lastDragLocation = currentPoint
    
    // 识别 swipe
    if let touchBeginTimestamp = touchBeginTimestamp, touch.timestamp - touchBeginTimestamp < longPressDelay {
      let tanThreshold = 0.58 // tan(30º)) = 0.58
      let distanceThreshold: CGFloat = 10 // 滑动的阈值

      let distanceY = currentPoint.y - startLocation.y
      let distanceX = currentPoint.x - startLocation.x
      
      // 两点距离
      let distance = sqrt(pow(distanceY, 2) + pow(distanceX, 2))
      
      // 轻扫的距离必须符合阈值要求
      guard distance >= distanceThreshold else { return }
      Logger.statistics.debug("current point: \(currentPoint.debugDescription)")
      Logger.statistics.debug("start point: \(startLocation.debugDescription)")

      // 水平方向夹角 tan 值
      let tanHorizontalCorner = distanceX == .zero ? .zero : abs(distanceY) / abs(distanceX)
      // 垂直方向夹角 tan 值
      let tanVerticalCorner = distanceY == .zero ? .zero : abs(distanceX) / abs(distanceY)
      
      Logger.statistics.debug("tanHorizontalCorner: \(tanHorizontalCorner)")
      Logger.statistics.debug("tanVerticalCorner: \(tanVerticalCorner)")
      
      // distanceX > 0 && distanceY < 0 表示 右上角
      // distanceX > 0 && distanceY > 0 表示 右下角
      // distanceX < 0 && distanceY < 0 表示 左上角
      // distanceX > 0 && distanceY > 0 表示 左下角
      var direction: SwipeDirection?
      if tanHorizontalCorner <= tanThreshold, tanVerticalCorner != 0 { // 水平夹角
        // 右上角或右下角
        if (distanceX > 0 && distanceY < 0) || (distanceX > 0 && distanceY > 0) {
          direction = .right
        } else if (distanceX < 0 && distanceY < 0) || (distanceX > 0 && distanceY > 0) { // 左上角或左下角
          direction = .left
        }
      } else if tanVerticalCorner <= tanThreshold, tanHorizontalCorner != 0 { // 垂直夹角
        // 右上角或左上角
        if (distanceX > 0 && distanceY < 0) || (distanceX < 0 && distanceY < 0) {
          direction = .up
        } else if (distanceX > 0 && distanceY > 0) || (distanceX > 0 && distanceY > 0) { // 右下角或左下角
          direction = .down
        }
      } else if tanHorizontalCorner == 0, tanVerticalCorner == 0 {
        if distanceX == 0, distanceY > 0 {
          direction = .down
        } else if distanceX == 0, distanceY < 0 {
          direction = .up
        } else if distanceX > 0, distanceY == 0 {
          direction = .right
        } else if distanceX < 0, distanceY == 0 {
          direction = .left
        }
      }
      
      if let direction = direction {
        swipeGestureHandle = { [unowned self] in
          swipeAction(direction: direction)
        }
      }
    } else {
      swipeGestureHandle = nil
    }
    
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
    guard let _ = lastDragLocation else { return false }
    let rect = CGRect.releaseOutsideToleranceArea(for: bounds.size, tolerance: releaseOutsideTolerance)
    let isInsideRect = rect.contains(currentPoint)
    return isInsideRect
  }
  
  func updateShouldApplyReleaseAction() {
    let context = calloutContext.action
    shouldApplyReleaseAction = shouldApplyReleaseAction && !context.hasSelectedAction
  }
  
  func resetGestureState() {
    lastDragLocation = nil
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
    // 空格长按不需要应用 release
    shouldApplyReleaseAction = shouldApplyReleaseAction && action != .space
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
    Logger.statistics.debug("dragAction()")
    actionHandler.handleDrag(on: action, from: start, to: current)
  }
  
  func swipeAction(direction: SwipeDirection) {
    Logger.statistics.debug("swipeAction(), direction: \(direction.debugDescription)")
    switch direction {
    case .up:
      actionHandler.handle(.swipeUp, on: action)
    case .down:
      actionHandler.handle(.swipeDown, on: action)
    case .left:
      actionHandler.handle(.swipeLeft, on: action)
    case .right:
      actionHandler.handle(.swipeRight, on: action)
    }
  }
  
  enum SwipeDirection: CustomDebugStringConvertible {
    case up
    case down
    case left
    case right
    
    public var debugDescription: String {
      switch self {
      case .up:
        return "up"
      case .down:
        return "down"
      case .left:
        return "left"
      case .right:
        return "right"
      }
    }
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
