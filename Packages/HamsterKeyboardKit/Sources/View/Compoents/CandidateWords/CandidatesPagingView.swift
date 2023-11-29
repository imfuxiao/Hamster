//
//  CadidatesPagingView.swift
//
//
//  Created by morse on 2023/11/18.
//

import Combine
import HamsterKit
import OSLog
import UIKit

/// 候选栏手动分页视图
/// 固定每页最多10个候选字，具体数量由 default.yaml 中 menu -> page_size 控制
class CandidatesPagingCollectionView: UICollectionView {
  var style: CandidateBarStyle

  /// RIME 上下文
  let rimeContext: RimeContext

  let keyboardContext: KeyboardContext

  let actionHandler: KeyboardActionHandler

  var subscriptions = Set<AnyCancellable>()

  /// 水平滚动方向布局
  let horizontalLayout: UICollectionViewLayout

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
    self.alwaysBounceHorizontal = false
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
    rimeContext.$rimeContext
      .receive(on: DispatchQueue.main)
      .sink { [weak self] context in
        guard let self = self else { return }
        guard let context = context else { return }
        guard let highlightedIndex = context.menu?.highlightedCandidateIndex else { return }
        guard let pageCandidates = context.menu?.candidates else { return }
        let labels = context.labels ?? [String]()
        let selectKeys = (context.menu?.selectKeys ?? "").map { String($0) }
        var candidates = [CandidateSuggestion]()
        for (index, candidate) in pageCandidates.enumerated() {
          let suggestion = CandidateSuggestion(
            index: index,
            label: indexLabel(index, labels: labels, selectKeys: selectKeys),
            text: candidate.text,
            title: candidate.text,
            isAutocomplete: index == highlightedIndex,
            subtitle: candidate.comment
          )
          candidates.append(suggestion)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, CandidateSuggestion>()
        snapshot.appendSections([0])
        snapshot.appendItems(candidates, toSection: 0)
        diffableDataSource.applySnapshotUsingReloadData(snapshot)
      }
      .store(in: &subscriptions)
  }

  /// 显示 index 对应的 label
  /// 优先级：labels > selectKeys > index
  func indexLabel(_ index: Int, labels: [String], selectKeys: [String]) -> String {
    if index < labels.count, !labels[index].isEmpty {
      return labels[index].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    if index < selectKeys.count, !selectKeys[index].isEmpty {
      return selectKeys[index].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return "\(index + 1)"
  }

  func reloadDiffableDataSource() {
    var snapshot = self.diffableDataSource.snapshot()
    snapshot.reloadSections([0])
    self.diffableDataSource.apply(snapshot, animatingDifferences: false)
  }
}

// MAKE: - UICollectionViewDelegate

extension CandidatesPagingCollectionView: UICollectionViewDelegate {
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

extension CandidatesPagingCollectionView: UICollectionViewDelegateFlowLayout {
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
    return 5
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let isVerticalLayout: Bool = !self.candidatesViewState.isCollapse()
    let heightOfCodingArea: CGFloat = keyboardContext.enableEmbeddedInputMode ? 0 : keyboardContext.heightOfCodingArea
    let heightOfToolbar: CGFloat = keyboardContext.heightOfToolbar - heightOfCodingArea - 6

    let candidate = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    let toolbarConfig = keyboardContext.hamsterConfiguration?.toolbar

    let showComment = toolbarConfig?.displayCommentOfCandidateWord ?? false
    let showIndex = toolbarConfig?.displayIndexOfCandidateWord ?? false

    // 为 cell 内容增加左右间距, 对应 cell 的 leading, trailing 的约束
    let intrinsicHorizontalMargin: CGFloat = 14

    // 60 为下拉状态按钮宽度, 220 是 横屏时需要减去全面屏两侧的宽度(注意：这里忽略的非全面屏)
    let maxWidth: CGFloat = UIScreen.main.bounds.width - ((self.window?.screen.interfaceOrientation == .portrait) ? 60 : 220)

    let attributeString = candidate.attributeString(showIndex: showIndex, showComment: showComment, style: style)

    // 60 是下拉箭头按键的宽度，垂直滑动的 label 在超出宽度时，文字折叠
    let targetWidth: CGFloat = maxWidth - (isVerticalLayout ? 60 : 0)

    var titleLabelSize = UILabel.estimatedAttributeSize(attributeString, targetSize: CGSize(width: targetWidth, height: 0))

    if attributeString.string.count == 1, let minWidth = UILabel.fontSizeAndMinWidthMapping[style.candidateTextFont.pointSize] {
      titleLabelSize.width = minWidth
    }

    let width = titleLabelSize.width + intrinsicHorizontalMargin
    return CGSize(
      // 垂直布局下，cell 宽度不能大于屏幕宽度
      width: isVerticalLayout ? min(width, maxWidth) : width,
      height: heightOfToolbar
    )
  }
}
