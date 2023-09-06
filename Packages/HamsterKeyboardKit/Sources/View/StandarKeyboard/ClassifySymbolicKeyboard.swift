//
//  ClassifySymbolicKeyboard.swift
//
//
//  Created by morse on 2023/9/5.
//

import Combine
import UIKit

/// 分类符号键盘
class ClassifySymbolicKeyboard: UIView {
  private let keyboardContext: KeyboardContext
  private let actionHandler: KeyboardActionHandler
  private let layoutProvider: KeyboardLayoutProvider
  private var classifyViewWidthConstraint: NSLayoutConstraint?
  private var subscriptions = Set<AnyCancellable>()

  init(actionHandler: KeyboardActionHandler, layoutProvider: KeyboardLayoutProvider, keyboardContext: KeyboardContext) {
    self.actionHandler = actionHandler
    self.layoutProvider = layoutProvider
    self.keyboardContext = keyboardContext

    super.init(frame: .zero)

    backgroundColor = .standardKeyboardBackground

    constructViewHierarchy()
    activateViewConstraints()

    keyboardContext.$interfaceOrientation
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        setNeedsUpdateConstraints()
      }
      .store(in: &subscriptions)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private lazy var viewModel: ClassifySymbolicViewModel = {
    let vm = ClassifySymbolicViewModel()
    return vm
  }()

  private lazy var classifyView: ClassifyView = {
    let view = ClassifyView(keyboardContext: keyboardContext, viewModel: viewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private lazy var symbolsView: SymbolsView = {
    let view = SymbolsView(actionHandler: actionHandler, viewModel: viewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

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

  /// 构建视图层次
  open func constructViewHierarchy() {
    addSubview(classifyView)
    addSubview(symbolsView)
    addSubview(bottomRow)
  }

  /// 激活视图约束
  open func activateViewConstraints() {
    let rowHeight = layoutConfig.rowHeight

    classifyViewWidthConstraint = classifyView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: keyboardContext.interfaceOrientation.isPortrait ? 0.2 : 0.1)

    NSLayoutConstraint.activate([
      classifyView.topAnchor.constraint(equalTo: topAnchor),
      classifyView.leadingAnchor.constraint(equalTo: leadingAnchor),
      classifyViewWidthConstraint!,

      symbolsView.topAnchor.constraint(equalTo: topAnchor),
      symbolsView.leadingAnchor.constraint(equalTo: classifyView.trailingAnchor, constant: 1),
      symbolsView.trailingAnchor.constraint(equalTo: trailingAnchor),

      bottomRow.leadingAnchor.constraint(equalTo: leadingAnchor),
      bottomRow.trailingAnchor.constraint(equalTo: trailingAnchor),
      bottomRow.topAnchor.constraint(equalTo: classifyView.bottomAnchor),
      bottomRow.topAnchor.constraint(equalTo: symbolsView.bottomAnchor),
      bottomRow.bottomAnchor.constraint(equalTo: bottomAnchor),
      bottomRow.heightAnchor.constraint(equalToConstant: rowHeight)
    ])
  }

  override func updateConstraints() {
    super.updateConstraints()

    classifyViewWidthConstraint?.isActive = false
    classifyViewWidthConstraint = classifyView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: keyboardContext.interfaceOrientation.isPortrait ? 0.2 : 0.1)
    classifyViewWidthConstraint?.isActive = true
  }
}
