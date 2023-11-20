//
//  CandidateWordsCollectionView.swift
//
//
//  Created by morse on 2023/8/19.
//

import Combine
import HamsterKit
import OSLog
import UIKit

/**
 候选文字集合视图
 */
public class CandidateWordsCollectionView: UICollectionView {
  var style: CandidateBarStyle

  /// RIME 上下文
  let rimeContext: RimeContext

  let keyboardContext: KeyboardContext

  let actionHandler: KeyboardActionHandler

  /// 水平滚动方向布局
  let horizontalLayout: UICollectionViewLayout

  /// 垂直滚动方向布局
  let verticalLayout: UICollectionViewLayout

  /// Combine
  var subscriptions = Set<AnyCancellable>()

  /// 候选栏状态
  var candidatesViewState: CandidateBarView.State

  /// 当前用户输入，用来判断滚动候选栏是否滚动到首个首选字
  var currentUserInputKey: String = ""

  private var diffableDataSource: UICollectionViewDiffableDataSource<Int, CandidateSuggestion>! = nil

  init(
    style: CandidateBarStyle,
    keyboardContext: KeyboardContext,
    actionHandler: KeyboardActionHandler,
    rimeContext: RimeContext
  ) {
    self.style = style
    self.keyboardContext = keyboardContext
    self.actionHandler = actionHandler
    self.rimeContext = rimeContext
    self.candidatesViewState = keyboardContext.candidatesViewState

    self.horizontalLayout = {
      let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .justified, verticalAlignment: .center)
      layout.scrollDirection = .horizontal
      return layout
    }()

    self.verticalLayout = {
      let layout = SeparatorCollectionViewFlowLayout(horizontalAlignment: .justified, verticalAlignment: .center)
      layout.scrollDirection = .vertical
      return layout
    }()

    super.init(frame: .zero, collectionViewLayout: horizontalLayout)

    self.delegate = self
    self.diffableDataSource = makeDataSource()

    // init data
    var snapshot = NSDiffableDataSourceSnapshot<Int, CandidateSuggestion>()
    snapshot.appendSections([0])
    snapshot.appendItems([], toSection: 0)
    diffableDataSource.apply(snapshot, animatingDifferences: false)

    self.backgroundColor = UIColor.clear
    // 水平划动状态下不允许垂直划动
    self.showsHorizontalScrollIndicator = false
    self.alwaysBounceHorizontal = true
    self.alwaysBounceVertical = false

    combine()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupStyle(_ style: CandidateBarStyle) {
    self.style = style

    // 重新加载数据
    reloadDiffableDataSource()
  }

  /// 构建数据源
  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, CandidateSuggestion> {
    let toolbarConfig = keyboardContext.hamsterConfiguration?.toolbar
    let showIndex = toolbarConfig?.displayIndexOfCandidateWord
    let showComment = toolbarConfig?.displayCommentOfCandidateWord

    let candidateWordCellRegistration = UICollectionView.CellRegistration<CandidateWordCell, CandidateSuggestion>
    { [unowned self] cell, _, candidateSuggestion in
      cell.updateWithCandidateSuggestion(
        candidateSuggestion,
        style: style,
        showIndex: showIndex,
        showComment: showComment
      )
    }

    let dataSource = UICollectionViewDiffableDataSource<Int, CandidateSuggestion>(collectionView: self) { collectionView, indexPath, candidateSuggestion in
      collectionView.dequeueConfiguredReusableCell(using: candidateWordCellRegistration, for: indexPath, item: candidateSuggestion)
    }

    return dataSource
  }

