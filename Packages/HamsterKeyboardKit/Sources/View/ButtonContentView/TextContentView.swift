//
//  TextContentView.swift
//
//
//  Created by morse on 2023/8/10.
//

import UIKit
import HamsterKit

/**
 该视图渲染系统键盘按钮的文本。

 注意：文本行数限制为 1 行，如果按钮操作是 input 类型且文本为小写，则会有垂直方向的偏移。
 */
public class TextContentView: UIView {
  /// 按钮样式
  public var style: KeyboardButtonStyle
  /// 文本内容
  private let text: String
  /// 是否为输入类型操作
  private let isInputAction: Bool

  private lazy var  label: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    // label.adjustsFontSizeToFitWidth = true
    label.textAlignment = .center
    label.minimumScaleFactor = 0.5
    label.numberOfLines = 1
    label.text = text
    return label
  }()
  
  private lazy var containerView: UIView = {
    let containerView = UIView(frame: .zero)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: offsetRight ? 5 : 0),
      label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: useOffset ? -2 : 0),
//      label.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor),
//      label.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor),
    ])
    
    return containerView
  }()

  /// 是否使用偏移
  /// 即在Y轴向上偏移
  var useOffset: Bool {
    isInputAction && text.isLowercased
  }
  
  /// 是否向右偏移
  var offsetRight: Bool {
    text.isMatchChineseParagraph && !text.isPairSymbolsBegin
  }

  init(style: KeyboardButtonStyle, text: String, isInputAction: Bool) {
    self.style = style
    self.text = text
    self.isInputAction = isInputAction

    super.init(frame: .zero)

    setupTextView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupTextView() {
    addSubview(containerView)
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: topAnchor),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])


  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    label.font = style.font?.font
    label.textColor = style.foregroundColor
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct TextContentView_Previews: PreviewProvider {
  static func textContent(text: String, action: KeyboardAction) -> some View {
    return UIViewPreview {
      let view = TextContentView(
        style: .preview1,
        text: text,
        isInputAction: action.isInputAction)
      view.frame = .init(x: 0, y: 0, width: 80, height: 80)
      return view
    }
  }

  static var previews: some View {
    HStack {
      textContent(text: "A", action: .character("A"))
      textContent(text: "a", action: .character("a"))
      textContent(text: "lower", action: .character("lower"))
      textContent(text: "lower", action: .backspace)
      textContent(text: "lowerlowerlowerlower", action: .backspace)
    }
  }
}

#endif
