//
//  KeyboardButton.swift
//
//
//  Created by morse on 2023/8/6.
//

import UIKit

/// 键盘键盘
public class KeyboardButton: UIControl {
  // MARK: - Properties
  
  /**
   此类型别名代表一种操作，可用于自定义（或替换）标准按钮内容视图。
   */
  public typealias ContentConfig = (KeyboardButtonContentView) -> UIView
  
  /// 按键对应的操作
  private let action: KeyboardAction
  
  /// 按键对应操作的处理类
  private let actionHandler: KeyboardActionHandler
  
  /// 键盘上下文
  private let keyboardContext: KeyboardContext
  
  /// 键盘外观
  private let appearance: KeyboardAppearance
  
  /// 按键内容视图
  private var buttonContentView: KeyboardButtonContentView!
  
  private var contentConfig: ContentConfig
  
  private var buttonStyle: KeyboardButtonStyle {
    appearance.buttonStyle(for: action, isPressed: isSelected)
  }
  
  // MARK: - Initializations
  
  init(
    action: KeyboardAction,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    appearance: KeyboardAppearance,
    contentConfig: @escaping ContentConfig
  ) {
    self.action = action
    self.actionHandler = actionHandler
    self.keyboardContext = keyboardContext
    self.appearance = appearance
    self.contentConfig = contentConfig
    
    super.init(frame: .zero)
    
    self.buttonContentView = KeyboardButtonContentView(
      action: action,
      style: buttonStyle,
      appearance: appearance,
      keyboardContext: keyboardContext
    )
    
    setupButtonContentView()
  }
  
  convenience init(
    action: KeyboardAction,
    actionHandler: KeyboardActionHandler,
    keyboardContext: KeyboardContext,
    appearance: KeyboardAppearance
  ) {
    self.init(
      action: action,
      actionHandler: actionHandler,
      keyboardContext: keyboardContext,
      appearance: appearance,
      contentConfig: { $0 }
    )
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Layout Functions
  
  override public var isSelected: Bool {
    didSet {
      buttonContentView.style = buttonStyle
    }
  }

  func setupButtonContentView() {
    let view = contentConfig(buttonContentView)
    addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: topAnchor),
      view.bottomAnchor.constraint(equalTo: bottomAnchor),
      view.leadingAnchor.constraint(equalTo: leadingAnchor),
      view.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
    
    updateButtonStyle()
  }
  
  func updateButtonStyle() {
    let style = buttonStyle
    let isPressed = isSelected
    
    layer.cornerRadius = style.cornerRadius ?? .zero
    layer.borderColor = style.border?.color.cgColor ?? UIColor.clear.cgColor
    backgroundColor = style.backgroundColor ?? .clear
    if isPressed {
      backgroundColor = style.pressedOverlayColor ?? .clear
    }
    layer.shadowColor = style.shadow?.color.cgColor ?? UIColor.clear.cgColor
    layer.shadowOffset = CGSizeMake(0, style.shadow?.size ?? .zero)
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
        appearance: .preview
      ) {
        $0.frame = .init(x: 0, y: 0, width: 80, height: 80)
        return $0
      }
      
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
