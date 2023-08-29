//
//  CandidateWordsCollectionView.swift
//
//
//  Created by morse on 2023/8/19.
//

import Combine
import HamsterKit
import HamsterModel
import OSLog
import UIKit

/**
 候选文字集合视图
 */
public class CandidateWordsCollectionView: UICollectionView {
  /// RIME 上下文
  let rimeContext: RimeContext

  let keyboardContext: KeyboardContext

  let actionHandler: KeyboardActionHandler

  /// 滚动方向
  let direction: UICollectionView.ScrollDirection

  /// 水平滚动方向布局
  let horizontalLayout: UICollectionViewLayout

  /// Combine
  var subscriptions = Set<AnyCancellable>()

  private var diffableDataSource: UICollectionViewDiffableDataSource<Int, CandidateSuggestion>! = nil

  init(
    keyboardContext: KeyboardContext,
    actionHandler: KeyboardActionHandler,
    rimeContext: RimeContext,
    direction: UICollectionView.ScrollDirection = .horizontal
  ) {
    self.keyboardContext = keyboardContext
    self.actionHandler = actionHandler
    self.rimeContext = rimeContext
    self.direction = direction

    self.horizontalLayout = {
      let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(40), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(40), heightDimension: .fractionalHeight(1.0))
      let group: NSCollectionLayoutGroup
      if #available(iOS 16.0, *) {
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
      } else {
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      }
      let section = NSCollectionLayoutSection(group: group)
      // 控制水平方向 item 之间间距
      // 注意：添加间距会导致点击间距无响应，需要将间距在 cell 的自动布局中添加进去
      // section.interGroupSpacing = 0
      section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
      // 控制垂直方向距拼写区的间距
      // 注意：添加间距会导致点击间距无响应，需要将间距在 cell 的自动布局中添加进去
      // section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
      return UICollectionViewCompositionalLayout(section: section)
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
    self.showsHorizontalScrollIndicator = false

    if direction == .horizontal {
      self.alwaysBounceHorizontal = true
      self.alwaysBounceVertical = false
    }

    combine()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 构建数据源
  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, CandidateSuggestion> {
    var keyboardColor: HamsterModel.KeyboardColor? = nil
    let toolbarConfig = keyboardContext.hamsterConfig?.toolbar
    let showIndex = toolbarConfig?.displayIndexOfCandidateWord
    let titleFontSize = toolbarConfig?.candidateWordFontSize
    let subtileFontSize = toolbarConfig?.candidateCommentFontSize

    // 开启键盘配色
    if keyboardContext.hamsterConfig?.Keyboard?.enableColorSchema ?? false,
       let color = keyboardContext.hamsterKeyboardColor
    {
      keyboardColor = color
    }

    let candidateWordCellRegistration = UICollectionView.CellRegistration<CandidateWordCell, CandidateSuggestion>
    { cell, _, candidateSuggestion in
      cell.updateWithCandidateSuggestion(
        candidateSuggestion,
        color: keyboardColor,
        showIndex: showIndex,
        titleFont: titleFontSize != nil ? UIFont.systemFont(ofSize: CGFloat(titleFontSize!)) : nil,
        subtitleFont: subtileFontSize != nil ? UIFont.systemFont(ofSize: CGFloat(subtileFontSize!)) : nil
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
          }
        }
        .store(in: &self.subscriptions)
    }
  }
}

// MAKE: - UICollectionViewDelegateFlowLayout

extension CandidateWordsCollectionView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    Task {
      // 用于触发反馈
      actionHandler.handle(.press, on: .none)
      if let text = await self.rimeContext.selectCandidate(index: indexPath.item) {
        keyboardContext.textDocumentProxy.insertText(text)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          self.rimeContext.reset()
        }
      } else {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
      }
    }
  }

  public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) {
      cell.isHighlighted = true
    }
  }
}
