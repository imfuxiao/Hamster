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
  private var style: KeyboardButtonStyle

  /// 文本内容
  private var text: String

  /// 是否为输入类型操作
  private let isInputAction: Bool

  private var oldBounds: CGRect = .zero

  /// 按键 Label
  public lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .center
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.numberOfLines = 1
    return label
  }()

  /// 是否使用偏移
  /// 即在Y轴向上偏移
  var useOffset: Bool {
    isInputAction && text.count == 1 && text.isLowercased
  }

  init(keyboardContext: KeyboardContext, item: KeyboardLayoutItem, style: KeyboardButtonStyle, text: String, isInputAction: Bool) {
    self.keyboardContext = keyboardContext
    self.item = item
    self.style = style
    self.text = text
    self.isInputAction = isInputAction

    super.init(frame: .zero)

    setupTextView()
    setupAppearance()
  }

  func setupTextView() {
    addSubview(label)
    label.text = text
  }

  override public func setupAppearance() {
    label.font = style.font
    label.textColor = style.foregroundColor
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    guard oldBounds != self.bounds else { return }
    self.oldBounds = self.bounds

    if oldBounds.width == .zero || oldBounds.height == .zero {
      self.label.frame = .zero
      return
    }

    self.label.frame = self.oldBounds.inset(by: UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1))
//    if useOffset {
//      self.label.frame = self.label.frame.offsetBy(dx: 0, dy: -1)
//      self.frame = self.frame.offsetBy(dx: 0, dy: -1)
//    }
  }

  func setStyle(_ style: KeyboardButtonStyle) {
    self.style = style
    setupAppearance()
  }

  func setTextValue(_ text: String) {
    label.text = text
  }
}
