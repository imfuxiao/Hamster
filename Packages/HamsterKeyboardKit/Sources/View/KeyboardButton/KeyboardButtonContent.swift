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
  private var style: KeyboardButtonStyle
  private let keyboardContext: KeyboardContext
  private let rimeContext: RimeContext
  private var oldBounds: CGRect = .zero

  private lazy var spaceContentView: SpaceContentView = {
    let view = SpaceContentView(keyboardContext: keyboardContext, rimeContext: rimeContext, item: item, style: style, spaceText: buttonText)
    return view
  }()

  private lazy var imageContentView: ImageContentView = {
    let view = ImageContentView(style: style, image: appearance.buttonImage(for: action), scaleFactor: appearance.buttonImageScaleFactor(for: action))
    return view
  }()

  private lazy var textContentView: TextContentView = {
    let view = TextContentView(keyboardContext: keyboardContext, item: item, style: style, text: buttonText, isInputAction: action.isInputAction)
    if action.isSymbol {
      view.label.adjustsFontSizeToFitWidth = true
      view.label.minimumScaleFactor = 0.5
    }
    return view
  }()

  private lazy var contentView: UIView = {
    let view: UIView
    if action == .space {
      view = spaceContentView
    } else if let image = appearance.buttonImage(for: action), item.key?.label.text.isEmpty ?? true { // 自定义键盘可以为 backspace/shift 设置文本显示
      view = imageContentView
    } else {
      view = textContentView
    }
    return view
  }()

  /// 上划 Label
  private lazy var upSwipeLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 1
    label.textAlignment = .center
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.9
    return label
  }()

  /// 下划 Label
  private lazy var downSwipeLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 1
    label.textAlignment = .center
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.9
    return label
  }()

