//
//  ClassifySymbolicKeyboard.swift
//
//
//  Created by morse on 2023/9/5.
//

import Combine
import HamsterUIKit
import UIKit

/// 分类符号键盘
class ClassifySymbolicKeyboard: NibLessView {
  private let keyboardContext: KeyboardContext
  private let actionHandler: KeyboardActionHandler
  private let layoutProvider: KeyboardLayoutProvider
  private var subscriptions = Set<AnyCancellable>()
  private var subviewConstraints = [NSLayoutConstraint]()
  private var classifyViewWidthConstraint: NSLayoutConstraint?
  private var bottomRowViewHeightConstraint: NSLayoutConstraint?

  // 屏幕方向
  private var interfaceOrientation: InterfaceOrientation

  private lazy var viewModel: ClassifySymbolicViewModel = {
    let vm = ClassifySymbolicViewModel()
    return vm
  }()

  /// 左侧分类列表
  private lazy var classifyView: ClassifyView = {
    let view = ClassifyView(keyboardContext: keyboardContext, viewModel: viewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 右侧符号视图
  private lazy var symbolsView: SymbolsView = {
    let view = SymbolsView(keyboardContext: keyboardContext, actionHandler: actionHandler, viewModel: viewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 底部按钮
  private lazy var bottomRow: BottomRowView = {
    let view = BottomRowView(
      actionHandler: actionHandler,
      layoutProvider: layoutProvider,
      keyboardContext: keyboardContext)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  // MARK: - 计算属性

  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  // MARK: - Initailization

  init(actionHandler: KeyboardActionHandler, layoutProvider: KeyboardLayoutProvider, keyboardContext: KeyboardContext) {
    self.actionHandler = actionHandler
    self.layoutProvider = layoutProvider
    self.keyboardContext = keyboardContext
    self.interfaceOrientation = keyboardContext.interfaceOrientation

    super.init(frame: .zero)

    keyboardContext.$interfaceOrientation
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        setNeedsUpdateConstraints()
      }
      .store(in: &subscriptions)
  }

  // MARK: - Layout

  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()
  }

  /// 构建视图层次
  override func constructViewHierarchy() {
    addSubview(classifyView)
    addSubview(symbolsView)
    addSubview(bottomRow)
  }

  /// 激活视图约束
  override func activateViewConstraints() {
    classifyViewWidthConstraint = classifyView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: keyboardContext.interfaceOrientation.isPortrait ? 0.2 : 0.15)
    bottomRowViewHeightConstraint = bottomRow.heightAnchor.constraint(equalToConstant: keyboardContext.interfaceOrientation.isPortrait ? 40 : 30)

    NSLayoutConstraint.activate([
      classifyView.topAnchor.constraint(equalTo: topAnchor),
      classifyView.leadingAnchor.constraint(equalTo: leadingAnchor),
      symbolsView.topAnchor.constraint(equalTo: topAnchor),
      symbolsView.leadingAnchor.constraint(equalTo: classifyView.trailingAnchor, constant: 1),
      symbolsView.trailingAnchor.constraint(equalTo: trailingAnchor),
      bottomRow.leadingAnchor.constraint(equalTo: leadingAnchor),
      bottomRow.trailingAnchor.constraint(equalTo: trailingAnchor),
      bottomRow.topAnchor.constraint(equalTo: classifyView.bottomAnchor),
      bottomRow.topAnchor.constraint(equalTo: symbolsView.bottomAnchor),
      bottomRow.bottomAnchor.constraint(equalTo: bottomAnchor),
      classifyViewWidthConstraint!,
      bottomRowViewHeightConstraint!,
    ])
  }

  override func updateConstraints() {
    super.updateConstraints()

    guard interfaceOrientation != keyboardContext.interfaceOrientation else { return }
    interfaceOrientation = keyboardContext.interfaceOrientation

    classifyViewWidthConstraint?.isActive = false
    bottomRowViewHeightConstraint?.isActive = false

    classifyViewWidthConstraint = classifyView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: keyboardContext.interfaceOrientation.isPortrait ? 0.2 : 0.15)
    bottomRowViewHeightConstraint = bottomRow.heightAnchor.constraint(equalToConstant: keyboardContext.interfaceOrientation.isPortrait ? 40 : 30)

    classifyViewWidthConstraint?.isActive = true
    bottomRowViewHeightConstraint?.isActive = true
  }
}