  func combine() {
    self.rimeContext.registryHandleSuggestionsChanged { [weak self] candidates in
      guard let self = self else { return }

      Logger.statistics.debug("self.rimeContext.$suggestions: \(candidates.count)")

      var snapshot = NSDiffableDataSourceSnapshot<Int, CandidateSuggestion>()
      snapshot.appendSections([0])
      snapshot.appendItems(candidates, toSection: 0)
      diffableDataSource.applySnapshotUsingReloadData(snapshot)

      if currentUserInputKey != rimeContext.userInputKey {
        currentUserInputKey = rimeContext.userInputKey
        if !candidates.isEmpty {
          if candidatesViewState.isCollapse() {
            self.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: false)
          } else {
            self.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
          }
          return
        }
      }

      if candidates.isEmpty {
        self.keyboardContext.candidatesViewState = .collapse
      }
    }

    keyboardContext.$candidatesViewState
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] state in
        guard self.candidatesViewState != state else { return }
        self.candidatesViewState = state
        changeLayout(state)
      }
      .store(in: &subscriptions)
  }

  func changeLayout(_ state: CandidateBarView.State) {
    if state.isCollapse() {
      setCollectionViewLayout(horizontalLayout, animated: false) { [weak self] _ in
        guard let self = self else { return }
        self.alwaysBounceHorizontal = true
        self.alwaysBounceVertical = false
        self.contentOffset = .zero
        // self.reloadDiffableDataSource()
      }
    } else {
      setCollectionViewLayout(verticalLayout, animated: false) { [weak self] _ in
        guard let self = self else { return }
        self.alwaysBounceHorizontal = false
        self.alwaysBounceVertical = true
        self.contentOffset = .zero
        // self.reloadDiffableDataSource()
      }
    }
  }

  func reloadDiffableDataSource() {
    var snapshot = self.diffableDataSource.snapshot()
    snapshot.reloadSections([0])
    self.diffableDataSource.apply(snapshot, animatingDifferences: false)
  }
}

// MAKE: - UICollectionViewDelegate

extension CandidateWordsCollectionView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let count = diffableDataSource.snapshot(for: indexPath.section).items.count
    if indexPath.item + 1 == count {
      rimeContext.nextPage()
    }
  }

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let _ = collectionView.cellForItem(at: indexPath) else { return }
    // 用于触发反馈
    actionHandler.handle(.press, on: .character(""))
    self.rimeContext.selectCandidate(index: indexPath.item)
  }

  public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) {
      cell.isHighlighted = true
    }
  }
}

// MAKE: - UICollectionViewDelegateFlowLayout

