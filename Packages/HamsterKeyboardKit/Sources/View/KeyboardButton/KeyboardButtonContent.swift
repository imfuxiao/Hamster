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
    label.minimumScaleFactor = 0.5
    return label
  }()

  /// 下划 Label
  private lazy var downSwipeLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 1
    label.textAlignment = .center
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    return label
  }()

  /// 按钮显示文本
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

    setupContentView()
    setupAppearance()
  }

  // MARK: - Layout

  func setupContentView() {
    constructViewHierarchy()
    upSwipeLabel.font = style.swipeFont
    downSwipeLabel.font = style.swipeFont
  }

  override public func constructViewHierarchy() {
    addSubview(contentView)

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

    guard oldBounds != self.bounds else { return }
    self.oldBounds = self.bounds

    if oldBounds.width == .zero || oldBounds.height == .zero {
      upSwipeLabel.frame = .zero
      downSwipeLabel.frame = .zero
      contentView.frame = .zero
      return
    }

    if keyboardContext.disableSwipeLabel {
      contentView.frame = self.oldBounds
      return
    }

    let showUpSwipeLabel = upSwipeLabel.superview != nil
    let showDownSwipeLabel = downSwipeLabel.superview != nil

    // 划动上下布局
    if keyboardContext.swipeLabelUpAndDownLayout {
      // TODO: 不规则上下布局
      if keyboardContext.swipeLabelUpAndDownIrregularLayout {
        if showUpSwipeLabel {
          upSwipeLabel.frame = CGRect(x: self.oldBounds.width / 3 * 2, y: 2, width: self.oldBounds.width / 3, height: self.oldBounds.height * 0.75 / 2)
          upSwipeLabel.textAlignment = .center
        }

        let contentWidth = self.oldBounds.width / 3 * 2 + 3
        contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: self.oldBounds.height * 0.75)
        textContentView.label.adjustsFontSizeToFitWidth = true
        textContentView.label.minimumScaleFactor = 0.88
        if !showUpSwipeLabel {
          textContentView.label.minimumScaleFactor = 0.5
        }

        if showDownSwipeLabel {
          downSwipeLabel.frame = CGRect(x: 0, y: self.oldBounds.height * 0.75 - 2, width: self.oldBounds.width, height: self.oldBounds.height * 0.3)
        }
      } else {
        // 标准上下布局
        let swipeHeight = self.oldBounds.height * 0.18

        if showUpSwipeLabel {
          upSwipeLabel.frame = CGRect(x: 0, y: 0, width: self.oldBounds.width, height: swipeHeight)
        }

        let contentHeight = self.oldBounds.height * 0.66
        contentView.frame = CGRect(x: 0, y: swipeHeight - 1, width: self.oldBounds.width, height: contentHeight)
        textContentView.label.adjustsFontSizeToFitWidth = true
        textContentView.label.minimumScaleFactor = 0.85

        if showDownSwipeLabel {
          downSwipeLabel.frame = CGRect(x: 0, y: swipeHeight + contentHeight - 1, width: self.oldBounds.width, height: swipeHeight)
        }
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

      contentView.frame = CGRect(x: 0, y: swipeHeight / 2 - 1.5, width: self.oldBounds.width, height: self.oldBounds.height - swipeHeight + 3)
      textContentView.label.adjustsFontSizeToFitWidth = true
      textContentView.label.minimumScaleFactor = 0.85
    }
  }

  func setStyle(_ style: KeyboardButtonStyle) {
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
