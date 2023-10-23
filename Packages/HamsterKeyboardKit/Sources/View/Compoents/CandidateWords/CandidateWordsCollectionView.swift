//
//  CandidateWordsCollectionView.swift
//
//
//  Created by morse on 2023/8/19.
//

import Combine
import HamsterKit
import OSLog
import RimeKit
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

    let heightOfToolbar = keyboardContext.heightOfToolbar
    let heightOfCodingArea: CGFloat = keyboardContext.enableEmbeddedInputMode ? 0 : keyboardContext.heightOfCodingArea

    self.horizontalLayout = {
      let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(30), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(30), heightDimension: .absolute(heightOfToolbar - heightOfCodingArea))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      let section = NSCollectionLayoutSection(group: group)
      // 控制水平方向 item 之间间距
      // 注意：添加间距会导致点击间距无响应，需要将间距在 cell 的自动布局中添加进去
      section.interGroupSpacing = 0
      section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
      // 控制垂直方向距拼写区的间距
      // 注意：添加间距会导致点击间距无响应，需要将间距在 cell 的自动布局中添加进去
      section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
      return UICollectionViewCompositionalLayout(section: section)
    }()

    self.verticalLayout = {
      let layout = SeparatorCollectionViewFlowLayout()
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

    self.backgroundColor = UIColor.clearInteractable
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
    let toolbarConfig = keyboardContext.hamsterConfig?.toolbar
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
    Task {
      await self.rimeContext.$suggestions
        .receive(on: DispatchQueue.main)
        .sink { [weak self] candidates in
          guard let self = self else { return }

          Logger.statistics.debug("self.rimeContext.$suggestions: \(candidates.count)")

          var snapshot = NSDiffableDataSourceSnapshot<Int, CandidateSuggestion>()
          snapshot.appendSections([0])
          snapshot.appendItems(candidates, toSection: 0)
          diffableDataSource.apply(snapshot, animatingDifferences: false)
          if !candidates.isEmpty {
            let invalidateContext = self.collectionViewLayout.invalidationContext(forBoundsChange: self.bounds)
            self.collectionViewLayout.invalidateLayout(with: invalidateContext)

            self.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
          }
        }
        .store(in: &subscriptions)
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
      }
    } else {
      setCollectionViewLayout(verticalLayout, animated: false) { [weak self] _ in
        guard let self = self else { return }
        self.alwaysBounceHorizontal = false
        self.alwaysBounceVertical = true
        self.contentOffset = .zero
      }
    }

    // 改变布局后，需要重新加载数据，否则会显示不正确(iOS 15)
    reloadDiffableDataSource()
  }

  func reloadDiffableDataSource() {
    var snapshot = self.diffableDataSource.snapshot()
    snapshot.reloadSections([0])
    self.diffableDataSource.apply(snapshot, animatingDifferences: false)
  }
}

// MAKE: - UICollectionViewDelegate

extension CandidateWordsCollectionView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    Task {
      // 用于触发反馈
      actionHandler.handle(.press, on: .none)
      await self.rimeContext.selectCandidate(index: indexPath.item)
      keyboardContext.candidatesViewState = .collapse
    }
  }

  public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) {
      cell.isHighlighted = true
    }
  }
}

// MAKE: - UICollectionViewDelegateFlowLayout

extension CandidateWordsCollectionView: UICollectionViewDelegateFlowLayout {
  // 询问委托一个部分连续的行或列之间的间距。
  // 对于一个垂直滚动的网格，这个值表示连续的行之间的最小间距。
  // 对于一个水平滚动的网格，这个值代表连续的列之间的最小间距。
  // 这个间距不应用于标题和第一行之间的空间或最后一行和页脚之间的空间。
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }

  // 向委托询问某部分的行或列中连续项目之间的间距。
  // 你对这个方法的实现可以返回一个固定的值或者为每个部分返回不同的间距值。
  // 对于一个垂直滚动的网格，这个值代表了同一行中项目之间的最小间距。
  // 对于一个水平滚动的网格，这个值代表同一列中项目之间的最小间距。
  // 这个间距是用来计算单行可以容纳多少个项目的，但是在确定了项目的数量之后，实际的间距可能会被向上调整。
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let candidate = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    let toolbarConfig = keyboardContext.hamsterConfig?.toolbar
    let titleFontSize = toolbarConfig?.candidateWordFontSize
    let subtileFontSize = toolbarConfig?.candidateCommentFontSize
    let showComment = toolbarConfig?.displayCommentOfCandidateWord ?? false
    let showIndex = toolbarConfig?.displayIndexOfCandidateWord ?? false

    let intrinsicVerticalMargin: CGFloat = 5 + 5
    let intrinsicHorizontalMargin: CGFloat = 5 + 5
    let maxWidth: CGFloat
    if self.window?.screen.interfaceOrientation == .portrait {
      maxWidth = UIScreen.main.bounds.width - 60
    } else {
      maxWidth = UIScreen.main.bounds.height - 60
    }

    let index = candidate.index
    let titleText = showIndex ? "\(index + 1). \(candidate.title)" : candidate.title
    let targetWidth = maxWidth - intrinsicHorizontalMargin

    let titleLabelSize = UILabel.estimatedSize(
      titleText,
      targetSize: CGSize(width: targetWidth, height: 0),
      font: titleFontSize != nil ? UIFont.systemFont(ofSize: CGFloat(titleFontSize!)) : nil
    )

    // 不显示 comment
    if !showComment {
      let width = titleLabelSize.width + intrinsicHorizontalMargin + 2
      return CGSize(
        width: min(width, maxWidth),
        height: titleLabelSize.height + intrinsicVerticalMargin
      )
    }

    let subtitleLableSize = UILabel.estimatedSize(
      candidate.subtitle ?? "",
      targetSize: CGSize(width: targetWidth, height: 0),
      font: subtileFontSize != nil ? UIFont.systemFont(ofSize: CGFloat(subtileFontSize!)) : nil
    )

    let width = titleLabelSize.width + subtitleLableSize.width + intrinsicHorizontalMargin + 2
    return CGSize(
      width: min(width, maxWidth),
      height: titleLabelSize.height + intrinsicVerticalMargin
    )
  }
}

public extension UILabel {
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
