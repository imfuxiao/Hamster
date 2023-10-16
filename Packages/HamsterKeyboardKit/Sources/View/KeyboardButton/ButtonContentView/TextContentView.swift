//
//  TextContentView.swift
//
//
//  Created by morse on 2023/8/10.
//

import HamsterKit
import HamsterUIKit
import UIKit

/**
 该视图渲染系统键盘按钮的文本。

 注意：文本行数限制为 1 行，如果按钮操作是 input 类型且文本为小写，则会有垂直方向的偏移。
 */
public class TextContentView: NibLessView {
  private let keyboardContext: KeyboardContext
  private let item: KeyboardLayoutItem
  public var style: KeyboardButtonStyle {
    didSet {
      label.font = style.font?.font
      label.textColor = style.foregroundColor
    }
  }

  /// 文本内容
  private var text: String

  /// 是否为输入类型操作
  private let isInputAction: Bool

  /// 按键 Label
  private lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .center
    label.lineBreakMode = .byTruncatingTail
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.2
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  /// 是否使用偏移
  /// 即在Y轴向上偏移
  var useOffset: Bool {
    isInputAction && text.isLowercased
  }

  init(keyboardContext: KeyboardContext, item: KeyboardLayoutItem, style: KeyboardButtonStyle, text: String, isInputAction: Bool) {
    self.keyboardContext = keyboardContext
    self.item = item
    self.style = style
    self.text = text
    self.isInputAction = isInputAction

    super.init(frame: .zero)

    setupTextView()
  }

  func setupTextView() {
    constructViewHierarchy()
    activateViewConstraints()

    label.text = text
    label.font = style.font?.font
    label.textColor = style.foregroundColor
  }

  override public func constructViewHierarchy() {
    addSubview(label)
  }

  override public func activateViewConstraints() {
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: useOffset ? -2 : 0),
      label.widthAnchor.constraint(equalTo: widthAnchor),
      label.heightAnchor.constraint(equalTo: heightAnchor),
    ])
  }

  func setTextValue(_ text: String) {
    label.text = text
  }
}
