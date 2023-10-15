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
    }
  }

  private let keyboardContext: KeyboardContext
  private let rimeContext: RimeContext

  private lazy var contentView: UIView = {
    if action == .space {
      return SpaceContentView(keyboardContext: keyboardContext, rimeContext: rimeContext, item: item, style: style, spaceText: buttonText)
    } else if let image = appearance.buttonImage(for: action) {
      return ImageContentView(style: style, image: image, scaleFactor: appearance.buttonImageScaleFactor(for: action))
    }
    return TextContentView(keyboardContext: keyboardContext, item: item, style: style, text: buttonText, isInputAction: action.isInputAction)
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
    let view = UIStackView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.alignment = .center
    view.distribution = .fillEqually
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
  }

  // MARK: - Layout

  func setupContentView() {
    constructViewHierarchy()
    activateViewConstraints()

    // fot test
//    let view = UIView()
//    view.backgroundColor = .red
//    view.translatesAutoresizingMaskIntoConstraints = false
//    addSubview(view)
//    view.fillSuperview()

    upSwipeLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    upSwipeLabel.textColor = keyboardContext.secondaryLabelColor

    downSwipeLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    downSwipeLabel.textColor = keyboardContext.secondaryLabelColor
  }

  override public func constructViewHierarchy() {
    addSubview(contentView)
    guard action.isInputAction && action != .space else { return }

    if keyboardContext.swipeLabelUpAndDownLayout {
      addSubview(upSwipeContainer)
      addSubview(downSwipeContainer)
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
          swipeLeftAndRightContainer.addArrangedSubview(upSwipeLabel)
        }

        if swipe.display, swipe.direction == .down {
          downSwipeLabel.text = swipe.labelText
          swipeLeftAndRightContainer.addArrangedSubview(downSwipeLabel)
        }
      }
      addSubview(swipeLeftAndRightContainer)
    }
  }

  override public func activateViewConstraints() {
    contentView.translatesAutoresizingMaskIntoConstraints = false

    if !action.isInputAction || action == .space {
      NSLayoutConstraint.activate([
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
        contentView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9),
        contentView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
      ])
      return
    }

    // 检测是否开启上下布局
    if keyboardContext.swipeLabelUpAndDownLayout {
      NSLayoutConstraint.activate([
        // x 轴位置一致
        upSwipeContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
        downSwipeContainer.centerXAnchor.constraint(equalTo: centerXAnchor),

        upSwipeContainer.topAnchor.constraint(equalTo: topAnchor, constant: 1),
        contentView.topAnchor.constraint(equalTo: upSwipeLabel.bottomAnchor),
        downSwipeContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),

        contentView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9),
        upSwipeContainer.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9),
        downSwipeContainer.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9),

        upSwipeContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.225),
        downSwipeContainer.heightAnchor.constraint(equalTo: upSwipeLabel.heightAnchor),
        contentView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.55),
      ])
      return
    }

    NSLayoutConstraint.activate([
      swipeLeftAndRightContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
      contentView.centerXAnchor.constraint(equalTo: centerXAnchor),

      swipeLeftAndRightContainer.topAnchor.constraint(equalTo: topAnchor),
      contentView.topAnchor.constraint(equalTo: swipeLeftAndRightContainer.bottomAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

      swipeLeftAndRightContainer.widthAnchor.constraint(equalTo: widthAnchor),
      contentView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9),

      swipeLeftAndRightContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
      contentView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
    ])
  }
}
