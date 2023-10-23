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
      setupAppearance()
      if action == .space {
        spaceContentView.style = style
      } else if let image = appearance.buttonImage(for: action) {
        imageContentView.imageView.image = image
        imageContentView.style = style
      } else {
        textContentView.style = style
      }
    }
  }

  private let keyboardContext: KeyboardContext
  private let rimeContext: RimeContext

  private lazy var spaceContentView: SpaceContentView = {
    let view = SpaceContentView(keyboardContext: keyboardContext, rimeContext: rimeContext, item: item, style: style, spaceText: buttonText)
    return view
  }()

  private lazy var imageContentView: ImageContentView = {
    let view = ImageContentView(style: style, scaleFactor: appearance.buttonImageScaleFactor(for: action))
    return view
  }()

  private lazy var textContentView: TextContentView = {
    let view = TextContentView(keyboardContext: keyboardContext, item: item, style: style, text: buttonText, isInputAction: action.isInputAction)
    return view
  }()

  private lazy var contentView: UIView = {
    let view = UIStackView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.alignment = .center
    view.distribution = .fill
    view.spacing = 0

    if action == .space {
      view.addArrangedSubview(spaceContentView)
    } else if let image = appearance.buttonImage(for: action) {
      view.addArrangedSubview(imageContentView)
    } else {
      view.addArrangedSubview(textContentView)
    }
    return view
  }()

  /// 上划 Label
  private lazy var upSwipeLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .center
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.numberOfLines = 1
    return label
  }()

  private lazy var upSwipeContainer: UIView = {
    let view = UIStackView(arrangedSubviews: [upSwipeLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.alignment = .center
    view.distribution = .fill
    view.spacing = 0
    return view
  }()

  /// 下划 Label
  private lazy var downSwipeLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .center
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.numberOfLines = 1
    return label
  }()

  private lazy var downSwipeContainer: UIView = {
    let view = UIStackView(arrangedSubviews: [downSwipeLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.alignment = .center
    view.distribution = .fill
    view.spacing = 0
    return view
  }()

  private lazy var swipeLeftAndRightContainer: UIStackView = {
    let view = UIStackView(arrangedSubviews: keyboardContext.upSwipeOnLeft ? [upSwipeLabel, downSwipeLabel] : [downSwipeLabel, upSwipeLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.alignment = .center
    view.distribution = .fillProportionally
    view.spacing = 0
    return view
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

    setupContentView()
    setupAppearance()
  }

  // MARK: - Layout

  func setupContentView() {
    constructViewHierarchy()
    activateViewConstraints()
  }

  override public func setupAppearance() {
    upSwipeLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    upSwipeLabel.textColor = style.swipeForegroundColor

    downSwipeLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    downSwipeLabel.textColor = style.swipeForegroundColor
  }

  override public func constructViewHierarchy() {
    addSubview(contentView)
    guard action.isInputAction && action != .space else { return }

    if keyboardContext.swipeLabelUpAndDownLayout {
      addSubview(upSwipeContainer)
      addSubview(downSwipeContainer)
      upSwipeLabel.text = " "
      downSwipeLabel.text = " "
      for swipe in item.swipes {
        if swipe.display, swipe.direction == .up {
          upSwipeLabel.text = swipe.labelText
        }

        if swipe.display, swipe.direction == .down {
          downSwipeLabel.text = swipe.labelText
        }
      }
    } else {
      for swipe in item.swipes {
        if swipe.display, swipe.direction == .up {
          upSwipeLabel.text = swipe.labelText
        }

        if swipe.display, swipe.direction == .down {
          downSwipeLabel.text = swipe.labelText
        }
      }
      addSubview(swipeLeftAndRightContainer)
    }
  }

  override public func activateViewConstraints() {
    var contentConstraints = [
      contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
      contentView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: keyboardContext.keyboardType.isChineseNineGrid ? 0.8 : 0.6),
    ]

    if !action.isInputAction || action == .space {
      contentConstraints.append(contentView.centerYAnchor.constraint(equalTo: centerYAnchor))
      contentConstraints.append(contentView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9))
      NSLayoutConstraint.activate(contentConstraints)
      return
    }

    // 划动上下布局
    if keyboardContext.swipeLabelUpAndDownLayout {
      contentConstraints.append(contentView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7))
      contentConstraints.append(contentView.centerYAnchor.constraint(equalTo: centerYAnchor))
      NSLayoutConstraint.activate([
        upSwipeContainer.topAnchor.constraint(equalTo: topAnchor),
        upSwipeContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
        upSwipeContainer.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
        upSwipeContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),

        downSwipeContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        downSwipeContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
        downSwipeContainer.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
        downSwipeContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
      ] + contentConstraints)
      return
    }

    // 划动左右布局
    contentConstraints.append(contentView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8))
    contentConstraints.append(contentView.centerYAnchor.constraint(equalTo: centerYAnchor))
    NSLayoutConstraint.activate([
      swipeLeftAndRightContainer.topAnchor.constraint(equalTo: topAnchor),
      swipeLeftAndRightContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
      swipeLeftAndRightContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
      swipeLeftAndRightContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
      swipeLeftAndRightContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
    ] + contentConstraints)
  }
}
