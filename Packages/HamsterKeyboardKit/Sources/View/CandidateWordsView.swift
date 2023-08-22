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
  private var keyboardContext: KeyboardContext
  private var rimeContext: RimeContext

  private var subscription = Set<AnyCancellable>()
  /// 拼音区域
  lazy var phoneticArea: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.baselineAdjustment = UIBaselineAdjustment.alignCenters
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.numberOfLines = 1
    return label
  }()

  /// 候选文字区域
  lazy var candidatesArea: CandidateWordsCollectionView = {
    let view = CandidateWordsCollectionView(rimeContext: rimeContext, direction: .horizontal)
    return view
  }()

  /// 布局配置
  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  init(keyboardContext: KeyboardContext, rimeContext: RimeContext) {
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
  }

  /// 激活视图约束
  func activateViewConstraints() {
    phoneticArea.translatesAutoresizingMaskIntoConstraints = false
    candidatesArea.translatesAutoresizingMaskIntoConstraints = false

    let buttonInsets = layoutConfig.buttonInsets
    // TODO: 高度可按配置调整
    NSLayoutConstraint.activate([
      phoneticArea.heightAnchor.constraint(equalToConstant: 15),
      phoneticArea.topAnchor.constraint(equalTo: topAnchor),
      phoneticArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
      phoneticArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonInsets.right),

      candidatesArea.topAnchor.constraint(equalTo: phoneticArea.bottomAnchor),
      candidatesArea.bottomAnchor.constraint(equalTo: bottomAnchor),
      candidatesArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonInsets.left),
      candidatesArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonInsets.right),
    ])
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

  override func layoutSubviews() {
    super.layoutSubviews()

    activateViewConstraints()
  }
}
