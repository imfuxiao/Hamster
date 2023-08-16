//
//  TextContentView.swift
//
//
//  Created by morse on 2023/8/10.
//

import UIKit

/**
 该视图渲染系统键盘按钮的文本。

 注意：文本行数限制为 1 行，如果按钮操作是 input 类型且文本为小写，则会有垂直方向的偏移。
 */
public class TextContentView: UIView {
  /// 按钮样式
  private let style: KeyboardButtonStyle
  /// 文本内容
  private let text: String
  /// 是否为输入类型操作
  private let isInputAction: Bool

  private let label: UILabel

  /// 是否使用偏移
  /// 即在Y轴向上偏移
  var useOffset: Bool {
    isInputAction && text.isLowercased
  }

  init(style: KeyboardButtonStyle, text: String, isInputAction: Bool) {
    self.style = style
    self.text = text
    self.isInputAction = isInputAction
    self.label = UILabel(frame: .zero)

    super.init(frame: .zero)

    setupTextView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupTextView() {
    label.textAlignment = .center
//    label.baselineAdjustment = UIBaselineAdjustment.alignCenters
//    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.numberOfLines = 1
    label.font = style.font?.font
    label.textColor = style.foregroundColor
    label.text = text
//    addSubview(label)

    label.translatesAutoresizingMaskIntoConstraints = false

    let stackView = UIStackView(arrangedSubviews: [label])
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fillEqually

    addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

//    NSLayoutConstraint.activate([
//      label.centerXAnchor.constraint(equalTo: centerXAnchor),
//      centerYAnchor.constraint(
//        equalTo: label.centerYAnchor,
//        constant: useOffset ? 2 : 0),
//      label.leadingAnchor.constraint(equalTo: leadingAnchor),
//      label.trailingAnchor.constraint(equalTo: trailingAnchor),
//    ])
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