extension CandidateWordsCollectionView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
  }

  // 询问委托一个部分连续的行或列之间的间距。
  // 对于一个垂直滚动的网格，这个值表示连续的行之间的最小间距。
  // 对于一个水平滚动的网格，这个值代表连续的列之间的最小间距。
  // 这个间距不应用于标题和第一行之间的空间或最后一行和页脚之间的空间。
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 3
  }

  // 向委托询问某部分的行或列中连续项目之间的间距。
  // 你对这个方法的实现可以返回一个固定的值或者为每个部分返回不同的间距值。
  // 对于一个垂直滚动的网格，这个值代表了同一行中项目之间的最小间距。
  // 对于一个水平滚动的网格，这个值代表同一列中项目之间的最小间距。
  // 这个间距是用来计算单行可以容纳多少个项目的，但是在确定了项目的数量之后，实际的间距可能会被向上调整。
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    let isVerticalLayout: Bool = !self.candidatesViewState.isCollapse()
    if isVerticalLayout {
      return 1
    }
    return 5
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let isVerticalLayout: Bool = !self.candidatesViewState.isCollapse()
    let heightOfCodingArea: CGFloat = keyboardContext.enableEmbeddedInputMode ? 0 : keyboardContext.heightOfCodingArea
    let heightOfToolbar: CGFloat = keyboardContext.heightOfToolbar - heightOfCodingArea - 6

    let candidate = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    let toolbarConfig = keyboardContext.hamsterConfiguration?.toolbar

    var candidateTextFont = KeyboardFont.title3.font
    var candidateCommentFont = KeyboardFont.caption2.font

    if let titleFontSize = toolbarConfig?.candidateWordFontSize {
      candidateTextFont = UIFont.systemFont(ofSize: CGFloat(titleFontSize))
    }
    if let subtileFontSize = toolbarConfig?.candidateCommentFontSize {
      candidateCommentFont = UIFont.systemFont(ofSize: CGFloat(subtileFontSize))
    }

    let showComment = toolbarConfig?.displayCommentOfCandidateWord ?? false
    let showIndex = toolbarConfig?.displayIndexOfCandidateWord ?? false

    // 垂直布局时，为 cell 内容增加左右间距
    let intrinsicHorizontalMargin: CGFloat = isVerticalLayout ? 20 : 12

    // 60 为下拉状态按钮宽度, 220 是 横屏时需要减去全面屏两侧的宽度(注意：这里忽略的非全面屏)
    let maxWidth: CGFloat = UIScreen.main.bounds.width - ((self.window?.screen.interfaceOrientation == .portrait) ? 60 : 220)

    let titleText = showIndex ? "\(candidate.showIndexLabel) \(candidate.title)" : candidate.title
    // 60 是下拉箭头按键的宽度，垂直滑动的 label 在超出宽度时，文字折叠
    let targetWidth: CGFloat = maxWidth - (isVerticalLayout ? 60 : 0)

    var titleLabelSize = UILabel.estimatedSize(
      titleText,
      targetSize: CGSize(width: targetWidth, height: 0),
      font: candidateTextFont
    )

    if titleText.count == 1, let minWidth = UILabel.fontSizeAndMinWidthMapping[candidateTextFont.pointSize] {
      titleLabelSize.width = minWidth
    }

    // 不显示 comment
    if !showComment {
      let width = titleLabelSize.width + intrinsicHorizontalMargin
      return CGSize(
        // 垂直布局下，cell 宽度不能大于屏幕宽度
        width: isVerticalLayout ? min(width, maxWidth) : width,
        height: heightOfToolbar
      )
    }

    var subtitleLabelSize = CGSize.zero
    if let subtitle = candidate.subtitle {
      subtitleLabelSize = UILabel.estimatedSize(
        subtitle,
        targetSize: CGSize(width: targetWidth, height: 0),
        font: candidateCommentFont
      )

      if subtitle.count == 1, let minWidth = UILabel.fontSizeAndMinWidthMapping[candidateCommentFont.pointSize] {
        subtitleLabelSize.width = minWidth
      }
    }

    let width = titleLabelSize.width + subtitleLabelSize.width + intrinsicHorizontalMargin
    return CGSize(
      // 垂直布局下，cell 宽度不能大于屏幕宽度
      width: isVerticalLayout ? min(width, maxWidth) : width,
      height: heightOfToolbar
    )
  }
}

public extension UILabel {
  /// 字体大小与最小宽度映射
  /// 最小宽度是由单个 emoji 表情计算得出, 比如：🉐，
  /// 因为单个 emoji 表情的宽度比单个汉字的宽度大，所以使用 emoji 作为最小宽度
  /// key: 字体大小
  /// value: 最小宽度
  static let fontSizeAndMinWidthMapping: [CGFloat: CGFloat] = [
    10: 14,
    11: 16,
    12: 17,
    13: 19,
    14: 20,
    15: 21,
    16: 23,
    17: 23,
    18: 24,
    19: 24,
    20: 25,
    21: 26,
    22: 26,
    23: 27,
    24: 27,
    25: 28,
    26: 30,
    27: 31,
    28: 32,
    29: 33,
    30: 34,
  ]

  static var tempLabelForCalc: UILabel = {
    let label = UILabel()
    label.numberOfLines = 1
    return label
  }()

  static func estimatedSize(_ text: String, targetSize: CGSize = .zero, font: UIFont? = nil) -> CGSize {
    tempLabelForCalc.text = text
    if let font = font {
      tempLabelForCalc.font = font
    }
    return tempLabelForCalc.sizeThatFits(targetSize)
  }
}
