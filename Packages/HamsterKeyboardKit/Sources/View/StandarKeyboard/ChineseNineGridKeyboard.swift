//
//  ChineseNineGrid.swift
//
//
//  Created by morse on 2023/9/5.
//

import Combine
import HamsterKit
import HamsterUIKit
import OSLog
import UIKit

/// 中文九宫格键盘
public class ChineseNineGridKeyboard: KeyboardTouchView, UICollectionViewDelegate {
  // MARK: - Properties

  private let keyboardLayoutProvider: ChineseNineGridLayoutProvider
  private let actionHandler: KeyboardActionHandler
  private let appearance: KeyboardAppearance
  private var keyboardContext: KeyboardContext
  private var calloutContext: KeyboardCalloutContext
  private var rimeContext: RimeContext
  private var nonStanderStyle: NonStandardKeyboardStyle

  // 屏幕方向
  private var interfaceOrientation: InterfaceOrientation

  private var userInterfaceStyle: UIUserInterfaceStyle

  // 键盘是否浮动
  private var isKeyboardFloating: Bool

  /// 符号列表视图

  private lazy var symbolsListView: SymbolsVerticalView = {
    let view = SymbolsVerticalView(
      style: nonStanderStyle,
      keyboardContext: keyboardContext,
      actionHandler: actionHandler,
      dataBuilder: { [unowned self] in
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(keyboardContext.symbolsOfChineseNineGridKeyboard, toSection: 0)
        $0.apply(snapshot, animatingDifferences: false)
      },
      collectionDelegateBuilder: { [unowned self] in self }
    )
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  /// 符号列表容器视图，为了添加 insets
  private lazy var symbolsListContainerView: UIView = {
    // 九宫格自身的 insets
    let insets = keyboardLayoutProvider.insets

    let container = UIView(frame: .zero)
    container.backgroundColor = .clear
    container.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(symbolsListView)
    NSLayoutConstraint.activate([
      symbolsListView.topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top),
      symbolsListView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom),
      symbolsListView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: insets.left),
      symbolsListView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -insets.right),
    ])
    return container
  }()

  // combine
  private var subscriptions = Set<AnyCancellable>()

  /// 缓存所有按键视图
  private var keyboardRows: [[KeyboardButton]] = []

  /// 静态视图约束，视图创建完毕后不在发生变化
  private var staticConstraints: [NSLayoutConstraint] = []

  private var dynamicHeightConstraints: [NSLayoutConstraint] = []

  // MARK: - 计算属性

  private var layout: KeyboardLayout {
    keyboardLayoutProvider.keyboardLayout(for: keyboardContext)
  }

  private var layoutConfig: KeyboardLayoutConfiguration {
    .standard(for: keyboardContext)
  }

  // MARK: - Initialization

  public init(
    keyboardLayoutProvider: KeyboardLayoutProvider,
    actionHandler: KeyboardActionHandler,
    appearance: KeyboardAppearance,
    keyboardContext: KeyboardContext,
    calloutContext: KeyboardCalloutContext,
    rimeContext: RimeContext
  ) {
    if let keyboardLayoutProvider = keyboardLayoutProvider as? StandardKeyboardLayoutProvider {
      self.keyboardLayoutProvider = keyboardLayoutProvider.chineseNineGridLayoutProvider
    } else {
      self.keyboardLayoutProvider = ChineseNineGridLayoutProvider()
    }
    self.actionHandler = actionHandler
    self.appearance = appearance
    self.keyboardContext = keyboardContext
    self.calloutContext = calloutContext
    self.rimeContext = rimeContext
    self.interfaceOrientation = keyboardContext.interfaceOrientation
    self.isKeyboardFloating = keyboardContext.isKeyboardFloating
    self.nonStanderStyle = appearance.nonStandardKeyboardStyle
    self.userInterfaceStyle = keyboardContext.colorScheme

    super.init(frame: .zero)

    setupKeyboardView()

    combine()
  }

  func combine() {
    // 屏幕方向改变重新计算动态高度
    keyboardContext.$interfaceOrientation
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard interfaceOrientation != $0 else { return }
        setNeedsUpdateConstraints()
      }
      .store(in: &subscriptions)

    // 屏蔽左侧候选拼音功能
    rimeContext.userInputKeyPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        var pinyinList = keyboardContext.symbolsOfChineseNineGridKeyboard
        if !$0.isEmpty {
          let candidatePinyinList = rimeContext.getPinyinCandidates()
          if !candidatePinyinList.isEmpty {
            pinyinList = candidatePinyinList
          }
        }
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(pinyinList, toSection: 0)
        symbolsListView.diffalbeDataSource.apply(snapshot, animatingDifferences: false)
      }
      .store(in: &subscriptions)
  }

  // MARK: - Layout

  func setupKeyboardView() {
    backgroundColor = .clear

    constructViewHierarchy()
    activateViewConstraints()
  }

  override public func constructViewHierarchy() {
    // 添加右侧符号划动列表
    addSubview(symbolsListContainerView)

    // 添加按键
    for (rowIndex, row) in layout.itemRows.enumerated() {
      var tempRow = [KeyboardButton]()
      for (itemIndex, item) in row.enumerated() {
        let buttonItem = KeyboardButton(
          row: rowIndex,
          column: itemIndex,
          item: item,
          actionHandler: actionHandler,
          keyboardContext: keyboardContext,
          rimeContext: rimeContext,
          calloutContext: calloutContext,
          appearance: appearance
        )
        buttonItem.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonItem)
        tempRow.append(buttonItem)
      }
      keyboardRows.append(tempRow)
    }
  }

  override public func activateViewConstraints() {
    // 根据 keyboardContext 获取当前布局配置
    // 注意：临时变量缓存计算属性的值，避免重复计算
    let layoutConfig = layoutConfig

    // 键盘两侧按键宽度,其余按键平分剩余宽度
    let edgeButtonWidth = keyboardLayoutProvider.smallBottomWidth(for: keyboardContext)

    // 最后一行小的系统按键宽度
    let lowerSystemButtonWidth = keyboardLayoutProvider.lowerSystemButtonWidth(for: keyboardContext)

    // 暂存中间部分按键，用于平分剩余宽度
    var availableItems = [KeyboardButton]()

    // 回车键
    var returnButton: KeyboardButton?

    // 左侧符号栏约束
    staticConstraints.append(symbolsListContainerView.topAnchor.constraint(equalTo: topAnchor))
    staticConstraints.append(symbolsListContainerView.leadingAnchor.constraint(equalTo: leadingAnchor))

    for row in keyboardRows {
      for button in row {
        // 按键高度约束（高度包含 insets 部分）
        let heightConstant = layoutConfig.rowHeight
        if button.row == 2 && button.column + 1 == row.endIndex { // 第3行的最后一列是回车键，因为跨行，需要加2倍高度, 所以不添加高度约束
          returnButton = button
        } else {
          let buttonHeightConstraint = button.heightAnchor.constraint(equalToConstant: heightConstant)
          buttonHeightConstraint.identifier = "\(button.row)-\(button.column)-button-height"
          // 注意：必须设置高度约束的优先级，Autolayout 会根据此约束自动更新根视图的高度，否则会与系统自动添加的约束冲突，会有错误日志输出。
          buttonHeightConstraint.priority = .defaultHigh
          dynamicHeightConstraints.append(buttonHeightConstraint)
        }

        // 按键宽度约束
        // 注意：最后一行的第一个按钮和每行最后一个按键(除最后一行)的宽度是固定的，其他按键的宽度是平分的
        if (button.column == 0 && button.row + 1 == keyboardRows.endIndex) || (button.column + 1 == row.endIndex && button.row + 1 != keyboardRows.endIndex) {
          staticConstraints.append(button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: edgeButtonWidth.percentageValue!))
        } else {
          if button.row + 1 == keyboardRows.endIndex {
            // 空格键不设置宽度约束
            if button.column == 1 || button.column + 1 == row.endIndex {
              staticConstraints.append(button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: lowerSystemButtonWidth.percentageValue!))
            }
          } else {
            availableItems.append(button)
          }
        }

        if button.row == 0 {
          // 首行添加按键相对视图的 top 约束
          staticConstraints.append(button.topAnchor.constraint(equalTo: topAnchor))
        } else {
          // 其他列添加相对上一行的符号约束
          // 其他行添加按键相对上一行按键的 top 约束
          let prevRowItem = keyboardRows[button.row - 1][0]
          staticConstraints.append(button.topAnchor.constraint(equalTo: prevRowItem.bottomAnchor))

          // 最后一行的第一列添加相对划动符号列的 top 约束
          if button.column == 0, button.row + 1 == keyboardRows.endIndex {
            staticConstraints.append(button.topAnchor.constraint(equalTo: symbolsListContainerView.bottomAnchor))
            staticConstraints.append(symbolsListContainerView.widthAnchor.constraint(equalTo: button.widthAnchor))
          }

          // 最后一行添加按键相对视图的 bottom 约束
          // 倒数第二行最后一个回车键添加夸行约束
          if (button.row + 1 == keyboardRows.endIndex) || (button.row + 2 == keyboardRows.endIndex && button.column + 1 == row.endIndex) {
            staticConstraints.append(button.bottomAnchor.constraint(equalTo: bottomAnchor))
          }
        }

        // 首列按键添加相对划动符号视图的 leading 约束
        if button.column == 0, button.row + 1 == keyboardRows.endIndex {
          staticConstraints.append(button.leadingAnchor.constraint(equalTo: leadingAnchor))
        } else if button.column == 0 {
          staticConstraints.append(button.leadingAnchor.constraint(equalTo: symbolsListContainerView.trailingAnchor))
        } else {
          // 其他列按键添加相对与前一个按键的 leading 约束
          let prevItem = keyboardRows[button.row][button.column - 1]
          staticConstraints.append(button.leadingAnchor.constraint(equalTo: prevItem.trailingAnchor))

          // 最后一列按键添加相对行的 trailing 约束
          if button.column + 1 == row.endIndex {
            // 最后一行最后一个键添加相对回车键的 traliing 约束
            if button.row + 1 == keyboardRows.endIndex, let returnButton = returnButton {
              staticConstraints.append(button.trailingAnchor.constraint(equalTo: returnButton.leadingAnchor))
            } else {
              staticConstraints.append(button.trailingAnchor.constraint(equalTo: trailingAnchor))
            }
          }
        }
      }
    }

    if let firstItem = availableItems.first {
      for item in availableItems.dropFirst() {
        staticConstraints.append(item.widthAnchor.constraint(equalTo: firstItem.widthAnchor))
      }
    }

    NSLayoutConstraint.activate(staticConstraints + dynamicHeightConstraints)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    // 样式调整
    if userInterfaceStyle != keyboardContext.colorScheme {
      userInterfaceStyle = keyboardContext.colorScheme
      nonStanderStyle = appearance.nonStandardKeyboardStyle
      symbolsListView.setStyle(nonStanderStyle)
      keyboardRows.forEach { $0.forEach { $0.setNeedsLayout() }}
    }

    // 行高调整
    guard interfaceOrientation != keyboardContext.interfaceOrientation || isKeyboardFloating != keyboardContext.isKeyboardFloating else { return }
    interfaceOrientation = keyboardContext.interfaceOrientation
    isKeyboardFloating = keyboardContext.isKeyboardFloating

    // 根据 keyboardContext 获取当前布局配置
    // 注意：临时变量缓存计算属性的值，避免重复计算
    let layoutConfig = layoutConfig
    dynamicHeightConstraints.forEach {
      $0.constant = layoutConfig.rowHeight
    }
  }
}