//  private lazy var swipeLeftAndRightContainer: UIStackView = {
//    let view = UIStackView(arrangedSubviews: keyboardContext.upSwipeOnLeft ? [upSwipeLabel, downSwipeLabel] : [downSwipeLabel, upSwipeLabel])
//    view.axis = .horizontal
//    view.alignment = .center
//    view.distribution = .fillProportionally
//    view.spacing = 0
//    return view
//  }()

  /// 按钮显示文本
  var buttonText: String {
    if keyboardContext.keyboardType.isCustom, let buttonText = item.key?.label.text, !buttonText.isEmpty {
      return buttonText
    }
    return appearance.buttonText(for: action) ?? ""
  }

  /// 是否需要显示划动文本控件
  var needSwipeLabel: Bool {
    guard !action.isSystemAction else { return false }
    guard action != .space else { return false }
    return action.isInputAction
  }

  init(item: KeyboardLayoutItem, style: KeyboardButtonStyle, appearance: KeyboardAppearance, keyboardContext: KeyboardContext, rimeContext: RimeContext) {
    self.item = item
    self.action = item.action
    self.style = style
    self.appearance = appearance
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext

    super.init(frame: .zero)

    setupContentView()
    setupAppearance()
  }

  // MARK: - Layout

  func setupContentView() {
    constructViewHierarchy()
    upSwipeLabel.font = style.swipeFont?.font
    downSwipeLabel.font = style.swipeFont?.font
  }

  override public func constructViewHierarchy() {
    addSubview(contentView)

    guard needSwipeLabel else { return }

    for swipe in item.swipes {
      if swipe.display, swipe.direction == .up {
        upSwipeLabel.text = swipe.labelText
        addSubview(upSwipeLabel)
      }

      if swipe.display, swipe.direction == .down {
        downSwipeLabel.text = swipe.labelText
        addSubview(downSwipeLabel)
      }
    }
  }

  override public func setupAppearance() {
    upSwipeLabel.textColor = style.swipeForegroundColor
    downSwipeLabel.textColor = style.swipeForegroundColor
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    guard self.bounds != .zero, oldBounds != self.bounds else { return }
    self.oldBounds = self.bounds

    if keyboardContext.disableSwipeLabel || !needSwipeLabel {
      contentView.frame = self.oldBounds
      return
    }

//    guard downSwipeLabel.superview != nil || upSwipeLabel.superview != nil else {
//      contentView.frame = self.oldBounds
//      return
//    }

    // 划动上下布局
    if keyboardContext.swipeLabelUpAndDownLayout {
      // TODO: 不规则上下布局
      if keyboardContext.swipeLabelUpAndDownIrregularLayout {
        upSwipeLabel.frame = CGRect(x: self.oldBounds.width / 3 * 2 - 2, y: 0, width: self.oldBounds.width / 3, height: self.oldBounds.height * 0.75 / 2)
        upSwipeLabel.textAlignment = .left
        upSwipeLabel.adjustsFontSizeToFitWidth = true
        upSwipeLabel.minimumScaleFactor = 0.6

        contentView.frame = CGRect(x: 0, y: 0, width: self.oldBounds.width / 3 * 2, height: self.oldBounds.height * 0.75)

        downSwipeLabel.frame = CGRect(x: 0, y: self.oldBounds.height * 0.75 - 2, width: self.oldBounds.width, height: self.oldBounds.height * 0.3)
        upSwipeLabel.adjustsFontSizeToFitWidth = true
        upSwipeLabel.minimumScaleFactor = 0.5
      } else {
        // 标准上下布局
        let swipeHeight = self.oldBounds.height * 0.18

        upSwipeLabel.frame = CGRect(x: 0, y: 0, width: self.oldBounds.width, height: swipeHeight)
        upSwipeLabel.adjustsFontSizeToFitWidth = true
        upSwipeLabel.minimumScaleFactor = 0.5

        contentView.frame = CGRect(x: 0, y: swipeHeight - 1, width: self.oldBounds.width, height: self.oldBounds.height * 0.66)
        textContentView.label.adjustsFontSizeToFitWidth = true
        textContentView.label.minimumScaleFactor = 0.85

        downSwipeLabel.frame = upSwipeLabel.frame.offsetBy(dx: 0, dy: upSwipeLabel.frame.height + contentView.frame.height - 1)
        downSwipeLabel.adjustsFontSizeToFitWidth = true
        downSwipeLabel.minimumScaleFactor = 0.5
      }
    } else { // 划动上布局
      let swipeHeight = self.oldBounds.height * 0.3
      let halfWidth = self.oldBounds.width / 2
      let swipeLabelFrame = CGRect(x: 0, y: 0, width: halfWidth, height: swipeHeight)
      let leftFrame = swipeLabelFrame.offsetBy(dx: 0, dy: -1)
      let rightFrame = swipeLabelFrame.offsetBy(dx: halfWidth, dy: -1)
      let middleFrame = CGRect(origin: CGPoint(x: 0, y: -1), size: CGSize(width: self.oldBounds.width, height: swipeHeight))
      let upSwipeLabelIsEmpty = upSwipeLabel.text?.isEmpty ?? true
      let downSwipeLabelIsEmpty = downSwipeLabel.text?.isEmpty ?? true
      let upSwipeOnLeft = keyboardContext.upSwipeOnLeft

      if !upSwipeLabelIsEmpty, !downSwipeLabelIsEmpty {
        if upSwipeOnLeft {
          upSwipeLabel.frame = leftFrame
          downSwipeLabel.frame = rightFrame
        } else {
          upSwipeLabel.frame = rightFrame
          downSwipeLabel.frame = leftFrame
        }
      } else if !upSwipeLabelIsEmpty, downSwipeLabelIsEmpty {
        upSwipeLabel.frame = middleFrame
      } else if upSwipeLabelIsEmpty, !downSwipeLabelIsEmpty {
        downSwipeLabel.frame = middleFrame
      }
      contentView.frame = CGRect(x: 0, y: swipeHeight / 2 + 1, width: self.oldBounds.width, height: self.oldBounds.height - swipeHeight)
    }
  }

  func setStyle(_ style: KeyboardButtonStyle) {
    guard self.style != style else { return }
    self.style = style

    setupAppearance()
    if action == .space {
      spaceContentView.setStyle(style)
    } else if let image = appearance.buttonImage(for: action) {
      spaceContentView.setStyle(style)
      imageContentView.setImage(image)
      imageContentView.setStyle(style)
    } else {
      textContentView.setStyle(style)
    }
  }
}
