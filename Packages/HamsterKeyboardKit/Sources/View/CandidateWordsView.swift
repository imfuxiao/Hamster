//
//  CandidateWordsView.swift
//
//
//  Created by morse on 2023/8/19.
//

import Combine
import HamsterKit
import UIKit

/**
 候选文字视图
 */
class CandidateWordsView: UIView {
  /// 候选区状态
  enum State {
    /// 展开
    case expand
    /// 收起
    case collapse
  }

  private var actionHandler: KeyboardActionHandler
  private var keyboardContext: KeyboardContext
  private var rimeContext: RimeContext

  private var subscription = Set<AnyCancellable>()

  private var state: State = .collapse {
    didSet {
      stateImageView.image = stateImage
    }
  }

  /// 拼音区域
  lazy var phoneticArea: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true
    if let fontSize = keyboardContext.hamsterConfig?.toolbar?.codingAreaFontSize {
      label.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
    }

    // 开启键盘配色
    if keyboardContext.hamsterConfig?.Keyboard?.enableColorSchema ?? false, let keyboardColor = keyboardContext.hamsterKeyboardColor {
      label.textColor = keyboardColor.textColor
    }

    return label
  }()

  /// 候选文字区域
  lazy var candidatesArea: CandidateWordsCollectionView = {
    let view = CandidateWordsCollectionView(
      keyboardContext: keyboardContext,
      actionHandler: actionHandler,
      rimeContext: rimeContext,
      direction: .horizontal)
    return view
  }()

  /// 候选区展开或收起控制按钮
  lazy var controlStateView: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = .clearInteractable

    view.addSubview(stateImageView)
    NSLayoutConstraint.activate([
      stateImageView.topAnchor.constraint(equalTo: view.topAnchor),
      stateImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      stateImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stateImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    // 添加阴影
    let codingAreaHeight = CGFloat(keyboardContext.hamsterConfig?.toolbar?.heightOfCodingArea ?? 15)
    let heightOfToolbar = CGFloat(keyboardContext.hamsterConfig?.toolbar?.heightOfToolbar ?? 55)
    let offsetY = (heightOfToolbar - codingAreaHeight - 30) / 2

    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.3
    view.layer.shadowOffset = .init(width: 0.5, height: offsetY)
    view.layer.shadowRadius = 0.5
    view.layer.shadowPath = UIBezierPath(rect: .init(x: 0, y: 0, width: 1, height: 30)).cgPath

    // 添加状态控制
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeState)))

    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 状态图片视图
  lazy var stateImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.contentMode = .center
    view.translatesAutoresizingMaskIntoConstraints = false
    view.image = stateImage

    if keyboardContext.hamsterConfig?.Keyboard?.enableColorSchema ?? false, let keyboardColor = keyboardContext.hamsterKeyboardColor {
      view.tintColor = keyboardColor.candidateTextColor
    } else {
      view.tintColor = .label
    }

    return view
  }()

  // 状态图片
  var stateImage: UIImage? {
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .default)
    return state == .collapse
      ? UIImage(systemName: "chevron.down", withConfiguration: config)
      : UIImage(systemName: "chevron.up", withConfiguration: config)
  }

  /// 布局配置
  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  init(actionHandler: KeyboardActionHandler, keyboardContext: KeyboardContext, rimeContext: RimeContext) {
    self.actionHandler = actionHandler
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext

    super.init(frame: .zero)

    setupContentView()
    combine()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 构建视图层次
  func constructViewHierarchy() {
    addSubview(phoneticArea)
    addSubview(candidatesArea)

    if keyboardContext.hamsterConfig?.toolbar?.displayKeyboardDismissButton ?? true {
      addSubview(controlStateView)
    }
  }

  /// 激活视图约束
  func activateViewConstraints() {
    phoneticArea.translatesAutoresizingMaskIntoConstraints = false
    candidatesArea.translatesAutoresizingMaskIntoConstraints = false

    let buttonInsets = layoutConfig.buttonInsets
    let codingAreaHeight = CGFloat(keyboardContext.hamsterConfig?.toolbar?.heightOfCodingArea ?? 15)

    if keyboardContext.hamsterConfig?.toolbar?.displayKeyboardDismissButton ?? true {
      NSLayoutConstraint.activate([
        phoneticArea.heightAnchor.constraint(equalToConstant: codingAreaHeight),
        phoneticArea.topAnchor.constraint(equalTo: topAnchor),
        phoneticArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
        phoneticArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonInsets.right),

        candidatesArea.topAnchor.constraint(equalTo: phoneticArea.bottomAnchor),
        candidatesArea.bottomAnchor.constraint(equalTo: bottomAnchor),
        candidatesArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
        candidatesArea.trailingAnchor.constraint(equalTo: controlStateView.leadingAnchor),

        controlStateView.topAnchor.constraint(equalTo: phoneticArea.bottomAnchor),
        controlStateView.bottomAnchor.constraint(equalTo: bottomAnchor),
        controlStateView.heightAnchor.constraint(equalTo: controlStateView.widthAnchor, multiplier: 1.0),
        controlStateView.trailingAnchor.constraint(equalTo: trailingAnchor),
      ])
    } else {
      NSLayoutConstraint.activate([
        phoneticArea.heightAnchor.constraint(equalToConstant: codingAreaHeight),
        phoneticArea.topAnchor.constraint(equalTo: topAnchor),
        phoneticArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
        phoneticArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonInsets.right),

        candidatesArea.topAnchor.constraint(equalTo: phoneticArea.bottomAnchor),
        candidatesArea.bottomAnchor.constraint(equalTo: bottomAnchor),
        candidatesArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
        candidatesArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonInsets.right),
      ])
    }
  }

  func setupContentView() {
    constructViewHierarchy()
    activateViewConstraints()
  }

  func combine() {
    Task {
      await rimeContext.$userInputKey
        .receive(on: DispatchQueue.main)
        .sink { [weak self] inputKeys in
          guard let self = self else { return }
          self.phoneticArea.text = inputKeys
        }
        .store(in: &subscription)
    }
  }

  @objc func changeState() {
    state = state == .collapse ? .expand : .collapse
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    activateViewConstraints()
  }
}
