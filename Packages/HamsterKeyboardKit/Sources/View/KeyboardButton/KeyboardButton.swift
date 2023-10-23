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
  typealias ButtonBounds = CGSize

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

  /// 设备方向
  var interfaceOrientation: InterfaceOrientation

  /// iPad 浮动模式
  var isKeyboardFloating: Bool

  /// 用来缓存是否需要重新计算 UnderShape
  var oldUnderShapeFrame: CGRect

  var oldBounds: CGRect = .zero

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
    return contentView
  }()

  // 按钮底部立体阴影
  lazy var underShadowShape: CAShapeLayer = {
    let layer = CAShapeLayer()
    return layer
  }()

  // 输入按键气泡
  lazy var inputCalloutView: InputCalloutView = {
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
  var buttonStyle: KeyboardButtonStyle {
    appearance.buttonStyle(for: item.action, isPressed: isHighlighted)
  }

  /// 布局配置
  var layoutConfig: KeyboardLayoutConfiguration {
    return .standard(for: keyboardContext)
  }

  /// 按钮内容内距
  var buttonContentInsets: UIEdgeInsets {
    keyboardContext.isKeyboardFloating ? layoutConfig.buttonInsets : item.insets
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
    self.userInterfaceStyle = keyboardContext.colorScheme
    self.isKeyboardFloating = keyboardContext.isKeyboardFloating
    self.oldUnderShapeFrame = .zero

    super.init(frame: .zero)

    setupButtonContentView()

    combine()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    repeatTimer.stop()
  }

  func combine() {
    // 系统外观发生变化，键盘颜色随亦随之变化
    keyboardContext.$traitCollection
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard userInterfaceStyle != $0.userInterfaceStyle else { return }
        userInterfaceStyle = $0.userInterfaceStyle
        updateButtonStyle(isPressed: isHighlighted)
      }
      .store(in: &subscriptions)
  }

  // MARK: - Layout Functions

  /// 设置按钮内容视图
  func setupButtonContentView() {
    buttonContentView.layer.addSublayer(underShadowShape)
    addSubview(buttonContentView)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    let insets = buttonContentInsets

    if self.bounds != .zero, oldBounds != self.bounds {
      oldBounds = self.bounds

      CATransaction.begin()
      CATransaction.setDisableActions(true)

      /// spacer 类型不可见
      alpha = isSpacer ? 0 : 1

      let bounds = oldBounds.inset(by: insets)
      buttonContentView.frame = bounds
      let style = buttonStyle
      if let cornerRadius = style.cornerRadius {
        underShadowShape.path = calculatorUnderPath(bounds: CGSize(width: bounds.width, height: bounds.height + 1), cornerRadius: cornerRadius).cgPath
        underShadowShape.fillColor = style.shadow?.color.cgColor
        buttonContentView.layer.cornerRadius = cornerRadius
      }

      CATransaction.commit()
    }

    // 按键气泡
    // 注意: InputCallout 视图是定义在父视图中，因为 button 之间会有遮盖
    if keyboardContext.displayButtonBubbles {
      if let superview = superview, inputCalloutView.superview == nil {
        inputCalloutView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(inputCalloutView)
        NSLayoutConstraint.activate([
          inputCalloutView.centerXAnchor.constraint(equalTo: centerXAnchor),
          inputCalloutView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
          inputCalloutView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2, constant: -insets.left * 2 - insets.right * 2),
          inputCalloutView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 2, constant: -insets.top * 2 - insets.bottom * 2),
        ])
      }
    }
    updateButtonStyle(isPressed: isHighlighted)
  }

  /// 根据按下状态更新当前按钮样式
  func updateButtonStyle(isPressed: Bool) {
    // Logger.statistics.debug("updateButtonStyle(), isPressed: \(isPressed), isHighlighted: \(self.isHighlighted)")
    let style = appearance.buttonStyle(for: item.action, isPressed: isPressed)

    // 更新按钮内容的样式
    buttonContentView.style = style

    // 按钮样式
    buttonContentView.backgroundColor = style.backgroundColor
    if let color = style.border?.color {
      buttonContentView.layer.borderColor = color.cgColor
      buttonContentView.layer.borderWidth = style.border?.size ?? 1
    }

    if isPressed {
      underShadowShape.opacity = 0
      // TODO: 按键气泡重新调整
      showInputCallout()
    } else {
      underShadowShape.opacity = 1
      hideInputCallout()
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
  /// 按钮底部深色样式路径
  func calculatorUnderPath(bounds: CGSize, cornerRadius: CGFloat) -> UIBezierPath {
    // 缓存 PATH
    if let path = underPathCache[bounds] {
      return path
    }
    let underPath = CAShapeLayer.underPath(size: bounds, cornerRadius: cornerRadius)
    underPathCache[bounds] = underPath
    return underPath
  }
}

extension CGSize: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(width)
    hasher.combine(height)
  }
}
