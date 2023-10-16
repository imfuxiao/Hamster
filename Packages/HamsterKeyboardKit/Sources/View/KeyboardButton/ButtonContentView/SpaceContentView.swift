//
//  SpaceContentView.swift
//
//
//  Created by morse on 2023/8/10.
//

import Combine
import HamsterUIKit
import UIKit

class SpaceContentView: NibLessView {
  private let keyboardContext: KeyboardContext
  private let rimeContext: RimeContext
  private let item: KeyboardLayoutItem
  private var spaceText: String
  private var subscriptions = Set<AnyCancellable>()

  public var style: KeyboardButtonStyle {
    didSet {
      loadingLabel.textColor = style.foregroundColor
      textView.style = style
    }
  }

  private lazy var loadingLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .center
    if keyboardContext.keyboardType.isCustom {
      label.text = item.key?.label.loadingText ?? ""
    } else {
      label.text = keyboardContext.loadingTextForSpaceButton
    }
    return label
  }()

  private lazy var textView: TextContentView = {
    var spaceText = ""
    if keyboardContext.keyboardType.isCustom {
      spaceText = item.key?.label.text ?? ""
      if keyboardContext.showCurrentInputSchemaNameForSpaceButton {
        spaceText = rimeContext.currentSchema?.schemaName ?? ""
      }
    } else {
      spaceText = keyboardContext.labelTextForSpaceButton
      if keyboardContext.showCurrentInputSchemaNameForSpaceButton {
        spaceText = rimeContext.currentSchema?.schemaName ?? ""
      }
    }

    // 数字键盘不显示
    if keyboardContext.keyboardType.isNumber {
      spaceText = self.spaceText
    }

    let textView = TextContentView(
      keyboardContext: keyboardContext,
      item: item,
      style: style,
      text: spaceText,
      isInputAction: true
    )
    return textView
  }()

  var isShowLoadingText: Bool {
    if keyboardContext.keyboardType.isNumber || !keyboardContext.enableLoadingTextForSpaceButton {
      return false
    }
    return true
  }

  init(keyboardContext: KeyboardContext, rimeContext: RimeContext, item: KeyboardLayoutItem, style: KeyboardButtonStyle, spaceText: String) {
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext
    self.item = item
    self.style = style
    self.spaceText = spaceText

    super.init(frame: .zero)

    setupView()

    combine()
  }

  func setupView() {
    /// 数字键盘不显示加载文字
    if !isShowLoadingText {
      addSubview(textView)
      textView.fillSuperview()
      return
    }

    loadingLabel.font = style.font?.font
    loadingLabel.alpha = 1
    addSubview(loadingLabel)
    loadingLabel.fillSuperview()

    textView.alpha = 0
    addSubview(textView)
    textView.fillSuperview()
  }

  func combine() {
    if keyboardContext.showCurrentInputSchemaNameForSpaceButton {
      Task {
        await rimeContext.$currentSchema
          .receive(on: DispatchQueue.main)
          .sink { [weak self] in
            guard let self = self else { return }
            guard let schema = $0 else { return }
            guard !keyboardContext.keyboardType.isNumber else { return }
            textView.setTextValue(schema.schemaName)
          }
          .store(in: &subscriptions)
      }
    }
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    guard isShowLoadingText else { return }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      guard let self = self else { return }
      UIView.animate(withDuration: 0.35) {
        self.loadingLabel.alpha = 0
        self.textView.alpha = 1
      }
    }
  }
}
