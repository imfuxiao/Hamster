//
//  StanderAlphabeticKeyboard.swift
//
//
//  Created by morse on 2023/8/10.
//

import Combine
import UIKit

/**
 标准字母键盘
 */
public class StanderAlphabeticKeyboard: UIView {
  public enum AutocompleteToolbarMode {
    /// Show the autocomplete toolbar if the keyboard context prefers it.
    ///
    /// 如果键盘上下文偏好自动完成工具栏，则显示该工具栏。
    case automatic

    /// Never show the autocomplete toolbar.
    ///
    /// 绝不显示自动完成工具栏。
    case none
  }

  public typealias AutocompleteToolbarAction = (AutocompleteSuggestion) -> Void
  public typealias KeyboardWidth = CGFloat

  // MARK: - Properties

  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let autocompleteToolbarMode: AutocompleteToolbarMode
  private let autocompleteToolbarAction: AutocompleteToolbarAction
  private let layout: KeyboardLayout

  private var actionCalloutStyle: KeyboardActionCalloutStyle {
    var style = appearance.actionCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = CGSize(width: insets.left, height: insets.top)
    return style
  }

  private var inputCalloutStyle: KeyboardInputCalloutStyle {
    var style = appearance.inputCalloutStyle
    let insets = layoutConfig.buttonInsets
    style.callout.buttonInset = CGSize(width: insets.left, height: insets.top)
    return style
  }

  private var actionCalloutContext: ActionCalloutContext
  private var autocompleteContext: AutocompleteContext
  private var calloutContext: KeyboardCalloutContext
  private var inputCalloutContext: InputCalloutContext
  private var keyboardContext: KeyboardContext

  /// 键盘宽度
  private var keyboardWidth: CGFloat

  /// input 类型按键的最小宽度
  /// 注意：每次 view 发生变化时需要重新计算此宽度
  private var inputWidth: CGFloat

  /// 缓存所有按键视图
  private var keyboardRows: [[KeyboardButtonRowItem]] = []
  /// 缓存所有视图约束
  private var buttonConstraints: [NSLayoutConstraint] = []

  // MARK: - 计算属性

  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  // MARK: - Initializations

  /**
   Create a system keyboard with custom button views.

   The provided `buttonView` builder will be used to build
   the full button view for every layout item.

   - Parameters:
     - layout: The keyboard layout to use.
     - appearance: The keyboard appearance to use.
     - actionHandler: The action handler to use.
     - autocompleteContext: The autocomplete context to use.
     - autocompleteToolbar: The autocomplete toolbar mode to use.
     - autocompleteToolbarAction: The action to trigger when tapping an autocomplete suggestion.
     - keyboardContext: The keyboard context to use.
     - calloutContext: The callout context to use.
     - width: The keyboard width.
   */
  public init(
    layout: KeyboardLayout,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    autocompleteContext: AutocompleteContext,
    autocompleteToolbar: AutocompleteToolbarMode,
    autocompleteToolbarAction: @escaping AutocompleteToolbarAction,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?
  ) {
    self.layout = layout
//    self.layoutConfig = .standard(for: keyboardContext)
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.autocompleteToolbarMode = autocompleteToolbar
    self.autocompleteToolbarAction = autocompleteToolbarAction
    self.autocompleteContext = autocompleteContext
    self.keyboardContext = keyboardContext
    self.calloutContext = calloutContext ?? .disabled
    self.actionCalloutContext = calloutContext?.action ?? .disabled
    self.inputCalloutContext = calloutContext?.input ?? .disabled
    self.keyboardWidth = keyboardContext.keyboardWidth
    self.inputWidth = layout.inputWidth(for: keyboardWidth)

    super.init(frame: .zero)

    setupKeyboardView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  /// 构建视图层次
  open func constructViewHierarchy() {
    // 添加按键至 View
    for (rowIndex, row) in layout.itemRows.enumerated() {
      var tempRow = [KeyboardButtonRowItem]()
      for (itemIndex, item) in row.enumerated() {
        let buttonItem = KeyboardButtonRowItem(
          row: rowIndex,
          column: itemIndex,
          item: item,
          keyboardContext: keyboardContext,
          actionHandler: actionHandler,
          calloutContext: calloutContext,
          keyboardWidth: keyboardWidth,
          inputWidth: inputWidth,
          appearance: appearance
        )
        buttonItem.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonItem)
        tempRow.append(buttonItem)
      }
      keyboardRows.append(tempRow)
    }
  }

