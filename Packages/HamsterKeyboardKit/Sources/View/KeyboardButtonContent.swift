//
//  KeyboardButtonContent.swift
//
//
//  Created by morse on 2023/8/10.
//

import HamsterKit
import UIKit

/// 标准按键内容视图
/// 可以继承此类实现不同的按键样式
public class KeyboardButtonContentView: UIView {
  private let action: KeyboardAction
  private let appearance: KeyboardAppearance
  public var style: KeyboardButtonStyle {
    didSet {
      setNeedsLayout()
    }
  }

  private let keyboardContext: KeyboardContext
  private let rimeContext: RimeContext
  private var contentView: UIView!

  var buttonText: String {
    appearance.buttonText(for: action) ?? " "
  }

  init(action: KeyboardAction, style: KeyboardButtonStyle, appearance: KeyboardAppearance, keyboardContext: KeyboardContext, rimeContext: RimeContext) {
    self.action = action
    self.style = style
    self.appearance = appearance
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext

    super.init(frame: .zero)

    if action == .space {
      // TODO: 补充空格自定义加载文本
      contentView = SpaceContentView(style: style, loadingText: .space, spaceText: buttonText)
    } else if let image = appearance.buttonImage(for: action) {
      contentView = ImageContentView(style: style, image: image, scaleFactor: appearance.buttonImageScaleFactor(for: action))
    } else {
      contentView = TextContentView(style: style, text: buttonText, isInputAction: action.isInputAction)
    }

    setupContentView()
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  func setupContentView() {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(contentView)
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    if let contentView = contentView as? SpaceContentView {
      contentView.style = style
    } else if let contentView = contentView as? ImageContentView {
      contentView.style = style
      if let image = appearance.buttonImage(for: action) {
        print("keyboard \(keyboardContext.keyboardType)")
        print("action \(action)")
        contentView.imageView.image = image
      }
    } else if let contentView = contentView as? TextContentView {
      contentView.style = style
    }
  }
}
