//
//  KeyboardButtonContent.swift
//
//
//  Created by morse on 2023/8/10.
//

import UIKit

/// 标准按键内容视图
/// 可以继承此类实现不同的按键样式
open class KeyboardButtonContentView: UIView {
  private let action: KeyboardAction
  private let appearance: KeyboardAppearance
  public var style: KeyboardButtonStyle {
    didSet {}
  }

  private let keyboardContext: KeyboardContext
  private var contentView: UIView!

  var spaceText: String {
    appearance.buttonText(for: action) ?? ""
  }

  init(action: KeyboardAction, style: KeyboardButtonStyle, appearance: KeyboardAppearance, keyboardContext: KeyboardContext) {
    self.action = action
    self.style = style
    self.appearance = appearance
    self.keyboardContext = keyboardContext

    super.init(frame: .zero)

    if action == .space {
      // TODO: 补充空格自定义加载文本
      contentView = SpaceContentView(style: style, loadingText: "空格（测试）", spaceText: spaceText)
    } else if let image = appearance.buttonImage(for: action) {
      contentView = ImageContentView(image: image, scaleFactor: appearance.buttonImageScaleFactor(for: action))
    } else {
      let text = appearance.buttonText(for: action) ?? ""
      contentView = TextContentView(style: style, text: text, isInputAction: action.isInputAction)
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
}