  /// 激活视图约束
  open func activateViewConstraints() {
    // 行中 input 类型按键总宽度
    var inputItemsTotalWidth = CGFloat.zero
    // 行中 available 类型按键集合
    var availableItems = [KeyboardButtonRowItem]()
    // 前一个按键，用于按键之间间隙约束
    var prevItem: KeyboardButtonRowItem?
    // 总行的高度，用于键盘视图的高度约束
    // 注意，这个值也用于按键 y 轴偏移量
    var keyboardHeight = CGFloat.zero

    let layoutConfig = layoutConfig

    for row in keyboardRows {
      for button in row {
        /// 按键高度约束(insets在案件内部处理)
        buttonConstraints.append(button.heightAnchor.constraint(equalToConstant: layoutConfig.rowHeight))

        if !button.isSpacer, let width = rowItemWidthValue(for: button.item, totalWidth: keyboardWidth, referenceWidth: inputWidth) {
          /// 按键宽度约束(insets在按键内部处理)
          let gConstraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: width)
          let lConstraint = button.widthAnchor.constraint(lessThanOrEqualToConstant: width)
          lConstraint.priority = .defaultLow
          buttonConstraints.append(gConstraint)
          buttonConstraints.append(lConstraint)
          inputItemsTotalWidth += width
        } else {
          // 注意：available 类型按键宽度在 input 类型宽度布局结束后，根据剩余宽度在平均分配
          availableItems.append(button)
        }

        if button.column == 0 {
          // 行中第一个按键添加相对行的 leading 约束
          buttonConstraints.append(button.leadingAnchor.constraint(equalTo: leadingAnchor))

          // 修改上一个按键的引用，用于其他按键添加 leading 约束
          prevItem = button
        } else if button.column + 1 == row.endIndex { // 行中最后一个按键
          if let prevItem = prevItem {
            // 根据上一个按键的 trailing，添加按键 leading 约束
            buttonConstraints.append(button.leadingAnchor.constraint(equalTo: prevItem.trailingAnchor))
          }
          // 行中最后一个按键添加相对行的 trailing 约束
          buttonConstraints.append(button.trailingAnchor.constraint(equalTo: trailingAnchor))
          prevItem = nil // 换行前修改上一个按键的引用值
        } else { // 行中其他按键添加 leading 约束
          if let prevItem = prevItem {
            buttonConstraints.append(button.leadingAnchor.constraint(equalTo: prevItem.trailingAnchor))
          }
          prevItem = button // 修改上一个按键引用值
        }

        // 添加按键 y 轴约束
        // 注意：约束商量使用了键盘总高度的值，这个值在每次遍例行中第一个按键时会累加一次行高，刚好可以作为相对 y 轴的偏移量
        buttonConstraints.append(button.topAnchor.constraint(equalTo: topAnchor, constant: keyboardHeight))
      }

      // 为宽度类型为 .available 的按键添加宽度约束
      // 计算逻辑：根据行中剩余的宽度，取平均值
      if !availableItems.isEmpty {
        let itemWidth = CGFloat.rounded((keyboardWidth - inputItemsTotalWidth) / CGFloat(availableItems.count)).rounded(.down)
        availableItems.forEach {
          buttonConstraints.append($0.widthAnchor.constraint(greaterThanOrEqualToConstant: itemWidth))
        }
        availableItems.removeAll()
      }

      inputItemsTotalWidth = .zero // 每一行遍历结束后，重置该值
      keyboardHeight += layoutConfig.rowHeight // 每一行遍历结束后，累加总行高度
    }
    // 添加视图的高度约束
    buttonConstraints.append(heightAnchor.constraint(greaterThanOrEqualToConstant: keyboardHeight))
    NSLayoutConstraint.activate(buttonConstraints)
  }

  func setupKeyboardView() {
    backgroundColor = .clear

    constructViewHierarchy()
    activateViewConstraints()
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    guard keyboardWidth != keyboardContext.keyboardWidth else { return }

    keyboardWidth = keyboardContext.keyboardWidth
    inputWidth = layout.inputWidth(for: keyboardWidth)

    NSLayoutConstraint.deactivate(buttonConstraints)
    buttonConstraints.removeAll()
    activateViewConstraints()
  }
}

private extension UIView {
  func rowItemWidthValue(for item: KeyboardLayoutItem, totalWidth: Double, referenceWidth: Double) -> Double? {
    switch item.size.width {
    case .available: return nil
    case .input: return referenceWidth
    case .inputPercentage(let percent): return percent * referenceWidth
    case .percentage(let percent): return percent * totalWidth
    case .points(let points): return points
    }
  }
}