public extension ChineseNineGridKeyboard {
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    let symbol = symbolsListView.diffalbeDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    actionHandler.handle(.press, on: .symbol(.init(char: symbol)))
    return true
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)

    guard let _ = collectionView.cellForItem(at: indexPath) else { return }

    // 符号处理
    let symbol = symbolsListView.diffalbeDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    // 当 symbol 非字母数字，顶码上屏
    if !symbol.isMatch(regex: "\\w.*") {
      if let first = rimeContext.suggestions.first {
        keyboardContext.textDocumentProxy.insertText(first.title)
        rimeContext.reset()
      }
      keyboardContext.textDocumentProxy.insertText(symbol)
      return
    }

    // 数字候选字直接上屏
    if Int(symbol) != nil {
      keyboardContext.textDocumentProxy.insertText(symbol)
      rimeContext.reset()
      return
    }

    // 候选拼音处理: 待修改拼音音节开始位置
    var startPos = 0
    var inputKeys = rimeContext.getInputKeys()
    let inputKeysCount = inputKeys.utf8.count

    if let symbolT9Pinyin = pinyinToT9Mapping[symbol] {
      while !inputKeys.isEmpty {
        if inputKeys.hasPrefix(symbolT9Pinyin) {
          break
        }
        startPos += inputKeys.first?.utf8.count ?? 0
        inputKeys = String(inputKeys.dropFirst())
      }
    }

    // 已经选择到输入拼音末尾了
    if inputKeys.isEmpty, startPos == inputKeysCount, let selectCandidatePinyin = rimeContext.selectCandidatePinyin {
      startPos = selectCandidatePinyin.1
    }

    let handle = rimeContext.tryHandleReplaceInputTexts(symbol, startPos: startPos, count: symbol.utf8.count)
    Logger.statistics.warning("change input text handle = \(handle)")
  }
}
