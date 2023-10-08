//
//  CandidateWordsView.swift
//
//
//  Created by morse on 2023/8/19.
//

import Combine
import HamsterKit
import HamsterUIKit
import UIKit

/**
 候选文字视图
 */
public class CandidateWordsView: NibLessView {
  /// 候选区状态
  public enum State {
    /// 展开
    case expand
    /// 收起
    case collapse

    func isCollapse() -> Bool {
      return self == .collapse
    }
  }

  private var actionHandler: KeyboardActionHandler
  private var keyboardContext: KeyboardContext
  private var rimeContext: RimeContext

  private var subscription = Set<AnyCancellable>()

  private var dynamicControlStateHeightConstraint: NSLayoutConstraint?

  /// 拼音Label
  lazy var phoneticLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    if let fontSize = keyboardContext.hamsterConfig?.toolbar?.codingAreaFontSize {
      label.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    label.textColor = keyboardContext.phoneticTextColor
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  /// 拼音区域
  ///
  lazy var phoneticArea: UIView = {
    let view = UIView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(phoneticLabel)
    phoneticLabel.fillSuperview()
    return view
  }()

  /// 候选文字区域
  lazy var candidatesArea: CandidateWordsCollectionView = {
    let view = CandidateWordsCollectionView(
      keyboardContext: keyboardContext,
      actionHandler: actionHandler,
      rimeContext: rimeContext)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 状态图片视图
  lazy var stateImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.contentMode = .center
    view.translatesAutoresizingMaskIntoConstraints = false
    view.image = stateImage(.collapse)
    view.tintColor = keyboardContext.candidateTextColor
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
      stateImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])

    // 添加阴影
    let heightOfCodingArea: CGFloat = keyboardContext.enableEmbeddedInputMode ? 0 : keyboardContext.heightOfCodingArea
    let heightOfToolbar = keyboardContext.heightOfToolbar
    let offsetY = (heightOfToolbar - heightOfCodingArea - 30) / 2

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

  /// 布局配置
  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  private var controlStateHeightConstraint: NSLayoutConstraint {
    keyboardContext.candidatesViewState.isCollapse()
      ? controlStateView.heightAnchor.constraint(equalTo: candidatesArea.heightAnchor)
      : controlStateView.heightAnchor.constraint(equalToConstant: 50)
  }

  init(actionHandler: KeyboardActionHandler, keyboardContext: KeyboardContext, rimeContext: RimeContext) {
    self.actionHandler = actionHandler
    self.keyboardContext = keyboardContext
    self.rimeContext = rimeContext

    super.init(frame: .zero)

    combine()
  }

  override public func didMoveToWindow() {
    super.didMoveToWindow()

    setupContentView()
  }

  func setupContentView() {
    constructViewHierarchy()
    activateViewConstraints()
  }

  /// 构建视图层次
  override public func constructViewHierarchy() {
    // 非内嵌模式添加拼写区域
    if !keyboardContext.enableEmbeddedInputMode {
      addSubview(phoneticArea)
    }
    addSubview(candidatesArea)
    addSubview(controlStateView)
  }

  /// 激活视图约束
  override public func activateViewConstraints() {
    let buttonInsets = layoutConfig.buttonInsets
    let codingAreaHeight = CGFloat(keyboardContext.hamsterConfig?.toolbar?.heightOfCodingArea ?? 15)

    let controlStateHeightConstraint = controlStateHeightConstraint
    dynamicControlStateHeightConstraint = controlStateHeightConstraint

    // 下拉状态按钮长宽比
    let controlStateWidthAndHeightConstraint = controlStateView.heightAnchor.constraint(equalTo: controlStateView.widthAnchor, multiplier: 1.0)
    controlStateWidthAndHeightConstraint.identifier = "controlStateWidthAndHeightConstraint"
    controlStateWidthAndHeightConstraint.priority = .defaultHigh

    let phoneticAreaLeadingConstraint = phoneticArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left)
    phoneticAreaLeadingConstraint.identifier = "phoneticAreaLeadingConstraint"
    phoneticAreaLeadingConstraint.priority = .defaultHigh

    let candidatesAreaLeadingConstraint = candidatesArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left)
    candidatesAreaLeadingConstraint.identifier = "candidatesAreaLeadingConstraint"
    candidatesAreaLeadingConstraint.priority = .defaultHigh

    /// 内嵌模式
    if keyboardContext.enableEmbeddedInputMode {
      NSLayoutConstraint.activate([
        candidatesArea.topAnchor.constraint(equalTo: topAnchor),
        candidatesArea.bottomAnchor.constraint(equalTo: bottomAnchor),
        candidatesAreaLeadingConstraint,
        candidatesArea.trailingAnchor.constraint(equalTo: controlStateView.leadingAnchor),

        controlStateView.topAnchor.constraint(equalTo: topAnchor),
        controlStateView.trailingAnchor.constraint(equalTo: trailingAnchor),
        controlStateHeightConstraint,
        controlStateWidthAndHeightConstraint
      ])
    } else {
      NSLayoutConstraint.activate([
        phoneticArea.heightAnchor.constraint(equalToConstant: codingAreaHeight),
        phoneticArea.topAnchor.constraint(equalTo: topAnchor),
        phoneticAreaLeadingConstraint,
        phoneticArea.trailingAnchor.constraint(equalTo: trailingAnchor),

        candidatesArea.topAnchor.constraint(equalTo: phoneticArea.bottomAnchor),
        candidatesArea.bottomAnchor.constraint(equalTo: bottomAnchor),
        candidatesAreaLeadingConstraint,

        controlStateView.topAnchor.constraint(equalTo: phoneticArea.bottomAnchor),
        controlStateView.leadingAnchor.constraint(equalTo: candidatesArea.trailingAnchor),
        controlStateView.trailingAnchor.constraint(equalTo: trailingAnchor),
        controlStateHeightConstraint,
        controlStateWidthAndHeightConstraint
      ])
    }
  }

  func combine() {
    Task {
      // 检测是否启用内嵌编码
      guard !keyboardContext.enableEmbeddedInputMode else { return }
      await rimeContext.$userInputKey
        .receive(on: DispatchQueue.main)
        .sink { [weak self] inputKeys in
          guard let self = self else { return }
          if self.keyboardContext.keyboardType.isChineseNineGrid {
            // Debug
            // self.phoneticArea.text = inputKeys + " | " + self.rimeContext.t9UserInputKey
            self.phoneticLabel.text = self.rimeContext.t9UserInputKey
          } else {
            self.phoneticLabel.text = inputKeys
          }
        }
        .store(in: &subscription)
    }

    keyboardContext.$candidatesViewState
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] state in
        stateImageView.image = stateImage(state)
        controlStateView.layer.shadowOpacity = state.isCollapse() ? 0.3 : 0
        if let dynamicControlStateHeightConstraint = dynamicControlStateHeightConstraint {
          dynamicControlStateHeightConstraint.isActive = false
          self.dynamicControlStateHeightConstraint = controlStateHeightConstraint
          self.dynamicControlStateHeightConstraint?.isActive = true
        }
      }.store(in: &subscription)
  }

  @objc func changeState() {
    keyboardContext.candidatesViewState = keyboardContext.candidatesViewState.isCollapse() ? .expand : .collapse
  }

  // 状态图片
  func stateImage(_ state: State) -> UIImage? {
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .default)
    return state == .collapse
      ? UIImage(systemName: "chevron.down", withConfiguration: config)
      : UIImage(systemName: "chevron.up", withConfiguration: config)
  }
}
