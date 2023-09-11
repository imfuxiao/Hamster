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
public class CandidateWordsView: UIView {
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

  /// 拼音区域
  lazy var phoneticArea: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true
    if let fontSize = keyboardContext.hamsterConfig?.toolbar?.codingAreaFontSize {
      label.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    label.textColor = keyboardContext.phoneticTextColor
    return label
  }()

  /// 候选文字区域
  lazy var candidatesArea: CandidateWordsCollectionView = {
    let view = CandidateWordsCollectionView(
      keyboardContext: keyboardContext,
      actionHandler: actionHandler,
      rimeContext: rimeContext)
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
    let heightOfCodingArea = keyboardContext.heightOfCodingArea
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

  /// 状态图片视图
  lazy var stateImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.contentMode = .center
    view.translatesAutoresizingMaskIntoConstraints = false
    view.image = stateImage(.collapse)
    view.tintColor = keyboardContext.candidateTextColor
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

    let controlStateHeightConstraint = controlStateHeightConstraint
    dynamicControlStateHeightConstraint = controlStateHeightConstraint

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
      controlStateView.trailingAnchor.constraint(equalTo: trailingAnchor),
      controlStateHeightConstraint,
      controlStateView.heightAnchor.constraint(equalTo: controlStateView.widthAnchor, multiplier: 1.0),
    ])
  }

  func setupContentView() {
    constructViewHierarchy()
    activateViewConstraints()
  }

  func combine() {
    Task {
//      if self.keyboardContext.keyboardType.isChineseNineGrid {
//        await rimeContext.$suggestions
//          .receive(on: DispatchQueue.main)
//          .sink { [weak self] suggestions in
//            guard let self = self else { return }
//            if let first = suggestions.first {
//              self.phoneticArea.text = first.subtitle
//            }
//          }
//          .store(in: &subscription)
//        return
//      }

      await rimeContext.$userInputKey
        .receive(on: DispatchQueue.main)
        .sink { [weak self] inputKeys in
          guard let self = self else { return }
          if self.keyboardContext.keyboardType.isChineseNineGrid {
            self.phoneticArea.text = self.rimeContext.t9UserInputKey
          } else {
            self.phoneticArea.text = inputKeys
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
          NSLayoutConstraint.deactivate([dynamicControlStateHeightConstraint])
          self.dynamicControlStateHeightConstraint = controlStateHeightConstraint
          NSLayoutConstraint.activate([self.dynamicControlStateHeightConstraint!])
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
