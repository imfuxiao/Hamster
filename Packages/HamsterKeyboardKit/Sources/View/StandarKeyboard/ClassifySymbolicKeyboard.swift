//
//  ClassifySymbolicKeyboard.swift
//
//
//  Created by morse on 2023/9/5.
//

import HamsterUIKit
import UIKit

/// 分类符号键盘
class ClassifySymbolicKeyboard: NibLessView {
  private let keyboardContext: KeyboardContext
  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private let layoutProvider: KeyboardLayoutProvider
  private var classifyViewHeightConstraint: NSLayoutConstraint?
  private var bottomRowViewHeightConstraint: NSLayoutConstraint?
  private var classifyViewWidthConstraint: NSLayoutConstraint?

  // 屏幕方向
  private var interfaceOrientation: InterfaceOrientation
  private var userInterfaceStyle: UIUserInterfaceStyle

  private var style: NonStandardKeyboardStyle

  // 键盘是否浮动
  private var isKeyboardFloating: Bool

  private lazy var viewModel: ClassifySymbolicViewModel = {
    let vm = ClassifySymbolicViewModel()
    return vm
  }()

  /// 左侧分类列表
  private lazy var classifyView: ClassifyView = {
    let view = ClassifyView(style: style, keyboardContext: keyboardContext, viewModel: viewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 右侧符号视图
  private lazy var symbolsView: SymbolsView = {
    let view = SymbolsView(style: style, keyboardContext: keyboardContext, actionHandler: actionHandler, viewModel: viewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 底部按钮
  private lazy var bottomRow: BottomRowView = {
    let view = BottomRowView(
      style: style,
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

  init(actionHandler: KeyboardActionHandler, appearance: KeyboardAppearance, layoutProvider: KeyboardLayoutProvider, keyboardContext: KeyboardContext) {
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.layoutProvider = layoutProvider
    self.keyboardContext = keyboardContext
    self.interfaceOrientation = keyboardContext.interfaceOrientation
    self.isKeyboardFloating = keyboardContext.isKeyboardFloating
    self.userInterfaceStyle = keyboardContext.colorScheme
    self.style = appearance.nonStandardKeyboardStyle

    super.init(frame: .zero)

    constructViewHierarchy()
    activateViewConstraints()
  }

  // MARK: - Layout

  /// 构建视图层次
  override func constructViewHierarchy() {
    addSubview(classifyView)
    addSubview(symbolsView)
    addSubview(bottomRow)
  }

  /// 激活视图约束
  override func activateViewConstraints() {
    let layoutConfig = layoutConfig
    let symbolViewHeight = layoutConfig.rowHeight * 3

    classifyViewWidthConstraint = createClassifyViewWidthConstraint()
    bottomRowViewHeightConstraint = bottomRow.heightAnchor.constraint(equalToConstant: layoutConfig.rowHeight)
    bottomRowViewHeightConstraint?.priority = .defaultHigh
    classifyViewHeightConstraint = classifyView.heightAnchor.constraint(equalToConstant: symbolViewHeight)
    classifyViewHeightConstraint?.priority = .defaultHigh

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
      symbolsView.heightAnchor.constraint(equalTo: classifyView.heightAnchor),
      classifyViewWidthConstraint!,
      bottomRowViewHeightConstraint!,
      classifyViewHeightConstraint!
    ])
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if userInterfaceStyle != keyboardContext.colorScheme {
      userInterfaceStyle = keyboardContext.colorScheme
      style = appearance.nonStandardKeyboardStyle
      classifyView.setStyle(style)
      symbolsView.setStyle(style)
      bottomRow.setStyle(style)
    }

    guard interfaceOrientation != keyboardContext.interfaceOrientation || isKeyboardFloating != keyboardContext.isKeyboardFloating else { return }
    interfaceOrientation = keyboardContext.interfaceOrientation
    isKeyboardFloating = keyboardContext.isKeyboardFloating

    classifyViewWidthConstraint?.isActive = false
    classifyViewWidthConstraint = createClassifyViewWidthConstraint()
    classifyViewWidthConstraint?.isActive = true

    let layoutConfig = layoutConfig
    let symbolViewHeight = layoutConfig.rowHeight * 3
    classifyViewHeightConstraint?.constant = symbolViewHeight
    bottomRowViewHeightConstraint?.constant = layoutConfig.rowHeight
  }

  func createClassifyViewWidthConstraint() -> NSLayoutConstraint {
    classifyView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: keyboardContext.interfaceOrientation.isPortrait ? 0.2 : 0.15)
  }
}
