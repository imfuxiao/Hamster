//
//  KeyboardView.swift
//
//
//  Created by morse on 2023/8/10.
//

import Combine
import UIKit

public class Keyboard: UIView {
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
  public typealias KeyboardItemWidth = CGFloat

  // MARK: - Properties

  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let autocompleteToolbarMode: AutocompleteToolbarMode
  private let autocompleteToolbarAction: AutocompleteToolbarAction
  /// 键盘宽度
  private let keyboardWidth: CGFloat
  /// 按键宽度
  private let inputWidth: CGFloat
  private let renderBackground: Bool
  private let layout: KeyboardLayout
  private let layoutConfig: KeyboardLayoutConfiguration

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
     - renderBackground: Whether or not to render the background, by default `true`.
     - buttonView: The keyboard button view builder.
   */
  public init(
    layout: KeyboardLayout,
    appearance: KeyboardAppearance,
    actionHandler: KeyboardActionHandler,
    autocompleteContext: AutocompleteContext,
    autocompleteToolbar: AutocompleteToolbarMode,
    autocompleteToolbarAction: @escaping AutocompleteToolbarAction,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext?,
    width: CGFloat,
    renderBackground: Bool = true
  ) {
    self.layout = layout
    self.layoutConfig = .standard(for: keyboardContext)
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.autocompleteToolbarMode = autocompleteToolbar
    self.autocompleteToolbarAction = autocompleteToolbarAction
    self.keyboardWidth = width
    self.inputWidth = layout.inputWidth(for: width)
    self.renderBackground = renderBackground
    self.autocompleteContext = autocompleteContext
    self.keyboardContext = keyboardContext
    self.calloutContext = calloutContext ?? .disabled
    self.actionCalloutContext = calloutContext?.action ?? .disabled
    self.inputCalloutContext = calloutContext?.input ?? .disabled

    super.init(frame: .zero)

    setupKeyboardView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  func setupKeyboardView() {
    // TODO: 设置背景View
    // renderBackground ? appearance.backgroundStyle.backgroundView : nil

    // 生成键盘按键
    var constraints = [NSLayoutConstraint]()
    var lastRowView: UIView?

    let layoutConfig = KeyboardLayoutConfiguration.standard(for: keyboardContext)
    for (rowIndex, row) in layout.itemRows.enumerated() {
      let rowView = UIView()
      rowView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(rowView)
      constraints.append(rowView.heightAnchor.constraint(equalToConstant: CGFloat(layoutConfig.rowHeight)))
      constraints.append(rowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: appearance.keyboardEdgeInsets.left))
      constraints.append(rowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: appearance.keyboardEdgeInsets.right))
      if rowIndex == 0 {
        constraints.append(rowView.topAnchor.constraint(equalTo: topAnchor, constant: appearance.keyboardEdgeInsets.top))
        lastRowView = rowView
      } else if rowIndex == layout.itemRows.endIndex {
        if let lastRowView = lastRowView {
          constraints.append(rowView.topAnchor.constraint(equalTo: lastRowView.bottomAnchor))
        }
        constraints.append(rowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: appearance.keyboardEdgeInsets.bottom))
      } else {
        if let lastRowView = lastRowView {
          constraints.append(rowView.topAnchor.constraint(equalTo: lastRowView.bottomAnchor))
        }
        lastRowView = rowView
      }

      var lastButtonItem: KeyboardButtonRowItem?

      for (itemIndex, item) in row.enumerated() {
        let buttonItem = KeyboardButtonRowItem(
          item: item,
          keyboardContext: keyboardContext,
          actionHandler: actionHandler,
          calloutContext: calloutContext,
          keyboardWidth: keyboardWidth,
          inputWidth: inputWidth,
          appearance: appearance
        )

        buttonItem.translatesAutoresizingMaskIntoConstraints = false
        rowView.addSubview(buttonItem)

        constraints.append(buttonItem.topAnchor.constraint(equalTo: rowView.topAnchor, constant: item.insets.top))
        constraints.append(buttonItem.bottomAnchor.constraint(equalTo: rowView.bottomAnchor, constant: -item.insets.bottom))

        if let width = rowItemWidthValue(for: item, totalWidth: keyboardWidth, referenceWidth: inputWidth) {
          constraints.append(buttonItem.widthAnchor.constraint(equalToConstant: width))
        }

        if itemIndex == 0 {
          constraints.append(buttonItem.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: item.insets.left))
          lastButtonItem = buttonItem
        } else if itemIndex == row.endIndex {
          if let lastButtonItem = lastButtonItem {
            constraints.append(buttonItem.leadingAnchor.constraint(equalTo: lastButtonItem.trailingAnchor, constant: item.insets.left))
          }
          constraints.append(buttonItem.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -item.insets.right))
        } else {
          if let lastButtonItem = lastButtonItem {
            constraints.append(buttonItem.leadingAnchor.constraint(equalTo: lastButtonItem.trailingAnchor, constant: item.insets.left))
          }
          lastButtonItem = buttonItem
        }
      }
    }

    NSLayoutConstraint.activate(constraints)
  }
}

private extension UIView {
  func rowItemWidthValue(for item: KeyboardLayoutItem, totalWidth: Double, referenceWidth: Double) -> Double? {
    let insets = item.insets.left + item.insets.right
    switch item.size.width {
    case .available: return nil
    case .input: return referenceWidth - insets
    case .inputPercentage(let percent): return percent * referenceWidth - insets
    case .percentage(let percent): return percent * totalWidth - insets
    case .points(let points): return points - insets
    }
  }
}
