//
//  KeyboardButtonContent.swift
//
//
//  Created by morse on 2023/8/10.
//

import HamsterKit
import HamsterUIKit
import UIKit

/// 标准按键内容视图
/// 可以继承此类实现不同的按键样式
public class KeyboardButtonContentView: NibLessView {
  private let item: KeyboardLayoutItem
  private let action: KeyboardAction
  private let appearance: KeyboardAppearance
  public var style: KeyboardButtonStyle {
    didSet {
      if let view = contentView as? SpaceContentView {
        view.style = style
      } else if let view = contentView as? ImageContentView {
        view.style = style
      } else if let view = contentView as? TextContentView {
        view.style = style
      }
      setNeedsLayout()
    }
  }

  private let keyboardContext: KeyboardContext
  private let rimeContext: RimeContext

  private lazy var contentView: UIView = {
    // TODO: 补充空格自定义加载文本
    if action == .space {
      return SpaceContentView(keyboardContext: keyboardContext, item: item, style: style, loadingText: .space, spaceText: buttonText)
    } else if let image = appearance.buttonImage(for: action) {
      return ImageContentView(style: style, image: image, scaleFactor: appearance.buttonImageScaleFactor(for: action))
    }
    return TextContentView(keyboardContext: keyboardContext, item: item, style: style, text: buttonText, isInputAction: action.isInputAction)
  }()

  var buttonText: String {
    if keyboardContext.keyboardType.isCustom, let buttonText = item.key?.label.text, !buttonText.isEmpty {
      return buttonText
    }
    return appearance.buttonText(for: action) ?? ""
  }

  init(item: KeyboardLayoutItem, style: KeyboardButtonStyle, appearance: KeyboardAppearance, keyboardContext: KeyboardContext, rimeContext: RimeContext) {
    self.item = item
    self.action = item.action
    self.style = style
    self.appearance = appearance
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext

    super.init(frame: .zero)
  }

  // MARK: - Layout

  override public func layoutSubviews() {
    super.layoutSubviews()

    setupContentView()
  }

//  override public func didMoveToWindow() {
//    super.didMoveToWindow()
//
//    setupContentView()
//  }

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
}
